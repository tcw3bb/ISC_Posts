# Last Modified: Thu Apr 21 15:46:46 2016
#include <tunables/global>

/home/cowrie/start.sh {
  #include <abstractions/base>
  #include <abstractions/bash>

  network inet dgram,
  network inet stream,

  /bin/dash ix,
  /etc/host.conf r,
  /etc/hosts r,
  /etc/nsswitch.conf r,
  /etc/python2.7/sitecustomize.py r,
  /etc/ssh/moduli r,
  /home/cowrie/** rw,
  /run/resolvconf/resolv.conf r,
  /sbin/ldconfig rix,
  /sbin/ldconfig.real rix,
  /tmp/** a,
  /usr/bin/ r,
  /usr/bin/dirname rix,
  /usr/bin/python2.7 ix,
  /usr/bin/twistd rix,
  /usr/lib{,32,64}/** ra,
  /usr/local/lib/python2.7/dist-packages/ r,
  /var/tmp/** a,

}
