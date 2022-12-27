# Slurm specific aliases
alias sq='squeue -u $(whoami) -o "%.18i %.9P %.20j %.8u %.8T %.10M %.9l %.6D %R"'
alias sqs='squeue -u $(whoami) --start'
alias csq='squeue -u $(whoami) -o "%.18i %.9P %.20j %.8u %.8T %.10M %.9l %.6D %R" -i 2'
alias csqs='squeue -u $(whoami) --start -i 2'

function _cluster_jobs() {
        local IFS=$'\n'
        local job_ids=$(squeue --user ${USER} -o "%A:%j" --noheader)
        #local job_ids=$(squeue -o "%A:%j" --noheader)
        _describe 'command' "($job_ids[@])" #"('$job_ids')" #cmd1:description1' '')"
}

compdef _cluster_jobs scancel
