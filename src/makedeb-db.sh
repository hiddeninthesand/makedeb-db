#!/usr/bin/env bash
set -e

## Variables ##
database_dir="./"

## Functions ##
arg_check() {
  while true; do
    case "${1}" in
      "" | "-h" | "--help")                      help; exit 0 ;;
      --package | -P)                         query="package"; shift 1; pkg="${@}"; break ;;
      --general | -G)                         query="general"; shift 1; pkg="${@}"; break ;;
      *)                                         echo "Invalid option '${1}'"; exit 1 ;;
    esac
  done
}

help() {
  echo "makedeb-db - CLI tool for interacting with the makedeb database"
  echo "Usage: makedeb-db [command] [package(s)]"
  echo
  echo "Commands:"
  echo "  --package, -P - search for a package-specific dependency. This command only takes one package as its argument."
  echo "  --general, -G - search for general dependencies. This command accepts any number of packages."
  echo
  echo "Report bugs at https://github.com/hwittenborn/makedeb-db"
}

query_check() {
  if [[ "${query}" == "package" ]] && [[ $(echo "${pkg}" | awk '{print $2}') != "" ]]; then
    echo "More than one package was specified"
    exit 1

  elif [[ "${pkg}" == "" ]]; then
    echo "No package was specified"

  else
    run_"${query}"
  fi
}

run_package() {
  pkginfo=$(cat packages.db | sed 's|$|;|g' | xargs | grep -o "${pkg}() {.*}" | sed 's|;|\n|g')
  source <(echo "${pkginfo}")
  if [[ $(type -t "${pkg}") == "function" ]]; then
    "${pkg}"
  else
    exit 0
  fi

  variables="add_depends add_optdepends add_conflicts add_makedepends add_checkdepends remove_depends remove_optdepends remove_conflicts remove_makedepends remove_checkdepends"
  for i in ${variables}; do
    if [[ $(eval echo \${${i}}) != "" ]]; then
      output+=" \"${i}\": \"$(eval echo \${${i}})\","
    fi
  done

  new_output=$(echo ${output} | rev | sed 's|,||' | rev)
  printf "{ ${new_output} }\n"
}

run_general() {
  # 1. Read the database
  # 2. Add semicolons(;) to end of each line
  # 3. Run 'xargs' to make one line
  # 4. Remove Everything up to beginning of general dependencies listing
  # 5. Replace semicolons(;) with newlines
  # 6. Add "export" to beggining of each line
  db_info=$(cat packages.db | sed 's|$|;|g' | xargs | sed 's|[^:].*# General dependencies; ||' | sed 's|;|\n|g')

  # Convert package arguments from arg_check() into format for 'grep'
  new_pkg=$(echo "${pkg}" | sed 's| |\n|g' | sed 's|$|=;|g' | xargs | sed 's|;| |g' | sed 's|  | |g' | sed 's| |\||g' | rev | sed 's|\|||' | rev)

  # Get packages to source, and then source them
  pkg_info=$(echo "${db_info}" | grep -E "${new_pkg}")

  # Generate json
  pkgnum="1"
  for i in ${pkg_info}; do
    output+="  \"$(echo ${i} | awk -F '=' '{print $1}')\": \"$(echo ${i} | awk -F '=' '{print $2}')\","
    pkgnum=$(( ${pkgnum} + 1))
  done

  if [[ "${output}" != "" ]]; then
    new_output=$(echo ${output} | rev | sed 's|,||' | rev)
    printf "{ ${new_output} }\n"
  fi
}
## Begin script ##
arg_check "${@}"
query_check
