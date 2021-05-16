#!/usr/bin/env bash
set -e

rm aur_makedeb-db/PKGBUILD
cp makedeb-db/src/PKGBUILDs/PKGBUILD_AUR aur_makedeb-db/PKGBUILD
