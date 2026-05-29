#!/usr/bin/env bash
# Atualiza a skill nicochat-prompt a partir do GitHub, silenciosamente,
# apenas se a working tree estiver limpa. Usado como SessionStart hook
# do Claude Code.

dir="$HOME/.claude/skills/nicochat-prompt"
[ ! -d "$dir" ] && exit 0

cd "$dir" || exit 0

# Aborta se houver edição local não commitada (evita conflito de merge).
[ -n "$(git status --porcelain 2>/dev/null)" ] && exit 0

git fetch --quiet >/dev/null 2>&1
behind=$(git rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)
if [ "$behind" -gt 0 ] 2>/dev/null; then
    git pull --quiet --ff-only >/dev/null 2>&1
fi

exit 0
