# Expected reuslts for juniper mpls l3vpn/l2vpn 

## Customer A L3VPN

### Juniper LPE01
```
admin@vjr> set cli logical-system lpe01    
Logical system: lpe01

admin@vjr:lpe01> show route table bgp.l3vpn.0    

bgp.l3vpn.0: 2 destinations, 2 routes (2 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

192.168.102.2:1:10.255.102.0/24                
                   *[BGP/170] 01:11:31, localpref 100, from 10.0.0.2
                      AS path: 65102 I, validation-state: unverified
                    >  to 10.0.12.2 via lt-0/0/10.1, label-switched-path lsp_to_lpe02
192.168.102.2:1:192.168.102.0/30                
                   *[BGP/170] 01:11:32, localpref 100, from 10.0.0.2
                      AS path: I, validation-state: unverified
                    >  to 10.0.12.2 via lt-0/0/10.1, label-switched-path lsp_to_lpe02

admin@vjr:lpe01> show route table  ce-A_l3vpn.inet.0                                                                                                                                                                                        

ce-A_l3vpn.inet.0: 5 destinations, 6 routes (5 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.255.101.0/24    *[BGP/170] 01:12:01, localpref 100
                      AS path: 65101 I, validation-state: unverified
                    >  to 192.168.101.2 via ge-0/0/1.0
10.255.102.0/24    *[BGP/170] 01:11:39, localpref 100, from 10.0.0.2
                      AS path: 65102 I, validation-state: unverified
                    >  to 10.0.12.2 via lt-0/0/10.1, label-switched-path lsp_to_lpe02
192.168.101.0/30   *[Direct/0] 01:12:03
                    >  via ge-0/0/1.0
                    [BGP/170] 01:12:01, localpref 100
                      AS path: 65101 I, validation-state: unverified
                    >  to 192.168.101.2 via ge-0/0/1.0
192.168.101.1/32   *[Local/0] 01:12:03
                       Local via ge-0/0/1.0
192.168.102.0/30   *[BGP/170] 01:11:40, localpref 100, from 10.0.0.2
                      AS path: I, validation-state: unverified
                    >  to 10.0.12.2 via lt-0/0/10.1, label-switched-path lsp_to_lpe02
```
### Juniper LPE02
```
admin@vjr:lpe01> set cli logical-system lpe02 
Logical system: lpe02

admin@vjr:lpe02> show route table bgp.l3vpn.0          

bgp.l3vpn.0: 2 destinations, 2 routes (2 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

192.168.101.2:1:10.255.101.0/24                
                   *[BGP/170] 01:11:52, localpref 100, from 10.0.0.1
                      AS path: 65101 I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01
192.168.101.2:1:192.168.101.0/30                
                   *[BGP/170] 01:11:52, localpref 100, from 10.0.0.1
                      AS path: I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01

admin@vjr:lpe02> show route table  ce-A_l3vpn.inet.0   

ce-A_l3vpn.inet.0: 5 destinations, 6 routes (5 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.255.101.0/24    *[BGP/170] 01:11:57, localpref 100, from 10.0.0.1
                      AS path: 65101 I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01
10.255.102.0/24    *[BGP/170] 01:11:55, localpref 100
                      AS path: 65102 I, validation-state: unverified
                    >  to 192.168.102.2 via ge-0/0/2.0
192.168.101.0/30   *[BGP/170] 01:11:57, localpref 100, from 10.0.0.1
                      AS path: I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01
192.168.102.0/30   *[Direct/0] 01:11:57
                    >  via ge-0/0/2.0
                    [BGP/170] 01:11:55, localpref 100
                      AS path: 65102 I, validation-state: unverified
                    >  to 192.168.102.2 via ge-0/0/2.0
192.168.102.1/32   *[Local/0] 01:11:57
                       Local via ge-0/0/2.0

```

### ce-101 routing table
```
vjr-ce101#show ipv4 route vjr                                                                                                                                                                                                                
typ  prefix            metric  iface      hop            time
C    10.255.101.0/24   0/0     loopback0  null           00:54:17
LOC  10.255.101.1/32   0/1     loopback0  null           00:54:17
B    10.255.102.0/24   20/0    ethernet1  192.168.101.1  00:37:00
C    192.168.101.0/30  0/0     ethernet1  null           00:54:17
LOC  192.168.101.2/32  0/1     ethernet1  null           00:54:17
B    192.168.102.0/30  20/0    ethernet1  192.168.101.1  00:37:01
```

### bgp details to ce-102
```

vjr-ce101#show ipv4 bgp 65101 summary                                                                                                                                                                                                        
neighbor       as     state  learn  sent  uptime
192.168.101.1  65000  up     2      4     00:45:26

vjr-ce101#show ipv4 route vjr 10.255.102.0/24                                                                                                                                                                                                
id    category              value
      vrf                   vjr:4
      ipver                 4
      rd                    0:0
      original rd           0:0
      prefix                10.255.102.0/24
      prefix network        10.255.102.0
      prefix broadcast      10.255.102.255
      prefix wildcard       ::ff
      prefix netmask        ffff:ffff:ffff:ffff:ffff:ffff:ffff:ff00
      nlri                  n/a
      alternates            1
      alternate #0          candidate=true best=true
alt0  type                  bgp4 65101
alt0  source                192.168.101.1
alt0  validity roa          nothing
alt0  validity aspa         nothing
alt0  segrout index         0
alt0  segrout old base      0
alt0  segrout base          0
alt0  segrout size          0
alt0  segrout offset        0
alt0  segrout prefix        null
alt0  bier index            0
alt0  bier subdomain        0
alt0  bier old base         0
alt0  bier base             0
alt0  bier range            0
alt0  bier size             0-32
alt0  updated               2025-08-18 08:23:27 (00:45:16 ago)
alt0  version               38
alt0  distance              20
alt0  metric                0
alt0  ident                 0
alt0  hops                  0
alt0  interface             ethernet1
alt0  table                 null
alt0  nexthop               192.168.101.1
alt0  original nexthop      null
alt0  route tag             0
alt0  origin type           0
alt0  local preference      100
alt0  accumulated igp       0
alt0  bandwidth             0
alt0  to customer asnum     0
alt0  to customer asnam     as0
alt0  attribute asnum       0
alt0  attribute asnam       as0
alt0  attribute value       n/a
alt0  nsh chain value       n/a
alt0  domain path value     n/a
alt0  bfd discr value       n/a
alt0  hop capability value  n/a
alt0  tunnel type           0
alt0  tunnel value          n/a
alt0  link state            n/a
alt0  pmsi type             0
alt0  pmsi label*16         0
alt0  pmsi tunnel           n/a
alt0  evpn label*16         0
alt0  entropy label         n/a
alt0  atomic aggregator     false
alt0  aggregator asnum      0
alt0  aggregator asnam      as0
alt0  aggregator router     null
alt0  connector router      null
alt0  distinguish pe        null
alt0  distinguish label     0
alt0  path limit            0
alt0  path asnum            0
alt0  path asnam            as0
alt0  originator            null
alt0  cluster list
alt0  aspath                65000 65102
alt0  asname                as65000 as65102
alt0  asinfo                as65000 as65102
alt0  asmixed               65000-as65000 65102-as65102
alt0  path length           2
alt0  standard community
alt0  extended community    2:65000:1
alt0  large community
alt0  internal source       4
alt0  local label           null
alt0  remote label
      counter               tx=5816(52) rx=0(0) drp=0(0)
      lastio                input never ago, output 00:04:54 ago, drop never ago
      hardware counter      null

```


### ping remote site A ce-102
```
vjr-ce101#ping 10.255.102.1 vrf vjr                                                                                                                                                                                                          
pinging 10.255.102.1, src=null, vrf=vjr, via=null, cnt=5, len=64, df=false, tim=1000, gap=0, ttl=255, tos=0, sgt=0, flow=0, fill=0, alrt=-1, sweep=false, multi=false
!!!!!
result=100.0%, recv/sent/lost/err=5/5/0/0, took 23, min/avg/max/dev rtt=0/1.0/2/0.4, ttl 252/252/252/0.0, tos 0/0.0/0/0.0
```

### SSH to remote site A ce-102
```
vjr-ce101#ssh 10.255.102.1 vrf vjr                                                                                                                                                                                                           
connecting to 10.255.102.1 22 ok!
username: rare
password: 
securing connection ok!

escape character is ascii0x03.

welcome
line ready
vjr-ce102#exit                                                                 
see you later

connection closed
vjr-ce101#                                                                                                                                                                                                                                   
```

## Customer B L2VPN

### Juniper LPE01
```
admin@vjr:lpe01> show l2vpn connections 
Layer-2 VPN connections:

Legend for connection status (St)   
EI -- encapsulation invalid      NC -- interface encapsulation not CCC/TCC/VPLS
EM -- encapsulation mismatch     WE -- interface and instance encaps not same
VC-Dn -- Virtual circuit down    NP -- interface hardware not present 
CM -- control-word mismatch      -> -- only outbound connection is up
CN -- circuit not provisioned    <- -- only inbound connection is up
OR -- out of range               Up -- operational
OL -- no outgoing label          Dn -- down                      
LD -- local site signaled down   CF -- call admission control failure      
RD -- remote site signaled down  SC -- local and remote site ID collision
LN -- local site not designated  LM -- local site ID not minimum designated
RN -- remote site not designated RM -- remote site ID not minimum designated
XX -- unknown connection status  IL -- no incoming label
MM -- MTU mismatch               MI -- Mesh-Group ID not available
BK -- Backup connection	         ST -- Standby connection
PF -- Profile parse failure      PB -- Profile busy
RS -- remote site standby	 SN -- Static Neighbor
LB -- Local site not best-site   RB -- Remote site not best-site
VM -- VLAN ID mismatch           HS -- Hot-standby Connection

Legend for interface status 
Up -- operational           
Dn -- down

Instance: ce-B_l2vpn
Edge protection: Not-Primary
  Local site: ce-B (1)
    connection-site           Type  St     Time last up          # Up trans
    2                         rmt   Up     Aug 18 06:23:23 2025           1
      Remote PE: 10.0.0.2, Negotiated control-word: Yes (Null)
      Incoming label: 800001, Outgoing label: 800000
      Local interface: ge-0/0/3.0, Status: Up, Encapsulation: ETHERNET
      Flow Label Transmit: No, Flow Label Receive: No

admin@vjr:lpe01> show route table bgp.l2vpn.0 

bgp.l2vpn.0: 1 destinations, 1 routes (1 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.0.0.2:2:2:1/96                
                   *[BGP/170] 01:31:43, localpref 100, from 10.0.0.2
                      AS path: I, validation-state: unverified
                    >  to 10.0.12.2 via lt-0/0/10.1, label-switched-path lsp_to_lpe02

admin@vjr:lpe01> show route table ce-B_l2vpn.l2vpn.0 

ce-B_l2vpn.l2vpn.0: 2 destinations, 2 routes (2 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.0.0.1:2:1:1/96                
                   *[L2VPN/170/-101] 01:32:25, metric2 1
                       Indirect
10.0.0.2:2:2:1/96                
                   *[BGP/170] 01:32:04, localpref 100, from 10.0.0.2
                      AS path: I, validation-state: unverified
                    >  to 10.0.12.2 via lt-0/0/10.1, label-switched-path lsp_to_lpe02

admin@vjr:lpe01> show route table ce-B_l2vpn.l2id.0     

ce-B_l2vpn.l2id.0: 2 destinations, 3 routes (2 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

1/32                
                   *[L2VPN/170/-101] 01:32:48, metric2 1
                       Indirect
                    [L2VPN/175] 01:32:27
                    >  via ge-0/0/3.0, Pop       Offset: 4
2/32                
                   *[BGP/170] 01:32:27, localpref 100, from 10.0.0.2
                      AS path: I, validation-state: unverified
                    >  to 10.0.12.2 via lt-0/0/10.1, label-switched-path lsp_to_lpe02
```

### Juniper LPE02
```
admin@vjr:lpe01> set cli logical-system lpe02 
Logical system: lpe02

admin@vjr:lpe02> show l2vpn connections                 
Layer-2 VPN connections:

Legend for connection status (St)   
EI -- encapsulation invalid      NC -- interface encapsulation not CCC/TCC/VPLS
EM -- encapsulation mismatch     WE -- interface and instance encaps not same
VC-Dn -- Virtual circuit down    NP -- interface hardware not present 
CM -- control-word mismatch      -> -- only outbound connection is up
CN -- circuit not provisioned    <- -- only inbound connection is up
OR -- out of range               Up -- operational
OL -- no outgoing label          Dn -- down                      
LD -- local site signaled down   CF -- call admission control failure      
RD -- remote site signaled down  SC -- local and remote site ID collision
LN -- local site not designated  LM -- local site ID not minimum designated
RN -- remote site not designated RM -- remote site ID not minimum designated
XX -- unknown connection status  IL -- no incoming label
MM -- MTU mismatch               MI -- Mesh-Group ID not available
BK -- Backup connection	         ST -- Standby connection
PF -- Profile parse failure      PB -- Profile busy
RS -- remote site standby	 SN -- Static Neighbor
LB -- Local site not best-site   RB -- Remote site not best-site
VM -- VLAN ID mismatch           HS -- Hot-standby Connection

Legend for interface status 
Up -- operational           
Dn -- down

Instance: ce-B_l2vpn
Edge protection: Not-Primary
  Local site: ce-B (2)
    connection-site           Type  St     Time last up          # Up trans
    1                         rmt   Up     Aug 18 06:23:23 2025           1
      Remote PE: 10.0.0.1, Negotiated control-word: Yes (Null)
      Incoming label: 800000, Outgoing label: 800001
      Local interface: ge-0/0/4.0, Status: Up, Encapsulation: ETHERNET
      Flow Label Transmit: No, Flow Label Receive: No

admin@vjr:lpe02> show route table bgp.l2vpn.0           

bgp.l2vpn.0: 1 destinations, 1 routes (1 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.0.0.1:2:1:1/96                
                   *[BGP/170] 01:32:41, localpref 100, from 10.0.0.1
                      AS path: I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01

admin@vjr:lpe02> show route table ce-B_l2vpn.l2vpn.0 

ce-B_l2vpn.l2vpn.0: 2 destinations, 2 routes (2 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.0.0.1:2:1:1/96                
                   *[BGP/170] 01:32:52, localpref 100, from 10.0.0.1
                      AS path: I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01
10.0.0.2:2:2:1/96                
                   *[L2VPN/170/-101] 01:32:52, metric2 1
                       Indirect

admin@vjr:lpe02> show route table ce-B_l2vpn.l2vpn.0    

ce-B_l2vpn.l2vpn.0: 2 destinations, 2 routes (2 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

10.0.0.1:2:1:1/96                
                   *[BGP/170] 01:32:54, localpref 100, from 10.0.0.1
                      AS path: I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01
10.0.0.2:2:2:1/96                
                   *[L2VPN/170/-101] 01:32:54, metric2 1
                       Indirect

admin@vjr:lpe02> show route table ce-B_l2vpn.l2id.0 

ce-B_l2vpn.l2id.0: 2 destinations, 3 routes (2 active, 0 holddown, 0 hidden)
+ = Active Route, - = Last Active, * = Both

1/32                
                   *[BGP/170] 01:33:15, localpref 100, from 10.0.0.1
                      AS path: I, validation-state: unverified
                    >  to 10.0.34.1 via lt-0/0/10.4, label-switched-path lsp_to_lpe01
2/32                
                   *[L2VPN/170/-101] 01:33:15, metric2 1
                       Indirect
                    [L2VPN/175] 01:33:15
                    >  via ge-0/0/4.0, Pop       Offset: 4
```

### ce-201 dhcp server
```
vjr-ce201#show dhcp4 vjr                                                                                                                                                                                                                     
mac             ip              last
aac1.aba3.a098  192.168.200.11  00:50:28
```

### ping remote site B ce-202
```
vjr-ce201#ping 192.168.200.11 vrf vjr                                                                                                                                                                                                        
pinging 192.168.200.11, src=null, vrf=vjr, via=null, cnt=5, len=64, df=false, tim=1000, gap=0, ttl=255, tos=0, sgt=0, flow=0, fill=0, alrt=-1, sweep=false, multi=false
!!!!!
result=100.0%, recv/sent/lost/err=5/5/0/0, took 19, min/avg/max/dev rtt=0/0.8/2/0.5, ttl 255/255/255/0.0, tos 0/0.0/0/0.0
```

### SSH to remote site B ce-202
```
vjr-ce201#ssh 192.168.200.11 vrf vjr                                                                                                                                                                                                         
connecting to 192.168.200.11 22 ok!
username: rare
password: 
securing connection ok!

escape character is ascii0x03.

welcome
line ready

vjr-ce202#show interfaces ethernet1                                            
ethernet1 is up
 description: 
 state changed 3 times, last at 2025-08-18 08:06:10, 01:08:24 ago
 last packet input 00:00:00 ago, output 00:00:00 ago, drop 00:00:08 ago
 type is ethernet hwaddr is aac1.aba3.a098 mtu is 1500 bw is 100mbps vrf is vjr
 ipv4 address is 192.168.200.11/24 ifcid=805058309
 received 102 packets (9640 bytes) dropped 12 packets (696 bytes)
 transmitted 356 packets (85348 bytes) macsec=false sgt=false

vjr-ce202#show ipv4 route vjr                                                  
typ  prefix             metric  iface      hop            time
DEF  0.0.0.0/0          0/2     ethernet1  192.168.200.1  00:51:25
C    10.255.202.1/32    0/0     loopback0  null           01:08:45
C    192.168.200.0/24   0/0     ethernet1  null           00:51:25
REM  192.168.200.1/32   0/0     ethernet1  192.168.200.1  00:51:25
LOC  192.168.200.11/32  0/1     ethernet1  null           00:51:25

vjr-ce202#exit                                                                 
see you later

connection closed
vjr-ce201#                                                                                                                                                                                                  
```
