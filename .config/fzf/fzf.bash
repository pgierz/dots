# Setup fzf
# ---------
if [[ ! "$PATH" == */pf/a/a270077/.local/src/fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}/pf/a/a270077/.local/src/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/pf/a/a270077/.local/src/fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/pf/a/a270077/.local/src/fzf/shell/key-bindings.bash"
