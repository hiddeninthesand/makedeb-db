## Overview ##
makedeb-db converts Arch Linux dependency names to their Debian counterparts.

## Installation ##
Arch Linux users can install makedeb-db from the [AUR](https://aur.archlinux.org/packages/makedeb-db/).

Users on Debian or Debian-based systems (i.e. Ubuntu) should follow the below instructions.

First, set up the repository with the following commands:
```sh
sudo wget 'https://hunterwittenborn.com/keys/apt.asc' -O /etc/apt/trusted.gpg.d/hwittenborn.asc
echo 'deb [arch=all] https://repo.hunterwittenborn.com/debian/makedeb any main' | sudo tee /etc/apt/sources.list.d/makedeb.list
sudo apt update
```

Then, install makedeb-db with the following command:
```sh
sudo apt install makedeb-db
```

## Usage ##
Instructions can be found after installation with `makedeb-db --help`

## Specification ##
makedeb-db will search the database for the package(s) specified and return the results in JSON format.

The `--package`/`-P` option only accepts one package as an argument.

The `--general`/`-G` option will only return packages that can be found inside the database. This option accepts as many packages as you give it.

The returning JSON isn't currently set in stone, and may change at any time. If you require more stability, you'll need to act directly upon the database until this message is removed.
