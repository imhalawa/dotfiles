#!/bin/bash
# Applies the paper palette to the current terminal pane only, via OSC escapes.
# Claude Code runs this on SessionStart ("set") and SessionEnd ("reset"),
# so other panes keep the terminal's own theme.
#
# Colors follow the system appearance: Selenized Light (paper) / Selenized Dark.

# Resolve a terminal to paint: the controlling tty, else the tty owning the
# parent process (Claude Code spawns hooks without a controlling terminal).
tty_out=""
if ( : >> /dev/tty ) 2>/dev/null; then
  tty_out=/dev/tty
else
  for pid in $PPID $(ps -o ppid= -p $PPID 2>/dev/null | tr -d ' '); do
    t=$(ps -o tty= -p "$pid" 2>/dev/null | tr -d ' ')
    case "$t" in
      ""|"??"|"-") continue ;;
    esac
    if ( : >> "/dev/$t" ) 2>/dev/null; then tty_out="/dev/$t"; break; fi
  done
fi
[ -n "$tty_out" ] || exit 0

osc() { printf "\033]%s\007" "$1" >> "$tty_out"; }

case "${1:-set}" in
  reset)
    # 104 = reset palette, 110/111/112 = reset fg/bg/cursor
    osc "104"; osc "110"; osc "111"; osc "112"
    exit 0
    ;;
esac

if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
  bg='#0F3841'; fg='#C3D2D2'; cursor='#4695F7'
  p=('#184956' '#FA5750' '#75B938' '#DBB32D' '#4695F7' '#F275BE' '#41C7B9' '#72898F'
     '#2D5B69' '#FF665C' '#84C747' '#EBC13D' '#58A3FF' '#FF84CD' '#53D6C7' '#CAD8D9')
  claude_theme=dark-ansi
else
  bg='#FDFCF8'; fg='#2E3E44'; cursor='#0072D4'
  p=('#ECE3CC' '#D2212D' '#489100' '#AD8900' '#0072D4' '#CA4898' '#009C8F' '#909995'
     '#D5CDB6' '#CC1729' '#428B00' '#A78300' '#006DCE' '#C44392' '#00978A' '#3A4D53')
  claude_theme=light-ansi
fi

for i in "${!p[@]}"; do osc "4;${i};${p[$i]}"; done
osc "10;${fg}"; osc "11;${bg}"; osc "12;${cursor}"

# Claude picks its own theme at startup, so a mode flip lands on the next session.
settings="$HOME/.claude/settings.json"
python3 - "$settings" "$claude_theme" <<'PY' 2>/dev/null
import json,sys
p,want=sys.argv[1],sys.argv[2]
s=json.load(open(p))
if s.get("theme")!=want:
    s["theme"]=want
    json.dump(s,open(p,"w"),indent=2)
PY
