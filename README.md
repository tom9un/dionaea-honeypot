# dionaea-honeypot
**A. Instalasi manual dionaea di VM ubuntu 12.04 server x64**

1. Buat VM dari iso ubuntu 12.04 server;

2. Setelah selesai instalasi os, jalankan update sbb :
    
*       sudo apt-get update
        sudo apt-get install -f
        sudo rm -rf /var/lib/apt/lists/*
        sudo apt-get update
        sudo apt-get upgrade
        sudo apt-get dist-upgrade
        sudo apt-get autoremove

3. Install depedencies sbb :
    
*       sudo apt-get install libudns-dev libglib2.0-dev libssl-dev libcurl4-openssl-dev 
        libreadline-dev libsqlite3-dev python-dev libtool automake autoconf build-essential 
        subversion git-core flex bison pkg-config libgc-dev libgc1c2 sqlite3 python-geoip 
        sqlite python-pip libreadline6 libreadline6-dev

4. Buat folder dionaea di folder opt :

*       sudo mkdir /opt/dionaea

5. Buat folder untuk menampung instalasi :

*       sudo mkdir ~/src

6. Buat alias di bashrc (mungkin optional) :

*       sudo nano ~/.bashrc
   *    isi diawal baris pada file bashrc dengan :
    
*       alias python=python3
        alias sqlite=sqlite3
        
    *   setelah exit dari editor kemudian reboot 
*       sudo reboot

7. Instal paket2 yang dibutuhkan sbb :
    
    *   Install Liblcfg
*       cd ~/src
        sudo git clone https://github.com/ThomasAdam/liblcfg.git liblcfg
        cd liblcfg/code
        sudo autoreconf -vi
        sudo ./configure --prefix=/opt/dionaea
        sudo make install
        sudo ldconfig

    *   Install Libemu :
*       cd ~/src
        sudo git clone https://github.com/gento/libemu.git libemu
        cd libemu
        sudo autoreconf -vi
        sudo ./configure --prefix=/opt/dionaea
        sudo make install
        sudo ldconfig
        
    *   Install Libnl :
*       apt-get install libnl-3-dev libnl-genl-3-dev libnl-nf-3-dev libnl-route-3-dev
        
    *   Install Libev :
*       cd ~/src
        sudo wget http://dist.schmorp.de/libev/libev-4.33.tar.gz
        sudo tar xfz libev-4.33.tar.gz
        cd libev-4.33
        sudo ./configure --prefix=/opt/dionaea
        sudo make install
        sudo ldconfig
        
    *   Install Python :
*       cd ~/src
        sudo wget http://www.python.org/ftp/python/3.2.2/Python-3.2.2.tgz
        sudo tar xfz Python-3.2.2.tgz
        cd Python-3.2.2/
        sudo ./configure --enable-shared --prefix=/opt/dionaea --with-computed-gotos --enable-ipv6 LDFLAGS="-Wl,-rpath=/opt/dionaea/lib/ -L/usr/lib/x86_64-linux-gnu/"
        sudo make
        sudo make install
        sudo ldconfig
        
    *   Install Libcurl :
*       sudo apt-get install curl
        
    *   Install Libpcap :
*       cd ~/src
        sudo wget http://www.tcpdump.org/release/libpcap-1.6.2.tar.gz
        sudo tar xfz libpcap-1.6.2.tar.gz
        cd libpcap-1.6.2
        sudo ./configure --prefix=/opt/dionaea
        sudo make
        sudo make install
        sudo ldconfig
        
    *   Install cython :
*       cd ~/src
        sudo wget https://files.pythonhosted.org/packages/88/c7/9f6270a2b68a9e2be1f1e732eff9a1b12f230f5ec8e55a20bfd1b24580a0/Cython-0.21.tar.gz
        sudo tar xfz Cython-0.21.tar.gz
        cd Cython-0.21
        sudo /opt/dionaea/bin/python3 setup.py install
        sudo ldconfig
        
    *   Install finger printing p0f :
*       sudo apt-get install p0f -y
        cd /
        sudo mkdir nonexistent
        sudo chown -R nobody:nogroup nonexistent
        sudo mkdir /var/p0f
        sudo p0f -i eth0 -u nobody -Q /tmp/p0f.sock -q -l -d -o /var/p0f/p0f.log
        sudo chown nobody:nogroup /tmp/p0f.sock

    *   note => cek source input trafic sebagai -i pada p0f disini eth0, 
        untuk cek source network gunakan "ifconfig".

    *   test proses p0f
*       ps -ef | grep p0f

    *   hasilnya :
*       nobody  4727     1  0 23:22 ?      00:00:00 p0f -i eth0 -u nobody -Q /tmp/p0f.sock -q -l -d -o /var/p0f/p0f.log
        1000    4734  1785  0 23:24 pts/0  00:00:00 grep --color=auto p0f
        
8. Install dionaea :

*       cd ~/src
        sudo git clone https://github.com/rep/dionaea.git dionaea
        cd dionaea
        sudo autoreconf -vi
        sudo ./configure --with-lcfg-include=/opt/dionaea/include/ \
             --with-lcfg-lib=/opt/dionaea/lib/ \
             --with-python=/opt/dionaea/bin/python3.2 \
             --with-cython-dir=/opt/dionaea/bin \
             --with-udns-include=/opt/dionaea/include/ \
             --with-udns-lib=/opt/dionaea/lib/ \
             --with-emu-include=/opt/dionaea/include/ \
             --with-emu-lib=/opt/dionaea/lib/ \
             --with-gc-include=/usr/include/gc \
             --with-ev-include=/opt/dionaea/include \
             --with-ev-lib=/opt/dionaea/lib \
             --with-nl-include=/opt/dionaea/include \
             --with-nl-lib=/opt/dionaea/lib/ \
             --with-curl-config=/usr/bin/ \
             --with-pcap-include=/opt/dionaea/include \
             --with-pcap-lib=/opt/dionaea/lib/
        sudo make
        sudo make install
        sudo ldconfig

    *   set permision :
*       sudo chown -R nobody:nogroup /opt/dionaea/var/dionaea
        sudo chown -R nobody:nogroup /opt/dionaea/var/log

    *   update dionaea :
*       sudo git pull;
        sudo make clean install

    *   pastikan konfigurasi terupdate
*       cd /opt/dionaea/etc/dionaea

        diff dionaea.conf dionaea.conf.dist

    *   start dionaea
*       /opt/dionaea/bin/dionaea -u nobody -g nogroup 
        -c /opt/dionaea/etc/dionaea/dionaea.conf 
        -w /opt/dionaea -p /opt/dionaea/var/dionaea.pid -D

    *   cek prosesnya
*       sudo ps -ef | grep dionaea
       
    *   hasilnya :
*       nobody  1654     1  2 15:55 ?       00:00:01 /opt/dionaea/bin/dionaea -u nobody -g nogroup -c /opt/dionaea/etc/dionaea/dionaea.conf -w /opt/dionaea -p /opt/dionaea/var/dionaea.pid -D
        root    1658  1654  0 15:55 ?       00:00:00 /opt/dionaea/bin/dionaea -u nobody -g nogroup -c /opt/dionaea/etc/dionaea/dionaea.conf -w /opt/dionaea -p /opt/dionaea/var/dionaea.pid -D
        1000    1934  1831  0 15:56 pts/0   00:00:00 grep --color=auto dionaea

    *   cek status network
*       sudo netstat -tnlp | grep dionaea

    *   hasilnya :
*       tcp        0      0 172.16.195.170:1433     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:1433          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:443      0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:443           0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:445      0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:445           0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:5060     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:5060          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:5061     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:5061          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:135      0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:135           0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:3306     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:42       0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:3306          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:42            0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:80       0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:80            0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:21       0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:21            0.0.0.0:*       LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:1433 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f:443 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f:445 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:5060 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:5061 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f:135 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:3306 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f::42 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f::80 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f::21 :::*            LISTEN      1654/dionaea

    *   log file ada di :
*       cd /opt/dionaea/var/log

    *   log filenya terdiri dari :
*       dionaea-errors.log
        dionaea.log 

    *   captured file dan log ada di :
*       cd /opt/dionaea/var/dionaea
       
    *   terdiri dari :
*       binaries
        bistreams
        logsql.sqlite
        sipaccounts.sqlite
        vtcache.sqlite
        wwwroot

9. Menjalankan saat startup :
*       sudo nano /opt/start.sh

    *   isi dengan :
*       /opt/dionaea/bin/dionaea -u nobody -g nogroup 
        -c /opt/dionaea/etc/dionaea/dionaea.conf 
        -w /opt/dionaea -p /opt/dionaea/var/dionaea.pid -D

    *   exit dari editor dan atur permision
*       cd /opt/
        chmod 655 start.sh

    *   set start up
*       sudo nano /etc/rc.local

    *   isi dengan :
*       opt/start.sh
        exit 0

    *   exit dari editor dan reboot
*       sudo reboot

10. Instalasi manual selesai.    
 
<img width="1440" alt="Screen Shot 2020-03-26 at 16 01 15" src="https://user-images.githubusercontent.com/33028642/77649718-e5d8e680-6f9c-11ea-8823-f645637d83a0.png">


**B. Instalasi otomatis dionaea di VM ubuntu 12.04 server**

1. Buat VM dari iso ubuntu 12.04 server;

2. Setelah selesai instalasi os, jalankan update sbb (pastikan poin 2 ini tidak ada masalah, baru lanjut ke poin berikutnya) :

*       sudo apt-get update
        sudo apt-get upgrade
        sudo apt-get dist-upgrade
        
    *   Jika terdapat error lakukah langkah dibawah ini :
    
*       sudo apt-get update
        sudo apt-get install -f
        sudo rm -rf /var/lib/apt/lists/*
        sudo apt-get update
        sudo apt-get update --fix-missing (Jika masing ada keterangan --fix-missing)
        sudo apt-get update
        sudo apt-get upgrade
        sudo apt-get dist-upgrade
        sudo apt-get autoremove
        sudo reboot
 
3. Download file build.sh dan buat permisionnya :
 
*       sudo wget https://raw.githubusercontent.com/tom9un/dionaea-honeypot/master/build.sh
        sudo chmod 655 build.sh

4. Jalankan :

*       sudo ./build.sh

5. Setting parameter hanya diawal untuk inputan i p0f, berupa network interface yang akan dijadikan input monitoring, pastikan tidak salah saat menulisnya, umumnya adalah eth0 atau cek kembali dengan ifconfig.

6. Setelah proses build selesai dan boot otomatis, lakukan pengecekan proses/status service dan kelengkapan file log sbb :

    *   test proses p0f
*       ps -ef | grep p0f

    *   hasilnya :
*       nobody  4727     1  0 23:22 ?      00:00:00 p0f -i eth0 -u nobody -Q /tmp/p0f.sock -q -l -d -o /var/p0f/p0f.log
        1000    4734  1785  0 23:24 pts/0  00:00:00 grep --color=auto p0f
        
    *   cek prosesnya dionaea
*       sudo ps -ef | grep dionaea
       
    *   hasilnya :
*       nobody  1654     1  2 15:55 ?       00:00:01 /opt/dionaea/bin/dionaea -u nobody -g nogroup -c /opt/dionaea/etc/dionaea/dionaea.conf -w /opt/dionaea -p /opt/dionaea/var/dionaea.pid -D
        root    1658  1654  0 15:55 ?       00:00:00 /opt/dionaea/bin/dionaea -u nobody -g nogroup -c /opt/dionaea/etc/dionaea/dionaea.conf -w /opt/dionaea -p /opt/dionaea/var/dionaea.pid -D
        1000    1934  1831  0 15:56 pts/0   00:00:00 grep --color=auto dionaea

    *   cek status network dionaea
*       sudo netstat -tnlp | grep dionaea

    *   hasilnya :
*       tcp        0      0 172.16.195.170:1433     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:1433          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:443      0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:443           0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:445      0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:445           0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:5060     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:5060          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:5061     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:5061          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:135      0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:135           0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:3306     0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:42       0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:3306          0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:42            0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:80       0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:80            0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 172.16.195.170:21       0.0.0.0:*       LISTEN      1654/dionaea    
        tcp        0      0 127.0.0.1:21            0.0.0.0:*       LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:1433 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f:443 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f:445 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:5060 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:5061 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f:135 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8:3306 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f::42 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f::80 :::*            LISTEN      1654/dionaea    
        tcp6       0      0 fe80::20c:29ff:fe8f::21 :::*            LISTEN      1654/dionaea

    *   log file ada di :
*       cd /opt/dionaea/var/log

    *   log filenya terdiri dari :
*       dionaea-errors.log
        dionaea.log 

    *   captured file dan log ada di :
*       cd /opt/dionaea/var/dionaea
       
    *   terdiri dari :
*       binaries
        bistreams
        logsql.sqlite
        sipaccounts.sqlite
        vtcache.sqlite
        wwwroot

7. Instalasi selesai.
