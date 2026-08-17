# =============================================================================
# web-builder — install target config (EXAMPLE)
# -----------------------------------------------------------------------------
# Copy to scripts/install-config.local.sh (gitignored) and edit for your machine.
# install-skill.sh sources it to learn WHERE to install the packaged skill.
# Uses $HOME, never a hardcoded personal absolute path.
#
#   cp scripts/install-config.example.sh scripts/install-config.local.sh
#   # then edit the path below and run:  bash scripts/install-skill.sh --apply
# =============================================================================

# A skills directory an agent harness reads. Common choices:
#   "$HOME/.claude/skills"
#   "$HOME/.config/claude/skills"
WB_SKILL_INSTALL_DIR="$HOME/.claude/skills"
