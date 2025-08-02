ansible-playbook playbooks/juniper/interfaces.yml  -e 'group=juniper'
ansible-playbook playbooks/juniper/logical-systems.yml
ansible-playbook playbooks/juniper/interfaces.yml  -e 'group=acx1100_logical_systems' --forks 1
ansible-playbook playbooks/juniper/common.yml  -e 'group=acx1100_logical_systems' --forks 1
ansible-playbook playbooks/juniper/enable_ecmp.yml  -e 'group=acx1100_logical_systems' --forks 1
ansible-playbook playbooks/juniper/isis.yml  -e 'group=acx1100_logical_systems' --forks 1
ansible-playbook playbooks/juniper/mpls.yml  -e 'group=acx1100_logical_systems' --forks 1
ansible-playbook playbooks/juniper/ldp.yml  -e 'group=acx1100_logical_systems' --forks 1
ansible-playbook playbooks/juniper/ibgp.yml  -e 'group=acx1100_logical_systems' --forks 1
nsible-playbook playbooks/juniper/l3vpn.yml  -e 'group=acx1100_logical_systems' --forks 1
