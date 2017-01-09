This vagrant project brings up a 4 networks connected via BGP with a single server on each network. The purpose of this is to create a more complex topology that includes multiple available routes per router.  Success here means that any device can contact any other device in the event of any single router failure except for those on the failed router's network.

Largely based on tutorial at http://xmodulo.com/centos-bgp-router-quagga.html

```

                       +--------------------------+                                          +--------------------------+
                       |             +------------------+                              +------------------+             |
                       | r1 (router) |     eth1         |        192.168.50.0/24       |     eth1         | r2 (router) |
                       | AS100       | 192.168.50.10/24 +------------------------------+ 192.168.50.20/24 |       AS200 |
                       |             +------------------+                              +------------------+             |
                       | +-------------------+    |                                          |   +-------------------+  |
                       | |     eth2          |    |                                          |   |     eth2          |  |
                       +-+  192.168.10.2/24  +----+                                          +---+  192.168.20.2/24  +--+
                         +--------+----------+                                                   +---------+---------+
                                  |                                                                        |
                           192.168.10.0/24                                                           192.168.20.0/24
                                  |                                                                        |
              +-------------------+-----------+                                              +-------------+--------------+
              |                               |                                              |                            |
   +----------+---------+           +---------+-------+                              +-----------------+         +--------------------+
 +-+     eth1           +-+       +-+     eth2        +---+                        +-+     eth1        +---+     |     eth1           |
 | |  192.168.10.100/24 | |       | | 192.168.10.4/24 |   |                        | | 192.168.20.3/24 |   |   +-+  192.168.20.100/24 +-+
 | +--------------------+ |       | +-----------------+   |                        | +-----------------+   |   | +--------------------+ |
 | s1 (server)            |       | r4 (router) +-----------------+                |           r3 (router) |   | s2 (server)            |
 |                        |       | AS400       |    eth1         |                |                AS300  |   |                        |
 +------------------------+       |             | 192.168.30.3/24 |                |                       |   +------------------------+
                                  |             +--------------+--+                |                       |
                                  | +-----------------+   |    |                   | +-------------------+ |
                                  +-+    eth3         +---+    |                   +-+     eth2          +-+
                                    | 192.168.40.2/24 |        |                     |  192.168.30.2/24  |
                                    +--------+--------+        |                     +-------------------+
                                             |                 |                                |
                                       192.168.40.0/24         +--------------------------------+
                                             |                                                  |
                                   +---------+----------+                                       |
                                   |     eth1           |                                  192.168.30.0/24
                                 +-+  192.168.40.100/24 +-+                                     |
                                 | +--------------------+ |                           +---------+----------+
                                 | s4 (server)            |                           |     eth1           |
                                 |                        |                         +-+  192.168.30.100/24 +-+
                                 +------------------------+                         | +--------------------+ |
                                                                                    | s3 (server)            |
                                                                                    |                        |
                                                                                    +------------------------+
```


## AS100

Announces routes to:
* AS400
* AS100

## AS200

Announces routes to:
* AS100
* AS300

# AS300

Announces routes to:
* AS400
* AS200

# AS400

Announces routes to:
* AS300
* AS100


```
$ ./test.sh
r1
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 dev eth2  proto kernel  scope link  src 192.168.10.2
192.168.20.0/24 via 192.168.50.20 dev eth1  proto zebra
192.168.30.0/24 via 192.168.10.4 dev eth2  proto zebra
192.168.40.0/24 via 192.168.10.4 dev eth2  proto zebra
192.168.50.0/24 dev eth1  proto kernel  scope link  src 192.168.50.10
BGP
BGP table version is 0, local router ID is 192.168.50.10
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*  192.168.10.0     192.168.10.4             0             0 400 i
*>                  0.0.0.0                  0         32768 i
*  192.168.20.0     192.168.10.4                           0 400 300 i
*>                  192.168.50.20            0             0 200 i
*> 192.168.30.0     192.168.10.4             0             0 400 i
*                   192.168.50.20                          0 200 300 i
*  192.168.40.0     192.168.50.20                          0 200 300 400 i
*>                  192.168.10.4             0             0 400 i
*  192.168.50.0     192.168.50.20            0             0 200 i
*>                  0.0.0.0                  0         32768 i

Total number of prefixes 5
BGP router identifier 192.168.50.10, local AS number 100
RIB entries 9, using 1008 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.10.4    4   400      42      50        0    0    0 00:20:09        4
192.168.50.20   4   200      48      53        0    0    0 00:21:44        4

Total number of neighbors 2
r1 -> 192.168.50.10:  0% packet loss
r1 -> 192.168.10.2:  0% packet loss
r1 -> 192.168.50.20:  0% packet loss
r1 -> 192.168.20.2:  0% packet loss
r1 -> 192.168.20.3:  0% packet loss
r1 -> 192.168.30.2:  0% packet loss
r1 -> 192.168.30.3:  0% packet loss
r1 -> 192.168.10.4:  0% packet loss
r1 -> 192.168.40.2:  0% packet loss
r1 -> 192.168.10.100:  0% packet loss
r1 -> 192.168.20.100:  0% packet loss
r1 -> 192.168.30.100:  0% packet loss
r1 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
r2
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 via 192.168.50.10 dev eth1  proto zebra
192.168.20.0/24 dev eth2  proto kernel  scope link  src 192.168.20.2
192.168.30.0/24 via 192.168.20.3 dev eth2  proto zebra
192.168.40.0/24 via 192.168.20.3 dev eth2  proto zebra
192.168.50.0/24 dev eth1  proto kernel  scope link  src 192.168.50.20
BGP
BGP table version is 0, local router ID is 192.168.50.20
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*  192.168.10.0     192.168.20.3                           0 300 400 i
*>                  192.168.50.10            0             0 100 i
*  192.168.20.0     192.168.20.3             0             0 300 i
*>                  0.0.0.0                  0         32768 i
*  192.168.30.0     192.168.50.10                          0 100 400 i
*>                  192.168.20.3             0             0 300 i
*  192.168.40.0     192.168.50.10                          0 100 400 i
*>                  192.168.20.3                           0 300 400 i
*  192.168.50.0     192.168.50.10            0             0 100 i
*>                  0.0.0.0                  0         32768 i

Total number of prefixes 5
BGP router identifier 192.168.50.20, local AS number 200
RIB entries 9, using 1008 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.20.3    4   300      29      26        0    0    0 00:21:52        4
192.168.50.10   4   100      29      30        0    0    0 00:21:47        4

Total number of neighbors 2
r2 -> 192.168.50.10:  0% packet loss
r2 -> 192.168.10.2:  0% packet loss
r2 -> 192.168.50.20:  0% packet loss
r2 -> 192.168.20.2:  0% packet loss
r2 -> 192.168.20.3:  0% packet loss
r2 -> 192.168.30.2:  0% packet loss
r2 -> 192.168.30.3:  0% packet loss
r2 -> 192.168.10.4:  0% packet loss
r2 -> 192.168.40.2:  0% packet loss
r2 -> 192.168.10.100:  0% packet loss
r2 -> 192.168.20.100:  0% packet loss
r2 -> 192.168.30.100:  0% packet loss
r2 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
r3
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 via 192.168.30.3 dev eth2  proto zebra
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.3
192.168.30.0/24 dev eth2  proto kernel  scope link  src 192.168.30.2
192.168.40.0/24 via 192.168.30.3 dev eth2  proto zebra
192.168.50.0/24 via 192.168.20.2 dev eth1  proto zebra
BGP
BGP table version is 0, local router ID is 192.168.20.3
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     192.168.30.3             0             0 400 i
*                   192.168.20.2                           0 200 100 i
*  192.168.20.0     192.168.20.2             0             0 200 i
*>                  0.0.0.0                  0         32768 i
*  192.168.30.0     192.168.30.3             0             0 400 i
*>                  0.0.0.0                  0         32768 i
*> 192.168.40.0     192.168.30.3             0             0 400 i
*  192.168.50.0     192.168.30.3                           0 400 100 i
*>                  192.168.20.2             0             0 200 i

Total number of prefixes 5
BGP router identifier 192.168.20.3, local AS number 300
RIB entries 9, using 1008 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.20.2    4   200      45      53        0    0    0 00:21:54        3
192.168.30.3    4   400      41      50        0    0    0 00:20:16        4

Total number of neighbors 2
r3 -> 192.168.50.10:  0% packet loss
r3 -> 192.168.10.2:  0% packet loss
r3 -> 192.168.50.20:  0% packet loss
r3 -> 192.168.20.2:  0% packet loss
r3 -> 192.168.20.3:  0% packet loss
r3 -> 192.168.30.2:  0% packet loss
r3 -> 192.168.30.3:  0% packet loss
r3 -> 192.168.10.4:  0% packet loss
r3 -> 192.168.40.2:  0% packet loss
r3 -> 192.168.10.100:  0% packet loss
r3 -> 192.168.20.100:  0% packet loss
r3 -> 192.168.30.100:  0% packet loss
r3 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
r4
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 dev eth2  proto kernel  scope link  src 192.168.10.4
192.168.20.0/24 via 192.168.30.2 dev eth1  proto zebra
192.168.30.0/24 dev eth1  proto kernel  scope link  src 192.168.30.3
192.168.40.0/24 dev eth3  proto kernel  scope link  src 192.168.40.2
192.168.50.0/24 via 192.168.10.2 dev eth2  proto zebra
BGP
BGP table version is 0, local router ID is 192.168.30.3
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*  192.168.10.0     192.168.10.2             0             0 100 i
*>                  0.0.0.0                  0         32768 i
*  192.168.20.0     192.168.10.2                           0 100 200 i
*>                  192.168.30.2             0             0 300 i
*  192.168.30.0     192.168.30.2             0             0 300 i
*>                  0.0.0.0                  0         32768 i
*> 192.168.40.0     0.0.0.0                  0         32768 i
*> 192.168.50.0     192.168.10.2             0             0 100 i
*                   192.168.30.2                           0 300 200 i

Total number of prefixes 5
BGP router identifier 192.168.30.3, local AS number 400
RIB entries 9, using 1008 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.10.2    4   100      26      27        0    0    0 00:20:17        3
192.168.30.2    4   300      26      25        0    0    0 00:20:19        3

Total number of neighbors 2
r4 -> 192.168.50.10:  0% packet loss
r4 -> 192.168.10.2:  0% packet loss
r4 -> 192.168.50.20:  0% packet loss
r4 -> 192.168.20.2:  0% packet loss
r4 -> 192.168.20.3:  0% packet loss
r4 -> 192.168.30.2:  0% packet loss
r4 -> 192.168.30.3:  0% packet loss
r4 -> 192.168.10.4:  0% packet loss
r4 -> 192.168.40.2:  0% packet loss
r4 -> 192.168.10.100:  0% packet loss
r4 -> 192.168.20.100:  0% packet loss
r4 -> 192.168.30.100:  0% packet loss
r4 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
s1
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.10.2 dev eth1
192.168.10.0/24 dev eth1  proto kernel  scope link  src 192.168.10.100
s1 -> 192.168.50.10:  0% packet loss
s1 -> 192.168.10.2:  0% packet loss
s1 -> 192.168.50.20:  0% packet loss
s1 -> 192.168.20.2:  0% packet loss
s1 -> 192.168.20.3:  0% packet loss
s1 -> 192.168.30.2:  0% packet loss
s1 -> 192.168.30.3:  0% packet loss
s1 -> 192.168.10.4:  0% packet loss
s1 -> 192.168.40.2:  0% packet loss
s1 -> 192.168.10.100:  0% packet loss
s1 -> 192.168.20.100:  0% packet loss
s1 -> 192.168.30.100:  0% packet loss
s1 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
s2
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.20.2 dev eth1
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.100
s2 -> 192.168.50.10:  0% packet loss
s2 -> 192.168.10.2:  0% packet loss
s2 -> 192.168.50.20:  0% packet loss
s2 -> 192.168.20.2:  0% packet loss
s2 -> 192.168.20.3:  0% packet loss
s2 -> 192.168.30.2:  0% packet loss
s2 -> 192.168.30.3:  0% packet loss
s2 -> 192.168.10.4:  0% packet loss
s2 -> 192.168.40.2:  0% packet loss
s2 -> 192.168.10.100:  0% packet loss
s2 -> 192.168.20.100:  0% packet loss
s2 -> 192.168.30.100:  0% packet loss
s2 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
s3
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.30.2 dev eth1
192.168.30.0/24 dev eth1  proto kernel  scope link  src 192.168.30.100
s3 -> 192.168.50.10:  0% packet loss
s3 -> 192.168.10.2:  0% packet loss
s3 -> 192.168.50.20:  0% packet loss
s3 -> 192.168.20.2:  0% packet loss
s3 -> 192.168.20.3:  0% packet loss
s3 -> 192.168.30.2:  0% packet loss
s3 -> 192.168.30.3:  0% packet loss
s3 -> 192.168.10.4:  0% packet loss
s3 -> 192.168.40.2:  0% packet loss
s3 -> 192.168.10.100:  0% packet loss
s3 -> 192.168.20.100:  0% packet loss
s3 -> 192.168.30.100:  0% packet loss
s3 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
s4
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.40.2 dev eth1
192.168.40.0/24 dev eth1  proto kernel  scope link  src 192.168.40.100
s4 -> 192.168.50.10:  0% packet loss
s4 -> 192.168.10.2:  0% packet loss
s4 -> 192.168.50.20:  0% packet loss
s4 -> 192.168.20.2:  0% packet loss
s4 -> 192.168.20.3:  0% packet loss
s4 -> 192.168.30.2:  0% packet loss
s4 -> 192.168.30.3:  0% packet loss
s4 -> 192.168.10.4:  0% packet loss
s4 -> 192.168.40.2:  0% packet loss
s4 -> 192.168.10.100:  0% packet loss
s4 -> 192.168.20.100:  0% packet loss
s4 -> 192.168.30.100:  0% packet loss
s4 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
```

Running `test.sh` after shutting down `quagga` on `r4` yields all devices still
reachable except for 192.168.40.0/24 and `r4`s interfaces.:

```
vagrant@r4:~$ sudo systemctl stop quagga
$ ./test.sh
r1
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 dev eth2  proto kernel  scope link  src 192.168.10.2
192.168.20.0/24 via 192.168.50.20 dev eth1  proto zebra
192.168.30.0/24 via 192.168.50.20 dev eth1  proto zebra
192.168.50.0/24 dev eth1  proto kernel  scope link  src 192.168.50.10
BGP
BGP table version is 0, local router ID is 192.168.50.10
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     0.0.0.0                  0         32768 i
*> 192.168.20.0     192.168.50.20            0             0 200 i
*> 192.168.30.0     192.168.50.20                          0 200 300 i
*  192.168.50.0     192.168.50.20            0             0 200 i
*>                  0.0.0.0                  0         32768 i

Total number of prefixes 4
BGP router identifier 192.168.50.10, local AS number 100
RIB entries 7, using 784 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.10.4    4   400      50      57        0    0    0 00:00:11 Active
192.168.50.20   4   200      57      62        0    0    0 00:29:16        3

Total number of neighbors 2
r1 -> 192.168.50.10:  0% packet loss
r1 -> 192.168.10.2:  0% packet loss
r1 -> 192.168.50.20:  0% packet loss
r1 -> 192.168.20.2:  0% packet loss
r1 -> 192.168.20.3:  0% packet loss
r1 -> 192.168.30.2:  0% packet loss
r1 -> 192.168.30.3:  100% packet loss
r1 -> 192.168.10.4:  0% packet loss
r1 -> 192.168.40.2:  0% packet loss
r1 -> 192.168.10.100:  0% packet loss
r1 -> 192.168.20.100:  0% packet loss
r1 -> 192.168.30.100:  0% packet loss
r1 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
r2
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 via 192.168.50.10 dev eth1  proto zebra
192.168.20.0/24 dev eth2  proto kernel  scope link  src 192.168.20.2
192.168.30.0/24 via 192.168.20.3 dev eth2  proto zebra
192.168.50.0/24 dev eth1  proto kernel  scope link  src 192.168.50.20
BGP
BGP table version is 0, local router ID is 192.168.50.20
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     192.168.50.10            0             0 100 i
*  192.168.20.0     192.168.20.3             0             0 300 i
*>                  0.0.0.0                  0         32768 i
*> 192.168.30.0     192.168.20.3             0             0 300 i
*  192.168.50.0     192.168.50.10            0             0 100 i
*>                  0.0.0.0                  0         32768 i

Total number of prefixes 4
BGP router identifier 192.168.50.20, local AS number 200
RIB entries 7, using 784 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.20.3    4   300      38      34        0    0    0 00:29:34        2
192.168.50.10   4   100      38      39        0    0    0 00:29:29        2

Total number of neighbors 2
r2 -> 192.168.50.10:  0% packet loss
r2 -> 192.168.10.2:  0% packet loss
r2 -> 192.168.50.20:  0% packet loss
r2 -> 192.168.20.2:  0% packet loss
r2 -> 192.168.20.3:  0% packet loss
r2 -> 192.168.30.2:  0% packet loss
r2 -> 192.168.30.3:  100% packet loss
r2 -> 192.168.10.4:  100% packet loss
r2 -> 192.168.40.2:  0% packet loss
r2 -> 192.168.10.100:  0% packet loss
r2 -> 192.168.20.100:  0% packet loss
r2 -> 192.168.30.100:  0% packet loss
r2 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
r3
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 via 192.168.20.2 dev eth1  proto zebra
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.3
192.168.30.0/24 dev eth2  proto kernel  scope link  src 192.168.30.2
192.168.50.0/24 via 192.168.20.2 dev eth1  proto zebra
BGP
BGP table version is 0, local router ID is 192.168.20.3
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     192.168.20.2                           0 200 100 i
*  192.168.20.0     192.168.20.2             0             0 200 i
*>                  0.0.0.0                  0         32768 i
*> 192.168.30.0     0.0.0.0                  0         32768 i
*> 192.168.50.0     192.168.20.2             0             0 200 i

Total number of prefixes 4
BGP router identifier 192.168.20.3, local AS number 300
RIB entries 7, using 784 bytes of memory
Peers 2, using 9136 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.20.2    4   200      53      62        0    0    0 00:29:56        3
192.168.30.3    4   400      49      57        0    0    0 00:00:46 Active

Total number of neighbors 2
r3 -> 192.168.50.10:  0% packet loss
r3 -> 192.168.10.2:  0% packet loss
r3 -> 192.168.50.20:  0% packet loss
r3 -> 192.168.20.2:  0% packet loss
r3 -> 192.168.20.3:  0% packet loss
r3 -> 192.168.30.2:  0% packet loss
r3 -> 192.168.30.3:  0% packet loss
r3 -> 192.168.10.4:  100% packet loss
r3 -> 192.168.40.2:  0% packet loss
r3 -> 192.168.10.100:  0% packet loss
r3 -> 192.168.20.100:  0% packet loss
r3 -> 192.168.30.100:  0% packet loss
r3 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
r4
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.10.0/24 dev eth2  proto kernel  scope link  src 192.168.10.4
192.168.30.0/24 dev eth1  proto kernel  scope link  src 192.168.30.3
192.168.40.0/24 dev eth3  proto kernel  scope link  src 192.168.40.2
BGP
Exiting: failed to connect to any daemons.
Exiting: failed to connect to any daemons.
r4 -> 192.168.50.10:  0% packet loss
r4 -> 192.168.10.2:  0% packet loss
r4 -> 192.168.50.20:  0% packet loss
r4 -> 192.168.20.2:  0% packet loss
r4 -> 192.168.20.3:  0% packet loss
r4 -> 192.168.30.2:  0% packet loss
r4 -> 192.168.30.3:  0% packet loss
r4 -> 192.168.10.4:  0% packet loss
r4 -> 192.168.40.2:  0% packet loss
r4 -> 192.168.10.100:  0% packet loss
r4 -> 192.168.20.100:  0% packet loss
r4 -> 192.168.30.100:  0% packet loss
r4 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
s1
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.10.2 dev eth1
192.168.10.0/24 dev eth1  proto kernel  scope link  src 192.168.10.100
s1 -> 192.168.50.10:  0% packet loss
s1 -> 192.168.10.2:  0% packet loss
s1 -> 192.168.50.20:  0% packet loss
s1 -> 192.168.20.2:  0% packet loss
s1 -> 192.168.20.3:  0% packet loss
s1 -> 192.168.30.2:  0% packet loss
s1 -> 192.168.30.3:  0% packet loss
s1 -> 192.168.10.4:  0% packet loss
s1 -> 192.168.40.2:  100% packet loss
s1 -> 192.168.10.100:  0% packet loss
s1 -> 192.168.20.100:  0% packet loss
s1 -> 192.168.30.100:  0% packet loss
s1 -> 192.168.40.100:  100% packet loss
Connection to 127.0.0.1 closed.
s2
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.20.2 dev eth1
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.100
s2 -> 192.168.50.10:  0% packet loss
s2 -> 192.168.10.2:  0% packet loss
s2 -> 192.168.50.20:  0% packet loss
s2 -> 192.168.20.2:  0% packet loss
s2 -> 192.168.20.3:  0% packet loss
s2 -> 192.168.30.2:  0% packet loss
s2 -> 192.168.30.3:  100% packet loss
s2 -> 192.168.10.4:  100% packet loss
s2 -> 192.168.40.2:  100% packet loss
s2 -> 192.168.10.100:  0% packet loss
s2 -> 192.168.20.100:  0% packet loss
s2 -> 192.168.30.100:  0% packet loss
s2 -> 192.168.40.100:  100% packet loss
Connection to 127.0.0.1 closed.
s3
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.30.2 dev eth1
192.168.30.0/24 dev eth1  proto kernel  scope link  src 192.168.30.100
s3 -> 192.168.50.10:  0% packet loss
s3 -> 192.168.10.2:  0% packet loss
s3 -> 192.168.50.20:  0% packet loss
s3 -> 192.168.20.2:  0% packet loss
s3 -> 192.168.20.3:  0% packet loss
s3 -> 192.168.30.2:  0% packet loss
s3 -> 192.168.30.3:  0% packet loss
s3 -> 192.168.10.4:  0% packet loss
s3 -> 192.168.40.2:  100% packet loss
s3 -> 192.168.10.100:  0% packet loss
s3 -> 192.168.20.100:  0% packet loss
s3 -> 192.168.30.100:  0% packet loss
s3 -> 192.168.40.100:  100% packet loss
Connection to 127.0.0.1 closed.
s4
========================
ip route list:
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.40.2 dev eth1
192.168.40.0/24 dev eth1  proto kernel  scope link  src 192.168.40.100
s4 -> 192.168.50.10:  100% packet loss
s4 -> 192.168.10.2:  100% packet loss
s4 -> 192.168.50.20:  100% packet loss
s4 -> 192.168.20.2:  100% packet loss
s4 -> 192.168.20.3:  100% packet loss
s4 -> 192.168.30.2:  100% packet loss
s4 -> 192.168.30.3:  0% packet loss
s4 -> 192.168.10.4:  0% packet loss
s4 -> 192.168.40.2:  0% packet loss
s4 -> 192.168.10.100:  100% packet loss
s4 -> 192.168.20.100:  100% packet loss
s4 -> 192.168.30.100:  100% packet loss
s4 -> 192.168.40.100:  0% packet loss
Connection to 127.0.0.1 closed.
```
