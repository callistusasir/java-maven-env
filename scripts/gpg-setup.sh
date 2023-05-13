#!/bin/bash

source $(dirname "$0")/print_style.sh

USER_EMAIL="$(git config --local user.email)"
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Add GNU PGP public key to key store
function setup_gpg_for_git() {
    # Works in AWS Workspaces
    GPG_PUB_ID=$(gpg --list-secret-keys --keyid-format=long -a ${USER_EMAIL} | grep '^sec' | head -n 1 | cut -d'/' -f2 | cut -d' ' -f1)
    if [ -n "$GPG_PUB_ID" ]; then
        print_style "Using GPG key: $GPG_PUB_ID" "info"
        git config --local user.signingkey "$GPG_PUB_ID"
    fi
    git config --local commit.gpgsign true

    # Prevent trying to run pinentry within the VSCode container
    # This is only changing the container-local ~/.bashrc
    printf "\nexport GPG_TTY=%s\n" "\$(tty)" >> ~/.bashrc
}

function additional_git_configurations() {
    git config --local fetch.prune true 
    git config --local pull.rebase false # Merge Commit Strategy
    git config --local core.autocrlf false # force lf file ending consistency
    git config --local core.eol lf 
    git config --global core.sshCommand $(which ssh) # For Windows File systems allows 
    git config --local push.autoSetupRemote true # Allows to push locally named branches automatically
    git config --global --add safe.directory .
}

# using ! before -f parameter to check if 
# file does not exist
# Add Public key
if [[ -f "$SCRIPT_DIR/../public.asc" ]] ;
then
gpg -quiet --import "$SCRIPT_DIR/../public.asc"
print_style "Public key has been succesfully imported" "success";
fi
# Add Secret Key
if [[ -f "$SCRIPT_DIR/../secret.asc" ]] ;
then
gpg -quiet --import "$SCRIPT_DIR/../secret.asc"
print_style "Secret key has been succesfully imported" "success";
fi
if [[ -f "$SCRIPT_DIR/../secret.asc" && -f "$SCRIPT_DIR/../public.asc" ]] ;
then
setup_gpg_for_git
print_style "Git has been configured to work with GPG Keys Imported" "success";
fi
additional_git_configurations