#!/run/current-system/sw/bin/env bash
if ~/bin/kwin_wmgmt_helper --class kitty 2>/dev/null; then
    # Window found and raised
    exit 0
else
    # Not running → launch it
    kitty &
fi
