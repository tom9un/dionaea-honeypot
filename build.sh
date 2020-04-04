#!/bin/bash
Hijau=$(tput setaf 2)
Kuning=$(tput setaf 3)
Default=$(tput setaf 7)
cd ~/
sudo cat << END >> .profile
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
END
echo "${Kuning}Setting Parameter Awal untuk P0f${Default}"
echo ""
ifconfig
echo "Masukan Network Interface untuk inputan p0f [eth0, wlp6s0 atau vboxnet0, cek hasil 'ifconfig' diatas] :"
merah=$(tput setaf 1)
input=false
while [ "$input" != "true" ];
do
   read inputan
     if [ "$inputan" != "" ];
     then
        echo "${merah}Input untuk p0f =>${Default} " $inputan
        echo "${merah}Setelah instalasi selesai, test proses/service p0f terlebih dahulu, jika ada kesalahan...lakukan config manual pada line 90${Default}"
        input=true
     else
        echo "${merah}Masukan yang benar!${Default}"
        echo "Masukan Network Interface untuk inputan p0f [eth0, wlp6s0 atau vboxnet0, cek hasil 'ifconfig' diatas] :"
     fi
done
echo "${Hijau}#-done${Default}"
echo ""
# Install Depedencies untuk kebutuhan aplikasi
echo "${Kuning}Instalasi Depedencies${Default}"
sudo apt-get install libudns-dev libglib2.0-dev libssl-dev libcurl4-openssl-dev libreadline-dev libsqlite3-dev python-dev libtool automake autoconf build-essential subversion git-core flex bison pkg-config libgc-dev libgc1c2 sqlite3 python-geoip sqlite python-pip -y
echo "${Hijau}#-done${Default}"
echo ""
# Buat Folder dionaea
echo "${Kuning} Menyiapkan Folder${Default}"
sudo mkdir /opt/dionaea
# Buat Folder penampung instalasi
sudo mkdir ~/src
echo "${Hijau}#-done${Default}"
echo ""
# Clone Dionaea dan paket2 yang dibutuhkan
echo "${Kuning}Cloning Aplikasi${Default}"
cd ~/src
sudo git clone https://github.com/tom9un/dionaea-honeypot.git dionaea
echo "${Hijau}#-done${Default}"
echo ""
# Instalasi paket Liblcfg
echo "${Kuning}Instalasi Paket Liblcfg${Default}"
cd dionaea/liblcfg/code
sudo autoreconf -vi
sudo ./configure --prefix=/opt/dionaea
sudo make install
sudo ldconfig
echo "${Hijau}#-done${Default}"
echo ""
cd ..
cd ..
# Install paket Libemu
echo "${Kuning}Instalasi Paket Libemu${Default}"
cd libemu
sudo autoreconf -vi
sudo ./configure --prefix=/opt/dionaea
sudo make install
sudo ldconfig
echo "${Hijau}#-done${Default}"
echo ""
cd ..
echo "${Kuning}Instalasi Libnl${Default}"
sudo apt-get install libnl-3-dev libnl-genl-3-dev libnl-nf-3-dev libnl-route-3-dev -y
echo "${Hijau}#-done${Default}"
echo ""
# Install paket Libev
echo "${Kuning}Instalasi Paket Libev${Default}"
cd libev-4.33
sudo ./configure --prefix=/opt/dionaea
sudo make install
sudo ldconfig
echo "${Hijau}#-done${Default}"
echo ""
cd ..
echo "${Kuning}Instalasi readline${Default}"
sudo apt-get install libreadline6 libreadline6-dev -y
echo "${Hijau}#-done${Default}"
echo ""
# Install Python 3.2.2
echo "${Kuning}Instalasi Python 3.2.2${Default}"
cd Python-3.2.2
sudo ./configure --enable-shared --prefix=/opt/dionaea --with-computed-gotos --enable-ipv6 LDFLAGS="-Wl,-rpath=/opt/dionaea/lib/ -L/usr/lib/x86_64-linux-gnu/"
sudo make
sudo make install
sudo ldconfig
echo "${Hijau}#-done${Default}"
echo ""
cd ..
echo "${Kuning}Instalasi Curl${Default}"
sudo apt-get install curl -y
echo "${Hijau}#-done${Default}"
echo ""
# Install Libpcap
echo "${Kuning}Instalasi Libpcap${Default}"
cd libpcap-1.6.2
sudo ./configure --prefix=/opt/dionaea
sudo make
sudo make install
sudo ldconfig
echo "${Hijau}#-done${Default}"
echo ""
cd ..
# Install Cython
echo "${Kuning}Instalasi Cython${Default}"
cd Cython-0.21
sudo /opt/dionaea/bin/python3 setup.py install
sudo ldconfig
echo "${Hijau}#-done${Default}"
echo ""
cd
# Install Finger Printing P0f
echo "${Kuning}Instalasi P0f${Default}"
sudo apt-get install p0f -y
cd /
sudo mkdir nonexistent
sudo chown -R nobody:nogroup nonexistent
sudo mkdir /var/p0f
sudo p0f -i $inputan -u nobody -Q /tmp/p0f.sock -q -l -d -o /var/p0f/p0f.log
sudo chown nobody:nogroup /tmp/p0f.sock
echo "${Hijau}#-done${Default}"
echo ""
# Instalasi dionaea
echo "${Kuning}Instalasi Dionaea${Default}"
cd ~/src/dionaea/
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
echo "${Hijau}#-done${Default}"
echo ""
# Set permision
echo "${Kuning}Set Permision${Default}"
sudo chown -R nobody:nogroup /opt/dionaea/var/dionaea
sudo chown -R nobody:nogroup /opt/dionaea/var/log
echo "${Hijau}#-done${Default}"
echo ""
# update
echo "${Kuning}Updating Instalasi${Default}"
sudo git pull;
sudo make clean install
echo "${Hijau}#-done${Default}"
echo ""
cd
echo "${Kuning}Membuat Start UP${Default}"
cd /opt/
sudo cat << END > start.sh
/opt/dionaea/bin/dionaea -u nobody -g nogroup -c /opt/dionaea/etc/dionaea/dionaea.conf -w /opt/dionaea -p /opt/dionaea/var/dionaea.pid -D
sudo p0f -i $inputan -u nobody -Q /tmp/p0f.sock -q -l -d -o /var/p0f/p0f.log
END
sudo chmod 655 start.sh
cd
cd /etc/
sudo cat << END > rc.local

END
sudo cat << END > rc.local
#!/bin/sh -e
opt/start.sh
exit 0
END
echo "${Hijau}#-done${Default}"
sudo reboot
