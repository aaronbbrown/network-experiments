This vagrant project brings up a 3 networks connected via BGP with a single server on each network.  AS100 and AS200 are directly connected, but AS300 sits within AS200s network and is not connected to AS100, so transitive routing must occur at `r2`.

Largely based on tutorial at http://xmodulo.com/centos-bgp-router-quagga.html

```
+--------------------------+                                          +--------------------------+
|             +------------------+                              +------------------+             |
| r1 (router) | WAN(eth1):       |        192.168.50.0/24       | WAN(eth1):       | r2 (router) |
| AS100       | 192.168.50.10/24 +------------------------------+ 192.168.50.20/24 |       AS200 |
|             +------------+-----+                              +-----+------------+             |
| +-------------------+    |                                          |   +-------------------+  |
| | LAN(eth2):        |    |                                          |   | LAN(eth2):        |  |
+-+  192.168.10.2/24  +----+                                          +---+  192.168.20.2/24  +--+
  +----------+--------+                                                   +---------+---------+
             |                    +--------------------------+                      |
       192.168.10.0/24            |             +-----------------+           192.168.20.0/24
             +                    | r3 (router) | WAN(eth1):      +-----------------+
             |                    | AS300       | 192.168.20.3/24 |                 |
  +----------+---------+          |             +------------+----+      +----------+---------+
+-+ LAN(eth1):         +-+        | +-------------------+    |           | LAN(eth1):         |
| |  192.168.10.100/24 | |        | | LAN(eth2):        |    |         +-+  192.168.20.100/24 +-+
| +--------------------+ |        +-+  192.168.10.2/24  +----+         | +--------------------+ |
| s1 (server)            |          +----------+--------+              | s2 (server)            |
|                        |                     |                       |                        |
+------------------------+                     |                       +------------------------+
                                          192.168.30.0/24
                                               |
                                     +---------+----------+
                                     | LAN(eth1):         |
                                   +-+  192.168.30.100/24 +-+
                                   | +--------------------+ |
                                   | s3 (server)            |
                                   |                        |
                                   +------------------------+
```

```
./test.sh
r1
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 dev eth2  proto kernel  scope link  src 192.168.10.2
192.168.20.0/24 via 192.168.50.20 dev eth1  proto zebra
192.168.30.0/24 via 192.168.50.20 dev eth1  proto zebra
192.168.50.0/24 dev eth1  proto kernel  scope link  src 192.168.50.10
Connection to 127.0.0.1 closed.
show ip bgp:
BGP table version is 0, local router ID is 192.168.50.10
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     0.0.0.0                  0         32768 i
*> 192.168.20.0     192.168.50.20            0             0 200 i
*> 192.168.30.0     192.168.50.20                          0 200 300 i
*> 192.168.50.0     192.168.50.20            0             0 200 i

Total number of prefixes 4
BGP router identifier 192.168.50.10, local AS number 100
RIB entries 7, using 784 bytes of memory
Peers 1, using 4568 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.50.20   4   200      83      86        0    0    0 00:54:16        3

Total number of neighbors 1
Connection to 127.0.0.1 closed.
r1 -> 192.168.10.100:  0% packet loss
r1 -> 192.168.20.100:  0% packet loss
r1 -> 192.168.30.100:  0% packet loss
r1 -> 192.168.10.2:  0% packet loss
r1 -> 192.168.20.2:  0% packet loss
r1 -> 192.168.20.3:  0% packet loss
r1 -> 192.168.30.2:  0% packet loss
r1 -> 192.168.50.10:  0% packet loss
r1 -> 192.168.50.20:  0% packet loss

r2
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 via 192.168.50.10 dev eth1  proto zebra
192.168.20.0/24 dev eth2  proto kernel  scope link  src 192.168.20.2
192.168.30.0/24 via 192.168.20.3 dev eth2  proto zebra
192.168.50.0/24 dev eth1  proto kernel  scope link  src 192.168.50.20
Connection to 127.0.0.1 closed.
show ip bgp:
BGP table version is 0, local router ID is 192.168.50.20
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     192.168.50.10            0             0 100 i
*> 192.168.20.0     0.0.0.0                  0         32768 i
*> 192.168.30.0     192.168.20.3             0             0 300 i
*> 192.168.50.0     0.0.0.0                  0         32768 i

Total number of prefixes 4
BGP router identifier 192.168.50.20, local AS number 200
RIB entries 7, using 784 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.20.3    4   300      57      59        0    0    0 00:54:48        1
192.168.50.10   4   100      57      59        0    0    0 00:54:46        1

Total number of neighbors 2
Connection to 127.0.0.1 closed.
r2 -> 192.168.10.100:  0% packet loss
r2 -> 192.168.20.100:  0% packet loss
r2 -> 192.168.30.100:  0% packet loss
r2 -> 192.168.10.2:  0% packet loss
r2 -> 192.168.20.2:  0% packet loss
r2 -> 192.168.20.3:  0% packet loss
r2 -> 192.168.30.2:  0% packet loss
r2 -> 192.168.50.10:  0% packet loss
r2 -> 192.168.50.20:  0% packet loss

r3
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 via 192.168.20.2 dev eth1  proto zebra
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.3
192.168.30.0/24 dev eth2  proto kernel  scope link  src 192.168.30.2
192.168.50.0/24 via 192.168.20.2 dev eth1  proto zebra
Connection to 127.0.0.1 closed.
show ip bgp:
BGP table version is 0, local router ID is 192.168.20.3
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     192.168.20.2                           0 200 100 i
*> 192.168.20.0     192.168.20.2             0             0 200 i
*> 192.168.30.0     0.0.0.0                  0         32768 i
*> 192.168.50.0     192.168.20.2             0             0 200 i

Total number of prefixes 4
BGP router identifier 192.168.20.3, local AS number 300
RIB entries 7, using 784 bytes of memory
Peers 1, using 4568 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.20.2    4   200      84      86        0    0    0 00:55:19        3

Total number of neighbors 1
Connection to 127.0.0.1 closed.
r3 -> 192.168.10.100:  0% packet loss
r3 -> 192.168.20.100:  0% packet loss
r3 -> 192.168.30.100:  0% packet loss
r3 -> 192.168.10.2:  0% packet loss
r3 -> 192.168.20.2:  0% packet loss
r3 -> 192.168.20.3:  0% packet loss
r3 -> 192.168.30.2:  0% packet loss
r3 -> 192.168.50.10:  0% packet loss
r3 -> 192.168.50.20:  0% packet loss

s1
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.10.2 dev eth1
192.168.10.0/24 dev eth1  proto kernel  scope link  src 192.168.10.100
Connection to 127.0.0.1 closed.
s1 -> 192.168.10.100:  0% packet loss
s1 -> 192.168.20.100:  0% packet loss
s1 -> 192.168.30.100:  0% packet loss
s1 -> 192.168.10.2:  0% packet loss
s1 -> 192.168.20.2:  0% packet loss
s1 -> 192.168.20.3:  0% packet loss
s1 -> 192.168.30.2:  0% packet loss
s1 -> 192.168.50.10:  0% packet loss
s1 -> 192.168.50.20:  0% packet loss

s2
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.20.2 dev eth1
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.100
Connection to 127.0.0.1 closed.
s2 -> 192.168.10.100:  0% packet loss
s2 -> 192.168.20.100:  0% packet loss
s2 -> 192.168.30.100:  0% packet loss
s2 -> 192.168.10.2:  0% packet loss
s2 -> 192.168.20.2:  0% packet loss
s2 -> 192.168.20.3:  0% packet loss
s2 -> 192.168.30.2:  0% packet loss
s2 -> 192.168.50.10:  0% packet loss
s2 -> 192.168.50.20:  0% packet loss

s3
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.30.2 dev eth1
192.168.30.0/24 dev eth1  proto kernel  scope link  src 192.168.30.100
Connection to 127.0.0.1 closed.
s3 -> 192.168.10.100:  0% packet loss
s3 -> 192.168.20.100:  0% packet loss
s3 -> 192.168.30.100:  0% packet loss
s3 -> 192.168.10.2:  0% packet loss
s3 -> 192.168.20.2:  0% packet loss
s3 -> 192.168.20.3:  0% packet loss
s3 -> 192.168.30.2:  0% packet loss
s3 -> 192.168.50.10:  0% packet loss
s3 -> 192.168.50.20:  0% packet loss
```
