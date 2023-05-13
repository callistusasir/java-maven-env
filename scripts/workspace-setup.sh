#!/bin/bash -e 

source $(dirname "$0")/print_style.sh

# Command to return to the executing directory
reset_dir() {
    cd "../$BASEDIR"
}

restart_gpg() {
    print_style "Recreating GPG Keychain for importing" "info"
    rm -rf ~/.gnupg
    gpg -K
    print_style "Recreated GPG Keychain for importing. Run the gpg-setup.sh script to import keys" "info"
}

restart_gpg
