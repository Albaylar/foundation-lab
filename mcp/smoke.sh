#!/usr/bin/env bash
# MCP server smoke test: raw JSON-RPC over stdio.
# Usage: ./mcp/smoke.sh [dart-file-to-check]
set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-app/lib/main.dart}"

{
  echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"smoke","version":"0"}}}'
  echo '{"jsonrpc":"2.0","method":"notifications/initialized"}'
  echo '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
  echo '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"list_components","arguments":{}}}'
  echo "{\"jsonrpc\":\"2.0\",\"id\":4,\"method\":\"tools/call\",\"params\":{\"name\":\"check_design_rules\",\"arguments\":{\"path\":\"$TARGET\"}}}"
  sleep 2
} | ./mcp/bin/ds-mcp --root .