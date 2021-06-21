#!/usr/bin/env bash
set -e

# Define functions
aur_clone() {
    cd ..
    git clone "https://${aur_url}/makedeb-db.git" "makedeb-db_aur"
}

aur_configure() {
    pkgbuild_pkgver=$(cat src/PKGBUILD | grep 'pkgver=' | sed 's|pkgver=||')
    pkgbuild_pkgrel=$(cat src/PKGBUILD | grep 'pkgrel=' | sed 's|pkgrel=||')

    cd ..

    sed -i "s|pkgver=.*|pkgver=${pkgbuild_pkgver}|" "makedeb-db_aur/PKGBUILD"
    sed -i "s|pkgrel=.*|pkgrel=${pkgbuild_pkgrel}|" "makedeb-db_aur/PKGBUILD"

    chown 'user:user' "makedeb-db_aur" -R
    cd "${package_name}"
    sudo -u user makepkg --printsrcinfo | tee .SRCINFO
}

aur_push() {
    # Set up SSH keys, known_hosts, and config file
    mkdir -p /root/.ssh/

    echo "${known_hosts}" > /root/.ssh/known_hosts

    echo "${aur_ssh_key}" > /root/.ssh/AUR
    chmod 400 /root/.ssh/AUR

    printf "Host ${aur_url}\n  Hostname ${aur_url}\n  IdentityFile /root/.ssh/AUR\n" > /root/.ssh/config

    pkgbuild_pkgver=$(cat src/PKGBUILD | grep 'pkgver=' | sed 's|pkgver=||')
    pkgbuild_pkgrel=$(cat src/PKGBUILD | grep 'pkgrel=' | sed 's|pkgrel=||')

    cd ../"makedeb-db_aur"

    git config user.name "Kavplex Bot"
    git config user.email "kavplex@hunterwittenborn.com"

    git add PKGBUILD .SRCINFO

    git commit -m "Updated version to ${pkgbuild_pkgver}-${pkgbuild_pkgrel}"

    git push "ssh://aur@${aur_url}/makedeb-db.git"
}

# Begin script
useradd user

case "${1}" in
    clone)        aur_clone ;;
    configure)    aur_configure ;;
    push)         aur_push ;;
esac
