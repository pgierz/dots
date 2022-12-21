mkdir -p "${XDG_CACHE_HOME=${HOME}/.cache}"/less
export LESSKEY="${XDG_CONFIG_HOME:=${HOME}/.config}"/less/lesskey
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history

