#!/bin/bash

echo "###########################################################"
echo "#                                                         #"
echo "# Creating a GPG Key without Expiration and Maximum Trust #"
echo "# ------------------------------------------------------- #"
echo "#                                                         #"
read -p "# Enter your full name: " name
read -p "# Enter your email address: " email
read -p "# Enter a comment (optional): " comment
echo "###########################################################"

echo "# Generating GPG key for                                  #"
echo "#                                                         #"
echo "# $name <$email> ($comment)"
echo "#                                                         #"
echo "# without expiration...                                   #"

# Generate key in batch mode
cat >gen-key-script <<EOF
Key-Type: RSA
Key-Length: 4096
Name-Real: $name
Name-Email: $email
EOF

if [ -n "$comment" ]; then
    echo "Name-Comment: $comment" >> gen-key-script
fi

cat >>gen-key-script <<EOF
Expire-Date: 0
%commit
%echo Generating key, please wait...
EOF

# Generate the key
gpg --batch --full-gen-key gen-key-script
rm gen-key-script

echo "# Setting ultimate trust for the generated key...         #"
key_id=$(gpg --list-secret-keys --keyid-format LONG | grep sec | awk '{print $2}' | cut -d '/' -f 2)
echo "Key ID: $key_id"
echo -e "trust\n5\ny\n" | gpg --batch --command-fd 0 --edit-key $key_id

echo "# GPG key generation complete.                            #"
echo "###########################################################"
