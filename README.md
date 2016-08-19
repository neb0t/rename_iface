#README

##Script using

By default script will try to change devise configuration in 
**/etc/sysconfig/network-scripts/ifcfg-$device**
where **$device** is current network interface.


```
generate-udev-net.pl > /etc/udev/rules.d/70-persistent-net.rules
```

**Be aware script will overwrite (or create) 70-persistent-net.rules file!**