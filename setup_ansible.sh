#!/bin/bash
# MIT License
# Copyright (c) 2025 Nikolay Dachev

# DEFAULTS
ver="1.1.1"
py="python3.13"
pip="pip3.13"
vaultpwd='1q2w3e'
localansible=".local"
requirements="setup_ansible"

# Paths / files
venv_dir="$localansible/venv"
venv_file="$requirements/requirements.venv"          # names only
venv_freeze_file="${venv_file}.freeze"              # pinned versions (pip freeze)
os_pkg_file="$requirements/requirements.pkg"
ansible_collections_file="$requirements/requirements.collections"

msg_prefix="SETUP ANSIBLE:"

install_os_pkgs_from_file() {
    echo "$msg_prefix --- INSTALL OS PACKAGES FROM FILE ---"

    [[ -f "$os_pkg_file" ]] || {
        echo "$msg_prefix Error: Package file not found: $os_pkg_file" >&2
        return 1
    }

    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^# ]] && continue

        if ! rpm -q "$pkg" &>/dev/null; then
            echo "$msg_prefix: Installing OS $pkg"
            sudo zypper -n install "$pkg"
        else
            echo "$msg_prefix Info: $pkg OS pkg is already installed"
        fi
    done < "$os_pkg_file"
}

init_ansible() {
    echo "$msg_prefix --- INIT ---"
    for i in inventory/group_vars/all \
             inventory/host_vars \
             playbooks \
             collections/ansible_collections/ \
             files \
             "$localansible/.ansible/tmp"
    do
        if [ ! -d "$PWD/$i" ]; then
            echo "$msg_prefix create folder: $PWD/$i"
            mkdir -p "$PWD/$i"
        fi
    done

    if [ ! -f "$PWD/inventory/inventory.yml" ]; then
        echo "$msg_prefix create $PWD/inventory/inventory.yml"
        touch "$PWD/inventory/inventory.yml"
    fi

    if [ ! -f "$PWD/ansible.cfg" ]; then
       echo "$msg_prefix create $PWD/ansible.cfg"
       cat > "$PWD/ansible.cfg" << EOF
[defaults]
inventory  =            ./inventory
collections_paths =     ./collections
remote_tmp =            \$HOME/.ansible/tmp
local_tmp  =            $localansible/.ansible/tmp
vault_password_file =   $localansible/.vaultpwd
become =                True
host_key_checking =     False
deprecation_warnings =  True
ansible_network_os =    linux
display_skipped_hosts = true
result_format =         yaml

[ssh_connection]
ssh_args = -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
EOF
    fi

    if [ ! -f "$PWD/.gitignore" ]; then
       echo "$msg_prefix create $PWD/.gitignore"
       cat > "$PWD/.gitignore" << EOF
$localansible/*
!$venv_file*
!$venv_freeze_file*
EOF
    fi

    if [ ! -f "$localansible/.vaultpwd" ]; then
        echo "$msg_prefix create $PWD/$localansible/.vaultpwd"
        mkdir -p "$PWD/$localansible"
        echo "$vaultpwd" > "$PWD/$localansible/.vaultpwd"
        chmod 400 "$PWD/$localansible/.vaultpwd"
        echo ""
        echo "$msg_prefix: Please check $localansible/.vaultpwd for the default vault password."
    fi

    echo ""
    echo "$msg_prefix: Ansible environment initialization complete!"
}

new_venv() {
    echo "$msg_prefix --- NEW VENV ---"

    local use_freeze=false
    local system_site=false

    # parse flags (can be anywhere)
    for arg in "$@"; do
        case "$arg" in
            -f) use_freeze=true ;;
            -s) system_site=true ;;
        esac
    done

    local req_file="$venv_file"
    if $use_freeze && [ -f "$venv_freeze_file" ]; then
        req_file="$venv_freeze_file"
        echo "$msg_prefix: Using freezed requirements file: $req_file"
    fi

    local venv_args=()
    if $system_site; then
        venv_args+=(--system-site-packages)
        echo "$msg_prefix: Allow system site packages in venv"
    fi

    if [ -d "$venv_dir" ]; then
        echo "$msg_prefix ERROR: '$venv_dir' exists. Please delete it first!"
        exit 1
    fi

    echo "$msg_prefix create $venv_dir"
    "$py" -m venv "${venv_args[@]}" "$venv_dir"

    echo "$msg_prefix source $venv_dir/bin/activate"
    # shellcheck disable=SC1090
    source "$venv_dir/bin/activate"

    echo "$msg_prefix update pip"
    "$pip" install --upgrade pip
    "$pip" install --upgrade wheel

    if [ -f "$req_file" ]; then
        echo "$msg_prefix $pip install -r $req_file"
        "$pip" install -r "$req_file"
    else
        echo "$msg_prefix $req_file not found!"
        echo "$msg_prefix install ansible"
        "$pip" install ansible
        ansible --version
        echo "$msg_prefix create $venv_file and $venv_freeze_file"
        "$pip" list --format=freeze | cut -d= -f1 > "$venv_file"
        "$pip" freeze > "$venv_freeze_file"
    fi

    echo ""
    echo "$msg_prefix: Virtual environment '$venv_dir' has been created."
}

check_venv() {
    if [ ! -d "$venv_dir" ]; then
        echo "$msg_prefix ERROR: '$venv_dir' does not exist!"
        echo "$msg_prefix Please create a new '$venv_dir' using: ./setup_ansible.sh init_venv"
        exit 1
    fi
}

update_venv_req() {
    echo "$msg_prefix --- UPDATE $venv_file / $venv_freeze_file ---"
    check_venv

    if [ -f "$venv_freeze_file" ]; then
      echo "$msg_prefix create $venv_freeze_file.bck"
      cp "$venv_freeze_file" "$venv_freeze_file.bck"
    fi

    if [ -f "$venv_file" ]; then
      echo "$msg_prefix create $venv_file.bck"
      cp "$venv_file" "$venv_file.bck"
    fi

    echo "$msg_prefix source $venv_dir/bin/activate"
    # shellcheck disable=SC1090
    source "$venv_dir/bin/activate"

    echo "$msg_prefix update $venv_file (names only)"
    "$pip" list --format=freeze | cut -d= -f1 > "$venv_file"

    echo "$msg_prefix update $venv_freeze_file (versions)"
    "$pip" freeze > "$venv_freeze_file"

    echo ""
    echo "$msg_prefix requirements updated:"
    echo "$msg_prefix - $venv_file"
    echo "$msg_prefix - $venv_freeze_file"
    echo "$msg_prefix please push these files in git"
}

ansible_collections() {
    echo "$msg_prefix --- INSTALL ANSIBLE COLLECTIONS ---"
    check_venv

    local update_collection=false

    # parse flags (can be anywhere)
    for arg in "$@"; do
        case "$arg" in
            -u) update_collection=true ;;
        esac
    done

    if [ ! -f "$ansible_collections_file" ]; then
        echo "$msg_prefix SKIP: '$ansible_collections_file' does not exist!"
        return 1
    fi

    echo "$msg_prefix INFO: $ansible_collections_file collections file found."

    if $update_collection; then
        ansible_galaxy="ansible-galaxy collection install --upgrade"
        echo "$msg_prefix: Update existing collections from $ansible_collections_file"
    else
        ansible_galaxy="ansible-galaxy collection install"
        echo "$msg_prefix: Install collections from $ansible_collections_file"
    fi

    echo "$msg_prefix source $venv_dir/bin/activate"
    source "$venv_dir/bin/activate"
    $ansible_galaxy -r "$ansible_collections_file"
    deactivate
}

# Check for python3 venv module and pip
"$py" -m venv -h &>/dev/null
if [ $? -ne 0 ]; then
    echo "$msg_prefix Error: The Python 3 venv module is missing. Please install it manually."
    exit 1
fi

"$pip" -h &>/dev/null
if [ $? -ne 0 ]; then
    echo "$msg_prefix Error: The Python 3 pip package is missing. Please install it manually."
    exit 1
fi

venv_msg(){
    echo "$msg_prefix To activate the virtual environment:   source $venv_dir/bin/activate"
    echo "$msg_prefix To deactivate the virtual environment: deactivate"
}

case "${1:-}" in
    init)
        echo ""
        init_ansible
        echo ""
        install_os_pkgs_from_file
        echo ""
        shift
        new_venv "$@"
        echo ""
        update_venv_req
        echo ""
        shift
        ansible_collections "$@"
    ;;
    init_ansible)
        echo ""
        init_ansible
    ;;
    init_venv)
        echo ""
        install_os_pkgs_from_file
        echo ""
        shift
        new_venv "$@"
        update_venv_req
    ;;
    update_venv)
        echo ""
        update_venv_req
    ;;
    collections)
        echo ""
        shift
        ansible_collections "$@"
    ;;
    *)
        cat << EOF
$msg_prefix v$ver
Usage:
    init         : Initialize everything. 
    init_ansible : Initialize Ansible files and folders.
    init_venv    : Initialize Python virtual environment.
           -s    : use system site packages.
           -f    : use pip freezed requirements file ($venv_freeze_file).
    update_venv  : Update '$venv_file' and '$venv_freeze_file'.
    collections  : Install Ansible collections from file.
           -u    : update existing collections.
EOF
    ;;
esac

echo ""
venv_msg
echo ""
