#foundation-lab


Flutter app (app/) + Go MCP server (mcp/) + evals (evals/).


## Design system rules (app/)
- Never hardcode colors, spacing or radius. Use tokens from `lib/design/tokens.dart`
  via `context.tokens`.
- Use shared components from `lib/design/components/` before writing new widgets.
- Prefer `const` constructors.

## Commands
- `cd app && flutter analyze && flutter test`
- `cd mcp && go test ./...`