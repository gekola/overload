#!/bin/sh

#
# Run Mozilla Firefox on X11
#
export MOZ_DISABLE_WAYLAND=1
FNAME="$(basename $0)"
exec @PREFIX@/bin/"${FNAME%-*}" "$@"
