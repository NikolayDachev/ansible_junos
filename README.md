## Init Ansible for juniper 

### Init ansible direcotries and files (if missed)
`./setup_ansible.sh init_ansible`

### Init ansible python venv
`./setup_ansible.sh init_venv`

### Ansible vault passowrd
`cat .local/.vaultpwd`

### Start Ansible venv
`source .local/venv/bin/activate`

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

