#!/usr/bin/env bash
# Uninstall addyosmani/agent-skills from Gemini CLI (user scope).
# Removes:
#   1. Skills (only those that exist in ./agent-skills/skills/)
#   2. Slash commands (only those shipped by the repo)
#   3. Persona files (only those shipped by the repo)
#
# Will NOT touch unrelated skills/commands/personas you have installed.

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
  echo "❌ agent-skills repo not found at: $REPO_DIR (needed to know what to remove)" >&2
  exit 1
fi

if ! command -v gemini >/dev/null 2>&1; then
  echo "❌ gemini CLI not found in PATH" >&2
  exit 1
fi

echo "🗑  Uninstalling agent-skills (sourced from $REPO_DIR)"
echo

# 1. Skills ----------------------------------------------------------------
echo "▶ [1/3] Uninstalling skills (user scope)…"
for skill_dir in "$SKILLS_SRC"/*/; do
  name="$(basename "$skill_dir")"
  printf "   • %-35s " "$name"
  if gemini skills uninstall "$name" --scope user >/dev/null 2>&1; then
    echo "removed"
  else
    echo "not installed (skipped)"
  fi
done
echo

# 2. Slash commands --------------------------------------------------------
echo "▶ [2/3] Removing slash commands from $COMMANDS_DST"
for f in "$COMMANDS_SRC"/*.toml; do
  name="$(basename "$f")"
  target="$COMMANDS_DST/$name"
  if [[ -f "$target" ]]; then
    rm -v "$target" | sed 's/^/   /'
  fi
done
echo

# 3. Personas --------------------------------------------------------------
echo "▶ [3/3] Removing personas from $AGENTS_DST"
for f in "$AGENTS_SRC"/*.md; do
  name="$(basename "$f")"
  [[ "$name" == "README.md" ]] && continue
  target="$AGENTS_DST/$name"
  if [[ -f "$target" ]]; then
    rm -v "$target" | sed 's/^/   /'
  fi
done

# clean up empty dirs
[[ -d "$AGENTS_DST" && -z "$(ls -A "$AGENTS_DST")" ]] && rmdir "$AGENTS_DST"
echo

echo "✅ Done."
