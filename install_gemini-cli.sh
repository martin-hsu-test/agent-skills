#!/usr/bin/env bash
# Install addyosmani/agent-skills (forked) into Gemini CLI (user scope).
# Installs three things:
#   1. Skills        -> via `gemini skills install`  (registered in ~/.gemini/skills)
#   2. Slash cmds    -> copied to ~/.gemini/commands/   (e.g. /spec /review /ship)
#   3. Personas      -> copied to ~/.gemini/agents/     (used via @agents/xxx.md)
#
# Re-runnable: existing files are overwritten; existing skills are re-installed.

set -euo pipefail

# REPO_DIR = directory of this script (i.e. the agent-skills repo root)
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"
COMMANDS_SRC="$REPO_DIR/.gemini/commands"
AGENTS_SRC="$REPO_DIR/agents"

GEMINI_HOME="$HOME/.gemini"
COMMANDS_DST="$GEMINI_HOME/commands"
AGENTS_DST="$GEMINI_HOME/agents"

if [[ ! -d "$REPO_DIR" ]]; then
  echo "❌ agent-skills repo not found at: $REPO_DIR" >&2
  exit 1
fi

if ! command -v gemini >/dev/null 2>&1; then
  echo "❌ gemini CLI not found in PATH" >&2
  exit 1
fi

echo "📦 Installing agent-skills from: $REPO_DIR"
echo

# 1. Skills ----------------------------------------------------------------
echo "▶ [1/3] Installing skills (user scope)…"
count=0
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  printf "   • %-35s " "$name"
  if gemini skills install "$skill_dir" --scope user --consent >/dev/null 2>&1; then
    echo "ok"
    count=$((count + 1))
  else
    echo "FAILED"
  fi
done
echo "   → $count skills installed."
echo

# 2. Slash commands --------------------------------------------------------
echo "▶ [2/3] Copying slash commands → $COMMANDS_DST"
mkdir -p "$COMMANDS_DST"
cp -v "$COMMANDS_SRC"/*.toml "$COMMANDS_DST"/ | sed 's/^/   /'
echo

# 3. Personas --------------------------------------------------------------
echo "▶ [3/3] Copying personas → $AGENTS_DST"
mkdir -p "$AGENTS_DST"
cp -v "$AGENTS_SRC"/*.md "$AGENTS_DST"/ | sed 's/^/   /'
echo

echo "✅ Done."
echo
echo "Verify:"
echo "   gemini skills list | grep -E 'spec-driven|code-review|test-driven'"
echo "   ls $COMMANDS_DST"
echo "   ls $AGENTS_DST"
echo
echo "Use:"
echo "   In gemini interactive: /spec  /planning  /build  /test  /review  /code-simplify  /ship"
echo "   For personas:          @$AGENTS_DST/code-reviewer.md  please review my changes"
