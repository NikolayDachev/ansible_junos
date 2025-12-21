## Init Ansible for juniper 

### To init everything
`./setup_ansible.sh init`

### Create ansible direcotries and files (if missed)
`./setup_ansible.sh init_ansible`

### Create ansible python venv
`./setup_ansible.sh init_venv`

### Install Ansible collections
`./setup_ansible.sh collections`

### Ansible vault passowrd
`cat .local/.vaultpwd`

### Start Ansible venv
`source .local/venv/bin/activate`

### setup_ansible.sh
```
Usage:
    init         : Initialize everything.
    init_ansible : Initialize Ansible files and folders.
    init_venv    : Initialize Python virtual environment.
           -s    : use system site packages.
           -f    : use pip freezed requirements file (setup_ansible/requirements.venv.freeze).
    update_venv  : Update 'setup_ansible/requirements.venv' and 'setup_ansible/requirements.venv.freeze'.
    collections  : Install Ansible collections from file.
           -u    : update existing collections.
```

### Install junos collection 
For more details please check [Jiniper device ansible collection](https://galaxy.ansible.com/ui/repo/published/juniper/device/)  
`ansible-galaxy collection install juniper.device`

### Patch junos collection 'LooseVersion' is not used in python 3.13+
```
sed -i \
  -e 's/from looseversion import LooseVersion/from packaging.version import Version as LooseVersion/' \
  -e 's/from distutils.version import LooseVersion/from packaging.version import Version as LooseVersion/' \
  collections/ansible_collections/juniper/device/plugins/module_utils/configuration.py
```

## Submodules

For `jvr` please use containerlab under `submodules/containerlab/labs/vjrouter-rare-ce/`  

## Deploymnet example 

### Init ansible venv
```
./setup_ansible.sh init
```
### Udate submodule and deploy container lab
```
git submodule update --init --recursive
cd submodules/containerlab/labs/vjrouter-rare-ce/
sudo containerlab deploy
sudo containerlab inspect
cd ../../../../
```
### Run script with ansible playbooks 
```
 source .local/venv/bin/activate
 echo '1q2w3e' > .local/.vaultpwd
./junos_mpls_config.sh
```
