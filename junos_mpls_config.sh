#!/bin/bash

# Default values
LABEL_PROTOCOL="rsvp"
IGP_PROTOCOL="ospf"
ECMP_ENABLED="false"
HW_GROUP="vjr"
LS_GROUP="vjr_logical_systems"

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -l, --label-protocol {ldp|rsvp}    Label distribution protocol (default: rsvp)"
    echo "  -i, --igp-protocol {ospf|isis}     Interior gateway protocol (default: ospf)"
    echo "  -e, --ecmp {enable|disable}        Enable/disable ECMP (default: disable)"
    echo "  -g, --hw-group GROUP               Hardware group name (default: vjr)"
    echo "  -s, --ls-group GROUP               Logical systems group name (default: vjr_logical_systems)"
    echo "  -h, --help                         Display this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                 # Use all defaults"
    echo "  $0 -l ldp -i isis -e enable        # Use LDP, ISIS, and enable ECMP"
    echo "  $0 --label-protocol ldp --ecmp enable  # Use LDP with ECMP enabled"
    echo "  $0 -g juniper -s acx1100_logical_systems  # Use custom group names"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--label-protocol)
            if [[ "$2" == "ldp" || "$2" == "rsvp" ]]; then
                LABEL_PROTOCOL="$2"
                shift 2
            else
                echo "Error: Invalid label protocol '$2'. Use 'ldp' or 'rsvp'."
                exit 1
            fi
            ;;
        -i|--igp-protocol)
            if [[ "$2" == "ospf" || "$2" == "isis" ]]; then
                IGP_PROTOCOL="$2"
                shift 2
            else
                echo "Error: Invalid IGP protocol '$2'. Use 'ospf' or 'isis'."
                exit 1
            fi
            ;;
        -e|--ecmp)
            if [[ "$2" == "enable" || "$2" == "disable" ]]; then
                if [[ "$2" == "enable" ]]; then
                    ECMP_ENABLED="true"
                else
                    ECMP_ENABLED="false"
                fi
                shift 2
            else
                echo "Error: Invalid ECMP option '$2'. Use 'enable' or 'disable'."
                exit 1
            fi
            ;;
        -g|--hw-group)
            if [[ -n "$2" && "$2" != -* ]]; then
                HW_GROUP="$2"
                shift 2
            else
                echo "Error: Hardware group name required after $1"
                exit 1
            fi
            ;;
        -s|--ls-group)
            if [[ -n "$2" && "$2" != -* ]]; then
                LS_GROUP="$2"
                shift 2
            else
                echo "Error: Logical systems group name required after $1"
                exit 1
            fi
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Error: Unknown option '$1'"
            usage
            ;;
    esac
done

# Display configuration summary
printf "\n=== Configuration Summary ===\n"
printf "Label Protocol: %s\n" "$LABEL_PROTOCOL"
printf "IGP Protocol: %s\n" "$IGP_PROTOCOL"
printf "ECMP: %s\n" "$([ "$ECMP_ENABLED" == "true" ] && echo "enabled" || echo "disabled")"
printf "Hardware Group: %s\n" "$HW_GROUP"
printf "Logical Systems Group: %s\n" "$LS_GROUP"
printf "==============================\n\n"

# Initialize step counter
STEP=1

# Start configuration deployment
printf "\n%02d - Configure logical systems\n\n" $STEP
ansible-playbook playbooks/juniper/logical-systems.yml -e "group=$HW_GROUP"
((STEP++))

printf "\n%02d - Configure physical interfaces\n\n" $STEP
ansible-playbook playbooks/juniper/interfaces.yml -e "group=$HW_GROUP"
((STEP++))

printf "\n%02d - Configure LS's interfaces\n\n" $STEP
ansible-playbook playbooks/juniper/interfaces.yml -e "group=$LS_GROUP" --forks 1
((STEP++))

printf "\n%02d - Configure LS's common configuration\n\n" $STEP
ansible-playbook playbooks/juniper/common.yml -e "group=$LS_GROUP" --forks 1
((STEP++))

# Conditionally configure ECMP
if [[ "$ECMP_ENABLED" == "true" ]]; then
    printf "\n%02d - Configure LS's ECMP\n\n" $STEP
    ansible-playbook playbooks/juniper/enable_ecmp.yml -e "group=$LS_GROUP" --forks 1
    ((STEP++))
else
    printf "\n-- - Skipping ECMP configuration (disabled)\n\n"
fi

# Configure selected IGP protocol
if [[ "$IGP_PROTOCOL" == "isis" ]]; then
    printf "\n%02d - Configure LS's ISIS\n\n" $STEP
    ansible-playbook playbooks/juniper/isis.yml -e "group=$LS_GROUP" --forks 1
else
    printf "\n%02d - Configure LS's OSPF\n\n" $STEP
    ansible-playbook playbooks/juniper/ospf.yml -e "group=$LS_GROUP" --forks 1
fi
((STEP++))

printf "\n%02d - Configure LS's MPLS\n\n" $STEP
ansible-playbook playbooks/juniper/mpls.yml -e "group=$LS_GROUP" --forks 1
((STEP++))

# Configure selected label distribution protocol
if [[ "$LABEL_PROTOCOL" == "ldp" ]]; then
    printf "\n%02d - Configure LS's LDP\n\n" $STEP
    ansible-playbook playbooks/juniper/ldp.yml -e "group=$LS_GROUP" --forks 1
else
    printf "\n%02d - Configure LS's RSVP\n\n" $STEP
    ansible-playbook playbooks/juniper/rsvp.yml -e "group=$LS_GROUP" --forks 1
fi
((STEP++))

printf "\n%02d - Configure LS's iBGP\n\n" $STEP
ansible-playbook playbooks/juniper/ibgp.yml -e "group=$LS_GROUP" --forks 1
((STEP++))

printf "\n%02d - Configure LS's VRF\n\n" $STEP
ansible-playbook playbooks/juniper/vrf.yml -e "group=$LS_GROUP" --forks 1

printf "\nDONE!\n\n"
