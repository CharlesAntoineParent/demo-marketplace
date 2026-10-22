#!/usr/bin/env bash
# PostToolUse: lint the .al file Claude just edited.
#
# The AL compiler works on a whole project, so we compile the project that
# contains the file with the analyzers enabled, then keep only the
# diagnostics that point at the edited file.
#
# Exit 0: nothing to report (not an .al file, or the file is clean).
# Exit 2: stderr goes back to Claude so it fixes the warnings.

set -uo pipefail

# Tell the user (not Claude) that the linter could not run, then fail open.
warn_user() {
  printf '{"systemMessage": "al: %s"}\n' "$1"
  exit 0
}

command -v jq >/dev/null 2>&1 || warn_user "jq est introuvable, lint AL ignoré."

file=$(jq -r '.tool_input.file_path // empty')
[[ "$file" == *.al || "$file" == *.AL ]] || exit 0
[[ -f "$file" ]] || exit 0

# Project root: closest parent folder that holds app.json.
root=$(dirname "$file")
while [[ "$root" != "/" && ! -f "$root/app.json" ]]; do
  root=$(dirname "$root")
done
[[ -f "$root/app.json" ]] || exit 0

al_cmd=$(command -v al || command -v altool) \
  || warn_user "la commande al est introuvable. Installer: dotnet tool install -g Microsoft.Dynamics.BusinessCentral.Development.Tools"

[[ -d "$root/.alpackages" ]] \
  || warn_user "aucun dossier .alpackages dans $root. Télécharger les symboles avant de lancer le lint."

# Built-in analyzers ship inside the dotnet tool package.
tool_store="${AL_ANALYZER_DIR:-$HOME/.dotnet/tools/.store/microsoft.dynamics.businesscentral.development.tools}"
args=("/project:$root" "/packagecachepath:$root/.alpackages")

IFS=',' read -ra wanted <<< "${CLAUDE_PLUGIN_OPTION_ANALYZERS:-CodeCop,UICop}"
for name in "${wanted[@]}"; do
  name=$(echo "$name" | tr -d '[:space:]')
  [[ -n "$name" ]] || continue
  dll=$(find "$tool_store" -name "Microsoft.Dynamics.Nav.$name.dll" 2>/dev/null | head -n 1)
  if [[ -n "$dll" ]]; then
    args+=("/analyzer:$dll")
  else
    warn_user "analyseur $name introuvable dans $tool_store."
  fi
done

IFS=';' read -ra custom <<< "${CLAUDE_PLUGIN_OPTION_CUSTOM_ANALYZERS:-}"
for dll in ${custom[@]+"${custom[@]}"}; do
  [[ -n "$dll" ]] && args+=("/analyzer:$dll")
done

ruleset="${CLAUDE_PLUGIN_OPTION_RULESET:-}"
[[ -n "$ruleset" ]] && args+=("/ruleset:$root/$ruleset")

out_dir=$(mktemp -d)
trap 'rm -rf "$out_dir"' EXIT
args+=("/out:$out_dir/lint.app")

output=$("$al_cmd" compile "${args[@]}" 2>&1)

# Diagnostics look like: path(line,col): warning AA0137: message
# Paths can be absolute or relative, with / or \, so compare on the
# path relative to the project root, lowercased.
rel=${file#"$root"/}
rel_norm=$(echo "$rel" | tr '[:upper:]\\' '[:lower:]/')

findings=$(echo "$output" | tr -d '\r' | awk -v rel="$rel_norm" '
  match($0, /^.+\([0-9]+,[0-9]+\): (error|warning) [A-Za-z]+[0-9]+:/) {
    path = substr($0, 1, index($0, "(") - 1)
    gsub(/\\/, "/", path)
    path = tolower(path)
    if (substr(path, length(path) - length(rel) + 1) == rel) print
  }')

[[ -z "$findings" ]] && exit 0

{
  echo "Lint AL sur $rel:"
  echo "$findings" | sed -E 's/^.+(\([0-9]+,[0-9]+\))/  \1/'
  echo "Corrige ces diagnostics avant de continuer."
} >&2
exit 2
