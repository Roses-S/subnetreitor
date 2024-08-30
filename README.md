# subnetreitor
**subnetreitor** is a tool tool made on bash to subnetting networks or find a information about an IP in a subnetwork.

## How does tool execute?
That is a good question... Well the tool has 2 modes, with the parameter **'-s'** or **'-p'** we'll able to find the information about an IP, depend if you have a subnetmask or a prefix. On the other hand with the parameter **'-d'** or **'-n'** we're gonna subnet a network, one is to subnet by quantity of devices and the other is to quantity of subnetworks, if we want to show the table we use **'-t'** to show the subnetting table. Of course always using the parameter **'-i'** to specific the IP that you have.

Anyway the tool has its own help panel after execution:
```bash
┌─(root@RedRose)-[/opt/subnetreitor]
└#  ./subnetreitor.sh

-------------------------------------------------------------
[?] How to use: ./subnetreitor.sh
-------------------------------------------------------------
    Network Reconnaissance
    i) Ip
        Ex: 182.168.1.70
    s) Subnetmask or p) Prefix
        Ex: 255.255.255.192 / 28
    -----------------------------
    Subnetting a Network
    i) Ip
        Ex: 192.168.1.0
    d) Host or n) Networks
        Ex: 35 Hosts / 16 Networks
    t) Show Subnetting Table
    -----------------------------
    Help
    h) Show Help Panel
```
All ready with the parameters and all configurided the script will do all the calculations automatic and we get the result.

Following you can see a example of subnetting a network by quantity of devices:

![image alt](https://github.com/Roses-S/subnetreitor/blob/d31caa3cfab204d060c9ced47fe87e737888d59f/images/Subnetting.png)

Following you can see a example of discovering IP's information:

![image alt](https://github.com/Roses-S/subnetreitor/blob/d31caa3cfab204d060c9ced47fe87e737888d59f/images/Discovering%20information.png)

**NOTE:** is possible this tool will update with new options.
