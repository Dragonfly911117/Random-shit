## How to connect to NTUT-802.1X in Linux distros

The [official document](https://cnc.ntut.edu.tw/p/404-1004-42883-1.php?Lang=zh-tw) does not contains the Linux-way, so I'm writing this note.


### Network-Manager
For Network-Manager users, just connect as it's a regular PSA network.


### iwd
Follow instructions from [Arch wiki](https://wiki.archlinux.org/title/Iwd#EAP-PEAP) and [Guide for Android users](https://cnc.ntut.edu.tw/var/file/4/1004/img/1183/Android4x.pdf) and you'll have the following result.

```
#/var/lib/iwd/=4e5455542d3830322e3158.8021x

[Security]
EAP-Method=PEAP
EAP-PEAP-Phase2-Method=GTC
EAP-PEAP-Phase2-Identity= <Your nportal-account>
EAP-PEAP-Phase2-Password= <Your nportal-password>

[Settings]
AutoConnect= <If you want to connect automatically>

```

