This vagrant project brings up a 2 networks connected via BGP with a single server on each network.

Largely based on tutorial at http://xmodulo.com/centos-bgp-router-quagga.html

```
+----------------------------+                                   +----------------------------+
|                            |                                   |                            |
|               +------------+------+                     +------+------------+               |
|               | WAN(eth1):        |   192.168.50.0/24   | WAN(eth1):        |               |
|  r1 (router)  | 192.168.50.10/24  +---------------------+ 192.168.50.20/24  |  r1 (router)  |
|  AS100        |                   |                     |                   |        AS200  |
|               +------------+------+                     +------+------------+               |
|                            |                                   |                            |
| +-------------------+      |                                   |      +-------------------+ |
| | LAN(eth2):        |      |                                   |      | LAN(eth2):        | |
+-+  192.168.10.2/24  +------+                                   +------+  192.168.20.2/24  +-+
  |                   |                                                 |                   |
  +----------+--------+                                                 +---------+---------+
             |                                                                    |
             |                                                                    |
             |                                                                    |
       192.168.10.0/24                                                      192.168.20.0/24
             |                                                                    |
             |                                                                    |
  +----------+---------+                                               +----------+---------+
  | LAN(eth1):         |                                               | LAN(eth1):         |
+-+  192.168.10.100/24 +-+                                           +-+  192.168.20.100/24 +-+
| |                    | |                                           | |                    | |
| +--------------------+ |                                           | +--------------------+ |
|                        |                                           |                        |
| s1 (server)            |                                           | s2 (server)            |
|                        |                                           |                        |
+------------------------+                                           +------------------------+

```

# AS100

## r1 (router)

* announces route for AS100 (192.168.10.0/24) to `r2`

```
root@r1:~# vtysh -c "show ip bgp "
BGP table version is 0, local router ID is 192.168.50.10
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     0.0.0.0                  0         32768 i
*> 192.168.20.0     192.168.50.20            0             0 200 i

Total number of prefixes 2
root@r1:~# vtysh -c "show ip bgp summary"
BGP router identifier 192.168.50.10, local AS number 100
RIB entries 3, using 336 bytes of memory
Peers 1, using 4568 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.50.20   4   200      12      14        0    0    0 00:10:04        1

Total number of neighbors 1
```


## s1 (server on 192.168.10.0/24 net)

```
host$ vagrant up
...

host$ vagrant ssh s1

vagrant@s1:~$ ip route list
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.10.2 dev eth1
192.168.10.0/24 dev eth1  proto kernel  scope link  src 192.168.10.100

vagrant@s1:~$ traceroute 192.168.20.100
traceroute to 192.168.20.100 (192.168.20.100), 30 hops max, 60 byte packets
 1  192.168.10.2 (192.168.10.2)  0.227 ms  0.165 ms  0.100 ms
 2  192.168.50.20 (192.168.50.20)  0.679 ms  0.628 ms  0.589 ms
 3  192.168.20.100 (192.168.20.100)  0.578 ms  0.569 ms  0.563 ms
```


# AS200

## r2 (router)

* announces route for AS100 (192.168.20.0/24) to `r1` over 192.168.50.0/24 network

```
root@r2:~# vtysh -c "show ip bgp "
BGP table version is 0, local router ID is 192.168.50.20
Status codes: s suppressed, d damped, h history, * valid, > best, = multipath,
              i internal, r RIB-failure, S Stale, R Removed
Origin codes: i - IGP, e - EGP, ? - incomplete

   Network          Next Hop            Metric LocPrf Weight Path
*> 192.168.10.0     192.168.50.10            0             0 100 i
*> 192.168.20.0     0.0.0.0                  0         32768 i

Total number of prefixes 2
root@r2:~# vtysh -c "show ip bgp summary"
BGP router identifier 192.168.50.20, local AS number 200
RIB entries 3, using 336 bytes of memory
Peers 1, using 4568 bytes of memory

Neighbor        V    AS MsgRcvd MsgSent   TblVer  InQ OutQ Up/Down  State/PfxRcd
192.168.50.10   4   100      15      16        0    0    0 00:12:02        1

Total number of neighbors 1
```

## s2 (server on 192.168.20.0/24 net)
```
host$ vagrant ssh s2

vagrant@s2:~$ ip route list
default via 10.0.2.2 dev eth0
10.0.2.0/24 dev eth0  proto kernel  scope link  src 10.0.2.15
192.168.0.0/16 via 192.168.20.2 dev eth1
192.168.20.0/24 dev eth1  proto kernel  scope link  src 192.168.20.100

vagrant@s2:~$ traceroute 192.168.10.100
traceroute to 192.168.10.100 (192.168.10.100), 30 hops max, 60 byte packets
 1  192.168.20.2 (192.168.20.2)  0.221 ms  0.094 ms  0.112 ms
 2  192.168.50.10 (192.168.50.10)  0.372 ms  0.361 ms  0.298 ms
 3  192.168.10.100 (192.168.10.100)  0.555 ms  0.500 ms  0.485 ms
```

