#!/bin/sh

#
# Run Mozilla Firefox under Wayland
#
export MOZ_ENABLE_WAYLAND=1
FNAME="$(basename $0)"
exec @PREFIX@/bin/"${FNAME%-*}" "$@"
