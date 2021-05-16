#!/usr/bin/env bash
set -e

echo "+ Sourcing variables from PKGBUILD"
source src/PKGBUILD

echo "+ Setting variables in PKGBUILDs"
for i in PKGBUILD_DEBIAN PKGBUILD_AUR; do
  sed -i "s|pkgver=.*|pkgver=${pkgver}|" src/PKGBUILDs/"${i}"
  sed -i "s|pkgrel=.*|pkgrel=${pkgrel}|" src/PKGBUILDs/"${i}"
done
