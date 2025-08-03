printf "\n01 - Configure physical interfaces\n\n"
ansible-playbook playbooks/juniper/interfaces.yml  -e 'group=juniper'

printf "\n02 - Configure logical systems\n\n"
ansible-playbook playbooks/juniper/logical-systems.yml

printf "\n03 - Configure LS's interfaces\n\n"
ansible-playbook playbooks/juniper/interfaces.yml  -e 'group=acx1100_logical_systems' --forks 1

printf "\n04 - Configure LS's common configuration\n\n"
ansible-playbook playbooks/juniper/common.yml  -e 'group=acx1100_logical_systems' --forks 1

#printf "\n05 - Configure LS's ECMP\n\n"
#ansible-playbook playbooks/juniper/enable_ecmp.yml  -e 'group=acx1100_logical_systems' --forks 1

printf "\n06 - Configure LS's ISIS\n\n"
ansible-playbook playbooks/juniper/isis.yml  -e 'group=acx1100_logical_systems' --forks 1

printf "\n07 - Configure LS's MPLS\n\n"
ansible-playbook playbooks/juniper/mpls.yml  -e 'group=acx1100_logical_systems' --forks 1

printf "\n08 - Configure LS's LDP\n\n"
ansible-playbook playbooks/juniper/ldp.yml  -e 'group=acx1100_logical_systems' --forks 1

printf "\n09 - Configure LS's iBGP\n\n"
ansible-playbook playbooks/juniper/ibgp.yml  -e 'group=acx1100_logical_systems' --forks 1

printf "\n10 - Configure LS's L3VPN\n\n"
ansible-playbook playbooks/juniper/l3vpn.yml  -e 'group=acx1100_logical_systems' --forks 1

printf "\nDONE!\n\n"
