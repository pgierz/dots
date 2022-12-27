alias config="/usr/bin/git --git-dir=${HOME}/.cfg/ --work-tree=${HOME}"

function retrieve_cfg() {
        f=$1
        config reset -- $1
        config checkout -- $1
}
