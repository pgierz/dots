export CONDARC="${XDG_CONFIG_HOME:=${HOME}/.config}/conda/.condarc"

case $(hostname) in
  *bkli04m034* | vpn-*.awi.de | Pauls-MacBook-Air.local )
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/usr/local/Caskroom/mambaforge/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/usr/local/Caskroom/mambaforge/base/etc/profile.d/conda.sh" ]; then
            . "/usr/local/Caskroom/mambaforge/base/etc/profile.d/conda.sh"
        else
            export PATH="/usr/local/Caskroom/mambaforge/base/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
    ;;
  *)
    echo "No conda setup for $(hostname)"
    ;;
esac
