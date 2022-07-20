#!/usr/bin/env bash

open-in-terminal() {
  local cmd
  if command -v x-terminal-emulator > /dev/null
  then
    cmd=(x-terminal-emulator --working-directory="$(pwd)")
    [[ -z "$1" ]] || cmd+=(-e "$@")
  else
    cmd=(gnome-terminal)
    [[ -z "$1" ]] || cmd+=(-- "$@")
  fi

  "${cmd[@]}"
}

list_installed_packages() {
  if command -v "dpkg" >/dev/null 
  then
    dpkg -l | grep '^ii'
  elif command -v "dnf" > /dev/null
  then
    dnf list --installed
  fi
}

show_setup_dialog() {
  set -e
  HLINE=""
  for i in $(seq ${#SCRIPT_NAME} ) = = _ S e t u p _ _ = =
  do
    HLINE="${HLINE}="
  done
  echo "$HLINE"
  echo "== Setup ${SCRIPT_NAME} =="
  echo "$HLINE"
  echo ""
  installed_pkgs="$(list_installed_packages || return $?)"
  sudo_required=false
  
  DEPENDENCIES_APT+=(libsecret-tools)
  DEPENDENCIES_DNF+=(libsecret)
  if command -v "apt-get" > /dev/null
  then
    deps=("${DEPENDENCIES_APT[@]}")
    install_cmd=("apt-get" "install")
    simulate_cmd=("apt-get" "install" "-s")
  elif command -v "dnf" > /dev/null
  then
    deps=("${DEPENDENCIES_DNF[@]}")
    install_cmd=("dnf" "install" "-y" "--setopt=install_weak_deps=False")
    simulate_cmd=("dnf" "install" "-y" "--setopt=install_weak_deps=False" "--downloadonly")
  fi

  for pkg in "${deps[@]}"
  do
    echo "$installed_pkgs" | grep "\<$pkg[: ]" > /dev/null 2>&1 || sudo_required=true
    [[ "$sudo_required" == "false" ]] || break;
  done

  if [[ "$sudo_required" == 'true' ]]
  then
    echo "This script requires some packages to be installed, which in turn requires sudo privileges. Please enter your password when asked."
    echo "Here's what we're going to install:"
    echo ""
    sudo "${simulate_cmd[@]}" "${deps[@]}"
    echo ""
    CHOICE=""
    while [[ "${CHOICE,,}" != "y" ]]
    do
      read -t 3600 -r -n 1 -p "Apply these changes? [y/N]" CHOICE
      if [[ "${CHOICE,,}" == "n" ]]
      then
        echo "Aborting (User choice)..."
        sleep 3
        exit 1
      fi
    done
    echo ""
    sudo "${install_cmd[@]}" "${deps[@]}"
    echo ""
  fi

  echo "CONFIGURATION"
  echo "-------------"
  echo ""

  if [[ -n "${CONFIG_ITEMS[@]}" ]]
  then
    mkdir -p "$HOME/.config/nautilus-bridge-tools"
    CONFIG_PATH="$HOME/.config/nautilus-bridge-tools/.${SCRIPT_FILE_NAME?}.env"
    echo -n "" > "$CONFIG_PATH"
    while true;
    do
      echo "${CONFIG_ITEMS[1]}"
      read -r -t 3600 -p "${CONFIG_ITEMS[0]}: " "${CONFIG_ITEMS[0]}"
      echo "${CONFIG_ITEMS[0]}=\"${!CONFIG_ITEMS[0]}\"" >> "${CONFIG_PATH}"
  
      if [[ "${#CONFIG_ITEMS[@]}" -le 2 ]]
      then
        break
      fi
      CONFIG_ITEMS=("${CONFIG_ITEMS[@]:2}")
    done
  fi

  while true
  do
    echo "${SECRETS[1]}"
    read -r -t 3600 -p "${SECRETS[0]}: " VALUE
    echo "$VALUE" | secret-tool store --label "${SECRETS[0]}" service nautilus-bridge-tools ${SECRETS[2]} || {
      echo "Failed to store ${SECRETS[0]} in secret manager!" >&2
      sleep 3
      exit 2
    }
    if [[ "${#SECRETS[@]}" -le 3 ]]
    then
      break
    fi
    SECRETS=("${SECRETS[@]:3}")
  done

  echo ""
  echo "Congratulations! ${SCRIPT_NAME} is now ready to be used!"

  echo "Press [Enter] to exit"
  wait_for_enter
}

wait_for_enter() {
    while true
    do
        read -s -N 1 -t 1 key || true
        if [[ "$key" == $'\x0a' ]]
        then
            break;
        fi
    done
}

get_log_path() {
  local log_path="$(dirname "$BASH_SOURCE")/../logs/.${1:-other}.log"
  mkdir -p "$(dirname "$log_path")" || true
  touch "$log_path"
  echo "$(realpath "$log_path")"
}

