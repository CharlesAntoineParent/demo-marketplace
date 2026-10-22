#!/usr/bin/env bash
# SessionStart: check that the AL linter toolchain is installed.
#
# Silent outside AL projects and when everything is in place. Otherwise it
# adds a note to Claude's context asking it to warn the user, with the
# install commands.

set -uo pipefail

project="${CLAUDE_PROJECT_DIR:-$PWD}"

# Only AL projects: an app.json at the root or a few levels down.
[[ -n $(find "$project" -maxdepth 3 -name app.json -not -path '*/node_modules/*' -print -quit 2>/dev/null) ]] || exit 0

missing=()

if ! command -v al >/dev/null 2>&1 && ! command -v altool >/dev/null 2>&1; then
  missing+=("- AL Development Tools (commande al), requis par le lint: dotnet tool install -g Microsoft.Dynamics.BusinessCentral.Development.Tools")
else
  tool_store="${AL_ANALYZER_DIR:-$HOME/.dotnet/tools/.store/microsoft.dynamics.businesscentral.development.tools}"
  if [[ -z $(find "$tool_store" -name 'Microsoft.Dynamics.Nav.CodeCop.dll' -print -quit 2>/dev/null) ]]; then
    missing+=("- Analyseur CodeCop introuvable dans $tool_store. Réinstaller les AL Development Tools, ou définir AL_ANALYZER_DIR vers le dossier qui contient les DLL des analyseurs.")
  fi
fi

command -v jq >/dev/null 2>&1 \
  || missing+=("- jq, requis par le hook de lint (macOS: brew install jq, Windows: winget install jqlang.jq)")

command -v alcops-mcp >/dev/null 2>&1 \
  || missing+=("- ALCops MCP (commande alcops-mcp), pour les outils de compilation et de correction: dotnet tool install -g ALCops.Mcp")

[[ ${#missing[@]} -eq 0 ]] && exit 0

context="Le plugin al a détecté des outils manquants: le lint automatique des fichiers .al ne fonctionnera pas tant qu'ils ne sont pas installés.
$(printf '%s\n' "${missing[@]}")
Au début de ta prochaine réponse, avertis l'utilisateur en une ou deux phrases et donne-lui les commandes d'installation ci-dessus. Ne les exécute pas toi-même sans son accord."

# Build the JSON without jq, since jq may be the missing tool.
escaped=$(printf '%s' "$context" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' | awk '{printf "%s\\n", $0}')
printf '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$escaped"
exit 0
