# Anycast w/ BGP

In this example, there are 2 servers which share the anycast IP `192.168.40.10`, which is announced to r2 via BGP.  Once bgp sessions are established, packets will flow from c1 to the anycast IP. When one of the servers loses its bgp session w/ r1, packets continue to flow to the other server.

```
                    +-------------------+
                    | c1 (client)       |
                    |                   |
                    |    +-----------------+
                    +----+192.168.50.100/24|
                         +-----------------+
                                |
                                |
                                |
                       +---------------+
                   +---+192.168.50.2/24+---+
                   |   +---------------+   |
                   |                       |
                   |     r1 (router)       |
                   |                       |
             +---------------+   +---------------+
             |192.168.10.2/24+---+192.168.20.2/24|
             +---------------+   +---------------+
               |                               |
               |                               |
               |                               |
  +-----------------+                       +-----------------+
+-+192.168.10.100/24|                       |192.168.20.100/24+-+
| +-----------------+                       +-----------------+ |
|                |                             |                |
|                |                             |                |
|   s1 (server)+-------------+     +-------------+ s2 (server)  |
|              |  ANYCAST IP |     |  ANYCAST IP |              |
+--------------+192.168.40.10|     |192.168.40.10+--------------+
               +-------------+     +-------------+
```

