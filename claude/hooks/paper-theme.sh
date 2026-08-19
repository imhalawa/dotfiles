#!/bin/bash
# Paints the current terminal pane via OSC escapes — one pane only, so other
# panes keep the terminal's own colors.
#
#   set    high-contrast black (Claude Code SessionStart)
#   paper  cream paper palette, for reading long output
#   reset  hand the pane back to the terminal theme (SessionEnd)
#
# The `paper` shell function in ~/.zshrc wraps this: `paper` / `paper off`.

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
  paper)
    bg='#FDFCF8'; fg='#2E3E44'; cursor='#0072D4'
    # Selenized Light. Bright slots (8-15) are dark ink, so they stay readable
    # on cream even when an app assumes a dark background.
    p=('#ECE3CC' '#D2212D' '#489100' '#AD8900' '#0072D4' '#CA4898' '#009C8F' '#909995'
       '#D5CDB6' '#CC1729' '#428B00' '#A78300' '#006DCE' '#C44392' '#00978A' '#3A4D53')
    ;;
  *)
    bg='#000000'; fg='#F2F2F2'; cursor='#FFFFFF'
    p=('#5C6370' '#FF6B60' '#7FE787' '#FFD866' '#6FB6FF' '#FF8AD8' '#5BE7DA' '#E6E6E6'
       '#7A8290' '#FF8B80' '#A2F5A8' '#FFE28A' '#9CCDFF' '#FFA9E4' '#86F2E8' '#FFFFFF')
    ;;
esac

for i in "${!p[@]}"; do osc "4;${i};${p[$i]}"; done
osc "10;${fg}"; osc "11;${bg}"; osc "12;${cursor}"
