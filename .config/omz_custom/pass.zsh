export PASSWORD_STORE_DIR=${XDG_DATA_HOME}/password-store

function export_tokens() {
        eval $(gpg-agent --daemon)
        pass ls tokens | sed 's/├\|─\|│\|└/ /g' | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' | sed "s/^[ \t]*//" | sed "s/tokens//" | while IFS= read -r token; do
                if [ ! -z $token ]; then
                        original_token=$token
                        token=$(echo $token | tr '[:lower:]' '[:upper:]')_TOKEN
                        if [ ! -z $DEBUG_EXPORT_TOKENS ]; then
                                echo export $token=\$\(pass tokens/$original_token\)
                        fi
                        eval export $token=$(pass tokens/$original_token)
                fi
        done
}

