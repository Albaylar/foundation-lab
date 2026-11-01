package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/modelcontextprotocol/go-sdk/mcp"
)

// Repo'nun kök klasörü. --root flag'i ile verilir.
var root string

// ---------- Tool 1: list_components ----------

type Component struct {
	Name        string `json:"name"`
	File        string `json:"file"`
	Description string `json:"description"`
}

type ListComponentsOut struct {
	Components []Component `json:"components"`
}

// Dart dosyasında "class KnowButton extends ..." satırını yakalar.
var classRe = regexp.MustCompile(`^class\s+([A-Z]\w*)\s+extends`)

// Bir .dart dosyasından public class adını ve üstündeki /// yorumları çıkarır.
func parseComponent(path string) (Component, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return Component{}, err
	}
	var doc []string
	for _, line := range strings.Split(string(data), "\n") {
		trimmed := strings.TrimSpace(line)
		switch {
		case strings.HasPrefix(trimmed, "///"):
			doc = append(doc, strings.TrimSpace(strings.TrimPrefix(trimmed, "///")))
		case strings.HasPrefix(trimmed, "@"):
			// @immutable gibi annotation'ları atla
		default:
			if m := classRe.FindStringSubmatch(trimmed); m != nil {
				rel, _ := filepath.Rel(root, path)
				return Component{Name: m[1], File: rel, Description: strings.Join(doc, "\n")}, nil
			}
			doc = nil
		}
	}
	return Component{}, fmt.Errorf("no public class in %s", path)
}

func listComponents(ctx context.Context, req *mcp.CallToolRequest, _ struct{}) (*mcp.CallToolResult, ListComponentsOut, error) {
	files, err := filepath.Glob(filepath.Join(root, "app/lib/design/components/*.dart"))
	if err != nil {
		return nil, ListComponentsOut{}, err
	}
	out := ListComponentsOut{Components: []Component{}}
	for _, f := range files {
		if c, err := parseComponent(f); err == nil {
			out.Components = append(out.Components, c)
		}
	}
	return nil, out, nil
}

// ---------- Tool 2: get_tokens ----------

type TokensOut struct {
	Usage  string `json:"usage"`
	Source string `json:"source"`
}

func getTokens(ctx context.Context, req *mcp.CallToolRequest, _ struct{}) (*mcp.CallToolResult, TokensOut, error) {
	data, err := os.ReadFile(filepath.Join(root, "app/lib/design/tokens.dart"))
	if err != nil {
		return nil, TokensOut{}, err
	}
	return nil, TokensOut{
		Usage:  "final t = context.tokens; then t.colors.<name>, t.spacing.<xs|sm|md|lg|xl>, t.radius.<sm|md|lg>",
		Source: string(data),
	}, nil
}

// ---------- Tool 3: check_design_rules ----------

type CheckIn struct {
	Path string `json:"path" jsonschema:"Dart file path relative to repo root, e.g. app/lib/screens/home.dart"`
}

type Violation struct {
	Line int    `json:"line"`
	Rule string `json:"rule"`
	Code string `json:"code"`
}

type CheckOut struct {
	OK         bool        `json:"ok"`
	Violations []Violation `json:"violations"`
}

var rules = []struct {
	name string
	re   *regexp.Regexp
}{
	{"hardcoded color, use context.tokens.colors", regexp.MustCompile(`Color\(0x|Colors\.[a-z]`)},
	{"hardcoded spacing, use context.tokens.spacing", regexp.MustCompile(`EdgeInsets\.\w+\((\s*\d|[^)]*:\s*\d)|SizedBox\([^)]*(height|width):\s*\d`)},
	{"hardcoded radius, use context.tokens.radius", regexp.MustCompile(`BorderRadius\.circular\(\s*\d`)},
}

// Hem MCP tool'u hem CLI modu bu fonksiyonu kullanır.
func checkFile(rel string) (CheckOut, error) {
	path := filepath.Join(root, rel)
	if !strings.HasPrefix(path, root+string(os.PathSeparator)) {
		return CheckOut{}, fmt.Errorf("path must be inside the repo")
	}
	data, err := os.ReadFile(path)
	if err != nil {
		return CheckOut{}, err
	}
	out := CheckOut{Violations: []Violation{}}
	for i, line := range strings.Split(string(data), "\n") {
		for _, r := range rules {
			if r.re.MatchString(line) {
				out.Violations = append(out.Violations, Violation{Line: i + 1, Rule: r.name, Code: strings.TrimSpace(line)})
			}
		}
	}
	out.OK = len(out.Violations) == 0
	return out, nil
}

func checkDesignRules(ctx context.Context, req *mcp.CallToolRequest, in CheckIn) (*mcp.CallToolResult, CheckOut, error) {
	out, err := checkFile(in.Path)
	return nil, out, err
}

// ---------- main ----------

func main() {
	var checkPath string
	flag.StringVar(&root, "root", ".", "path to the foundation-lab repo root")
	flag.StringVar(&checkPath, "check", "", "check one Dart file and exit (CLI mode)")
	flag.Parse()
	abs, err := filepath.Abs(root)
	if err != nil {
		log.Fatal(err)
	}
	root = abs

	// CLI modu: server başlatma, dosyayı kontrol et ve çık.
	if checkPath != "" {
		out, err := checkFile(checkPath)
		if err != nil {
			log.Fatal(err)
		}
		b, _ := json.MarshalIndent(out, "", "  ")
		fmt.Println(string(b))
		if !out.OK {
			os.Exit(1)
		}
		return
	}

	server := mcp.NewServer(&mcp.Implementation{Name: "design-system", Version: "v0.1.0"}, nil)

	mcp.AddTool(server, &mcp.Tool{
		Name:        "list_components",
		Description: "List shared Flutter design system components with usage docs. Call this BEFORE writing any new widget.",
	}, listComponents)

	mcp.AddTool(server, &mcp.Tool{
		Name:        "get_tokens",
		Description: "Get design tokens (colors, spacing, radius) and how to access them. Never hardcode these values.",
	}, getTokens)

	mcp.AddTool(server, &mcp.Tool{
		Name:        "check_design_rules",
		Description: "Check a Dart file for hardcoded colors, spacing or radius. Call this AFTER editing a file and fix every violation.",
	}, checkDesignRules)

	// stdio: Claude Code bu process'i başlatır ve stdin/stdout üzerinden konuşur.
	if err := server.Run(context.Background(), &mcp.StdioTransport{}); err != nil {
		log.Fatal(err)
	}
}
