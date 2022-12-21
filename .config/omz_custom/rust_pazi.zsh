if command -v pazi &>/dev/null; then
  eval "$(pazi init zsh)" # or 'bash'
fi
function pazi_pv() {
        exa -la -git {2}
}

if [ -f ${HOME}/.local/bin/clean_pazi.py ]; then
        module load python3
        time ${HOME}/.local/bin/clean_pazi.py
fi


alias zf='z --pipe="sk"'
bindkey -s "" "zf"

