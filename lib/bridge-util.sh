#!/usr/bin/env bash

show_setup_dialog() {
  HLINE=""
  for i in $(seq ${#SCRIPT_NAME} ) = = _ S e t u p _ _ = =
  do
    HLINE="${HLINE}="
  done
  echo "$HLINE"
  echo "== Setup ${SCRIPT_NAME} =="
  echo "$HLINE"
  echo ""
  installed_pkgs="$(dpkg -l | grep '^ii')"
  sudo_required=false
  for pkg in "${APT_DEPENDENCIES[@]}" libsecret-tools
  do
    echo "$installed_pkgs" | grep "$pkg" > /dev/null 2>&1 || sudo_required=true
  done
  if [[ "$sudo_required" == 'true' ]]
  then
    echo "This scripts requires some apt packages to be installed, which in turn requires sudo privileges. Please enter your password when asked."
    echo "Here's what we're going to install:"
    echo ""
    apt-get install -s "${APT_DEPENDENCIES[@]}"
    echo ""
    CHOICE=""
    while [[ "${CHOICE,,}" != "y" ]]
    do
      read -t 3600 -r -n 1 -p "Continue? [y/N]" CHOICE
      if [[ "${CHOICE,,}" == "n" ]]
      then
        echo "Aborting (User choice)..."
        sleep 3
        exit 1
      fi
    done
    echo ""
    sudo apt-get install -y "${APT_DEPENDENCIES[@]}"
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

if [[ "$1" == "--setup" ]]
then
  show_setup_dialog
fi
