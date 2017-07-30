#!/bin/bash
#GOAL: To document how to build a clone of the original firmware using lede 17
#TODO: Clean up descriptions, provide links to the manual pages, remove cruft, automate more

set -x


sudo apt-get install subversion g++ zlib1g-dev build-essential git python -y
sudo apt-get install libncurses5-dev gawk gettext unzip file libssl-dev wget -y
sudo apt-get install ccache -y
sudo apt-get install quilt -y


ccache -M 0
export PATH="/usr/lib/ccache/bin/:$PATH"

#WORK_DIR=$PWD
export WORK_DIR=$PWD






rm -rf $WORK_DIR/lede



#Get the LEDE source code:

git clone https://git.lede-project.org/source.git lede
cd $WORK_DIR/lede

#This is the <buildroot dir>
#$WORK_DIR/lede

#Update package feeds

./scripts/feeds update -a
./scripts/feeds install -a


#Insert custom files
#In case you want to include some custom configuration files, the correct place to put them is:
#<buildroot dir>/files/

#For example, let's say that you want an image with a custom /etc/config/firewall or a custom etc/#sysctl.conf, then create this files as:
#<buildroot dir>/files/etc/config/firewall
#<buildroot dir>/files/etc/sysctl.conf

#E.g. if your <buildroot dir> is ~/source and you want some files to be copied into firmware image's /etc/#config directory, the correct place to put them is ~/source/files/etc/config .


#This enables wifi
########## /etc/uci-defaults/98_kksp3
#files/etc/uci-defaults/98_kksp3

mkdir -p $WORK_DIR/lede/files/etc/uci-defaults/

cat >> $WORK_DIR/lede/files/etc/uci-defaults/98_kksp3 << XEOFX
uci set wireless.default_radio0.ssid=kksp3
uci delete wireless.radio0.disabled
uci delete network.lan.type # not bridged
uci set network.lan.ifname=wlan0
uci commit

mkdir -p /etc/config

#pulled from original firmware
cat >> /etc/config/system << EOF
config restorefactory
        option button 'reset'
        option action 'pressed'
        option timeout '2'

config led
        option name 'flashing'
        option sysfs 'tp-link:blue:config'
        option trigger 'timer'
        option delayon '800'
        option delayoff '800'

config led
        option name 'Relay'
        option sysfs 'tp-link:blue:relay'
        option trigger 'none'
        option default '1'
EOF

XEOFX

mkdir -p $WORK_DIR/lede/files/etc/rc.button
base64 -d > $WORK_DIR/lede/files/etc/rc.button/reset << XEOFX
IyEvYmluL3NoCgouIC9saWIvZnVuY3Rpb25zLnNoCgpPVkVSTEFZPSIkKCBncmVwICcgL292ZXJs
YXkgJyAvcHJvYy9tb3VudHMgKSIKCmNhc2UgIiRBQ1RJT04iIGluCnByZXNzZWQpCglbIC16ICIk
T1ZFUkxBWSIgXSAmJiByZXR1cm4gMAoKCVNXPSQodWNpIGdldCBzeXN0ZW0uQGxlZFstMV0uZGVm
YXVsdCkKCVsgJFNXID09ICcwJyBdICYmIHVjaSBzZXQgc3lzdGVtLkBsZWRbLTFdLmRlZmF1bHQ9
MQoJWyAkU1cgPT0gJzAnIF0gfHwgdWNpIHNldCBzeXN0ZW0uQGxlZFstMV0uZGVmYXVsdD0wCgl1
Y2kgY29tbWl0CgkvZXRjL2luaXQuZC9sZWQgcmVzdGFydAoJcmV0dXJuIDUKOzsKcmVsZWFzZWQp
CglpZiBbICIkU0VFTiIgLWd0IDUgLWEgLW4gIiRPVkVSTEFZIiBdCgl0aGVuCgkJZWNobyAiRkFD
VE9SWSBSRVNFVCIgPiAvZGV2L2NvbnNvbGUKCQlqZmZzMnJlc2V0IC15ICYmIHJlYm9vdCAmCglm
aQo7Owplc2FjCgpyZXR1cm4gMAo=

XEOFX

chmod a+x $WORK_DIR/lede/files/etc/rc.button/reset

cat $WORK_DIR/lede/files/etc/rc.button/reset













#switch cgi script
mkdir -p $WORK_DIR/lede/files/www/cgi-bin
base64 -d > $WORK_DIR/lede/files/www/cgi-bin/json.cgi << XEOFX
IyEvYmluL3NoCmVjaG8gJFFVRVJZX1NUUklORyA+IC90bXAvcXVlcnlfc3RyaW5nClZFUlNJT049
MC4wLjMKUkVMQVlfQ1RSTD0vc3lzL2NsYXNzL2xlZHMvdHAtbGluazpibHVlOnJlbGF5L2JyaWdo
dG5lc3MKSVBfQUREUkVTUz1gaWZjb25maWcgd2xhbjAgfCBzZWQgJzphO047JCFiYTtzL1xuLyIs
Ii9nJyB8IGdyZXAgLUUgLW8gJ1swLTldK1wuWzAtOV0rXC5bMC05XStcLlswLTldKycgfCBoZWFk
IC1uIDFgClRaPWBjYXQgL2V0Yy9UWmAKU1NJRD1gaXcgZGV2IHdsYW4wIGxpbmsgfCBncmVwIFNT
SUQgfCBhd2sgJ3sgcHJpbnQgJDIgfSdgCldJRklfU0lHTkFMPWBpdyBkZXYgd2xhbjAgbGluayB8
IGdyZXAgc2lnbmFsIHwgYXdrICd7IHByaW50ICQyIH0nYApXSUZJX0NIQU5ORUw9YGl3IGRldiB3
bGFuMCBpbmZvIHwgZ3JlcCBjaGFubmVsIHwgYXdrICd7IHByaW50ICQyIH0nYApNQUNBRERSPWBp
dyBkZXYgd2xhbjAgaW5mbyAgfCBncmVwIGFkZHIgfCBhd2sgJ3sgcHJpbnQgJDIgfSdgClVQVElN
RT1gdXB0aW1lIHwgYXdrIC1GICwgJ3sgcHJpbnQgJDEgfSdgCkxXUkFQUEVSPSIiClJXUkFQUEVS
PSIiCkNVUlJFTlRfU1RBVEU9YGNhdCAkUkVMQVlfQ1RSTGAKCmdldD0kKGVjaG8gIiRRVUVSWV9T
VFJJTkciIHwgc2VkIC1uICdzL14uKmdldD1cKFteJl0qXCkuKiQvXDEvcCcgfCBzZWQgInMvJTIw
LyAvZyIpCnNldD0kKGVjaG8gIiRRVUVSWV9TVFJJTkciIHwgc2VkIC1uICdzL14uKnNldD1cKFte
Jl0qXCkuKiQvXDEvcCcgfCBzZWQgInMvJTIwLyAvZyIpCm1pbnM9JChlY2hvICIkUVVFUllfU1RS
SU5HIiB8IHNlZCAtbiAncy9eLiptaW5zPVwoW14mXSpcKS4qJC9cMS9wJyB8IHNlZCAicy8lMjAv
IC9nIikKY2FuY2Vsam9iPSQoZWNobyAiJFFVRVJZX1NUUklORyIgfCBzZWQgLW4gJ3MvXi4qY2Fu
Y2Vsam9iPVwoW14mXSpcKS4qJC9cMS9wJyB8IHNlZCAicy8lMjAvIC9nIikKCmNhbGxiYWNrPSQo
ZWNobyAiJFFVRVJZX1NUUklORyIgfCBzZWQgLW4gJ3MvXi4qY2FsbGJhY2s9XChbXiZdKlwpLiok
L1wxL3AnIHwgc2VkICJzLyUyMC8gL2ciKQoKaWYgWyAhIC16ICRjYWxsYmFjayBdOyB0aGVuCiAg
TFdSQVBQRVI9IigiCiAgUldSQVBQRVI9IikiCmZpCgppZiBbICEgLXogJGNhbGxiYWNrIF07IHRo
ZW4KICBlY2hvICJDb250ZW50LVR5cGU6IGFwcGxpY2F0aW9uL2phdmFzY3JpcHQiCmVsc2UKICBl
Y2hvICJDb250ZW50LVR5cGU6IGFwcGxpY2F0aW9uL2pzb24iCmZpCmVjaG8gIkNhY2hlLUNvbnRy
b2w6IG5vLWNhY2hlLCBtdXN0LXJldmFsaWRhdGUiCmVjaG8gIkV4cGlyZXM6IFNhdCwgMjYgSnVs
IDE5OTcgMDU6MDA6MDAgR01UIgplY2hvCgpjYXNlICIkZ2V0IiBpbgogIHN0YXRlKQogICAgY2Fz
ZSAiJENVUlJFTlRfU1RBVEUiIGluCiAgICAgIDApIGVjaG8gIiRjYWxsYmFjayRMV1JBUFBFUntc
InN0YXRlXCI6XCJvZmZcIn0kUldSQVBQRVIiCiAgICAgIDs7CiAgICAgIDEpIGVjaG8gIiRjYWxs
YmFjayRMV1JBUFBFUntcInN0YXRlXCI6XCJvblwifSRSV1JBUFBFUiIKICAgICAgOzsKICAgIGVz
YWMKICA7OwogIGpvYnMpICAjIGxpc3QgYWxsIHRoZSBzY2hlZHVsZWQgam9icwogICAgICBpPTAK
ICAgICAgZWNobyAiJGNhbGxiYWNrJExXUkFQUEVSe1wiam9ic1wiOlsiCiAgICAgIGF0cSB8IHdo
aWxlIHJlYWQgbGluZTsgZG8KICAgICAgICBqb2JfaWQ9JChlY2hvICRsaW5lIHwgYXdrICd7IHBy
aW50ICQxIH0nKQogICAgICAgIGpvYl9kYXRlPSQoZWNobyAkbGluZSB8IGF3ayAneyBwcmludCAk
NSwgJDIsICQzLCAkNCwgJDYgfScpCiAgICAgICAgam9iX3F1ZXVlPSQoZWNobyAkbGluZSB8IGF3
ayAneyBwcmludCAkNyB9JykKICAgICAgICBqb2JsaXN0PSJ7XCJqb2JpZFwiOiRqb2JfaWQsXCJx
dWV1ZVwiOlwiJGpvYl9xdWV1ZVwiLFwiZGF0ZVwiOlwiJGpvYl9kYXRlXCJ9IgogICAgICAgIGlm
IFsgJGkgLW5lIDAgXTsgdGhlbgogICAgICAgICAgZWNobyAiLCI7CiAgICAgICAgZmkKICAgICAg
ICBpPTEKICAgICAgICBlY2hvICIkam9ibGlzdCIKICAgICAgZG9uZQogICAgICBlY2hvICJdfSRS
V1JBUFBFUiIKICA7Owplc2FjCgpjYXNlICIkc2V0IiBpbgogIG9uKQogICAgaWYgWyAhIC16ICRt
aW5zIF07IHRoZW4KICAgICAgZWNobyAiZWNobyAxID4gJFJFTEFZX0NUUkwiIHwgYXQgbm93ICsg
JG1pbnMgbWludXRlIC1NIC1xIGIKICAgIGVsc2UKICAgICAgZWNobyAxID4gJFJFTEFZX0NUUkwK
ICAgIGZpCiAgICBlY2hvICIkY2FsbGJhY2skTFdSQVBQRVJ7XCJva1wiOnRydWV9JFJXUkFQUEVS
IgogIDs7CiAgb2ZmKQogICAgaWYgWyAhIC16ICRtaW5zIF07IHRoZW4KICAgICAgZWNobyAiZWNo
byAwID4gJFJFTEFZX0NUUkwiIHwgYXQgbm93ICsgJG1pbnMgbWludXRlIC1NIC1xIGMKICAgIGVs
c2UKICAgICAgZWNobyAwID4gJFJFTEFZX0NUUkwKICAgIGZpCiAgICBlY2hvICIkY2FsbGJhY2sk
TFdSQVBQRVJ7XCJva1wiOnRydWV9JFJXUkFQUEVSIgogIDs7CiAgdG9nZ2xlKQogICAgY2FzZSAi
JENVUlJFTlRfU1RBVEUiIGluCiAgICAgIDApCiAgICAgICAgaWYgWyAhIC16ICRtaW5zIF07IHRo
ZW4KICAgICAgICAgIGVjaG8gImVjaG8gMSA+ICRSRUxBWV9DVFJMIiB8IGF0IG5vdyArICRtaW5z
IG1pbnV0ZSAtTSAtcSBkCiAgICAgICAgZWxzZQogICAgICAgICAgZWNobyAxID4gJFJFTEFZX0NU
UkwKICAgICAgICBmaQogICAgICA7OwogICAgICAxKQogICAgICAgIGlmIFsgISAteiAkbWlucyBd
OyB0aGVuCiAgICAgICAgICBlY2hvICJlY2hvIDAgPiAkUkVMQVlfQ1RSTCIgfCBhdCBub3cgKyAk
bWlucyBtaW51dGUgLU0gLXEgZAogICAgICAgIGVsc2UKICAgICAgICAgIGVjaG8gMCA+ICRSRUxB
WV9DVFJMCiAgICAgICAgZmkKICAgICAgOzsKICAgIGVzYWMKICAgIGVjaG8gIiRjYWxsYmFjayRM
V1JBUFBFUntcIm9rXCI6dHJ1ZX0kUldSQVBQRVIiCiAgOzsKZXNhYwoKCmlmIFsgIiRjYW5jZWxq
b2IiIC1nZSAwIF0gMj4gL2Rldi9udWxsOyB0aGVuCiAgYXRybSAiJGNhbmNlbGpvYiIKICBlY2hv
ICIkY2FsbGJhY2skTFdSQVBQRVJ7XCJva1wiOnRydWV9JFJXUkFQUEVSIgpmaQoKaWYgWyAteiAi
JGdldCIgXSAmJiBbIC16ICIkc2V0IiBdOyB0aGVuCiAgZWNobyAiJGNhbGxiYWNrJExXUkFQUEVS
e1wiaW5mb1wiOntcIm5hbWVcIjpcImthbmt1bi1qc29uXCIsXCJ2ZXJzaW9uXCI6XCIkVkVSU0lP
TlwiLFwiaXBBZGRyZXNzXCI6XCIkSVBfQUREUkVTU1wiLFwibWFjYWRkclwiOlwiJE1BQ0FERFJc
IixcInNzaWRcIjpcIiRTU0lEXCIsXCJjaGFubmVsXCI6XCIkV0lGSV9DSEFOTkVMXCIsXCJzaWdu
YWxcIjpcIiRXSUZJX1NJR05BTFwiLFwidGltZXpvbmVcIjpcIiRUWlwiLFwidXB0aW1lXCI6XCIk
VVBUSU1FXCJ9LFwibGlua3NcIjp7XCJtZXRhXCI6e1wic3RhdGVcIjpcImh0dHA6Ly8kSVBfQURE
UkVTUy9jZ2ktYmluL2pzb24uY2dpP2dldD1zdGF0ZVwifSxcImFjdGlvbnNcIjp7XCJvblwiOlwi
aHR0cDovLyRJUF9BRERSRVNTL2NnaS1iaW4vanNvbi5jZ2k/c2V0PW9uXCIsXCJvbmRlbGF5XCI6
XCJodHRwOi8vJElQX0FERFJFU1MvY2dpLWJpbi9qc29uLmNnaT9zZXQ9b24mbWlucz02MFwiLFwi
b2ZmXCI6XCJodHRwOi8vJElQX0FERFJFU1MvY2dpLWJpbi9qc29uLmNnaT9zZXQ9b2ZmXCIsXCJv
ZmZkZWxheVwiOlwiaHR0cDovLyRJUF9BRERSRVNTL2NnaS1iaW4vanNvbi5jZ2k/c2V0PW9mZiZt
aW5zPTYwXCJ9fX0kUldSQVBQRVIiCmZpCg==

XEOFX

chmod -R 0755 $WORK_DIR/lede/files/www/cgi-bin



#switch html page
base64 -d > $WORK_DIR/lede/files/www/index.html << XEOFX
PGh0bWw+DQoNCjxoZWFkPg0KPG1ldGEgbmFtZT0idmlld3BvcnQiIGNvbnRlbnQ9IndpZHRoPWRl
dmljZS13aWR0aCwgaW5pdGlhbC1zY2FsZT0xIj4NCjwvaGVhZD4NCg0KPGJvZHk+DQoNCjxmb3Jt
IGFjdGlvbj0iL2NnaS1iaW4vanNvbi5jZ2kiIHRhcmdldD0iZHVtbXlmcmFtZSI+DQogIDxpbnB1
dCB0eXBlPSJzdWJtaXQiIG5hbWU9InNldCIgdmFsdWU9Im9uIiBzdHlsZT0id2lkdGg6IDEwMCU7
IHBhZGRpbmctdG9wOiAxMHB4OyBwYWRkaW5nLWJvdHRvbTogMTBweDsiPg0KICA8aW5wdXQgdHlw
ZT0ic3VibWl0IiBuYW1lPSJzZXQiIHZhbHVlPSJvZmYiIHN0eWxlPSJ3aWR0aDogMTAwJTsgcGFk
ZGluZy10b3A6IDEwcHg7IHBhZGRpbmctYm90dG9tOiAxMHB4OyI+DQogIDxpbnB1dCB0eXBlPSJz
dWJtaXQiIG5hbWU9InNldCIgdmFsdWU9InRvZ2dsZSIgc3R5bGU9IndpZHRoOiAxMDAlOyBwYWRk
aW5nLXRvcDogMTBweDsgcGFkZGluZy1ib3R0b206IDEwcHg7Ij4NCjwvZm9ybT4NCg0KPGEgc3R5
bGU9ImNvbG9yOiBibGFjazsgZm9udC1mYW1pbHk6IGFyaWFsLCBoZWx2ZXRpY2EsIHNhbnMtc2Vy
aWY7IiBocmVmPSIvY2dpLWJpbi9sdWNpIj5MdUNJIC0gTHVhIENvbmZpZ3VyYXRpb24gSW50ZXJm
YWNlPC9hPg0KDQo8aWZyYW1lIHdpZHRoPSIwIiBoZWlnaHQ9IjAiIGJvcmRlcj0iMCIgbmFtZT0i
ZHVtbXlmcmFtZSIgaWQ9ImR1bW15ZnJhbWUiPjwvaWZyYW1lPg0KPC9ib2R5Pg0KPC9odG1sPg0K

XEOFX






#Making kernel patch

#sudo apt-get install quilt -y

#Set quilt defauts

cat > ~/.quiltrc << EOF
QUILT_DIFF_ARGS="--no-timestamps --no-index -p ab --color=auto"
QUILT_REFRESH_ARGS="--no-timestamps --no-index -p ab"
QUILT_SERIES_ARGS="--color=auto"
QUILT_PATCH_OPTS="--unified"
QUILT_DIFF_OPTS="-p"
EDITOR="nano"
EOF





cp $WORK_DIR/940-kksp3.patch $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*/patches/platform/940-kksp3.patch

cat $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*/patches/platform/940-kksp3.patch




cp $WORK_DIR/940-kksp3.patch $WORK_DIR/lede/target/linux/ar71xx/patches-4.4/940-kksp3.patch 

cat $WORK_DIR/lede/target/linux/ar71xx/patches-4.4/940-kksp3.patch






sleep 10




cd $WORK_DIR/lede

#Adding a new patch



echo If you want to build images for the KK-sp3, select:
echo Target System Atheros AR7xxx/AR9xxx
echo Target Profile TP-LINK TL-WR703N v1

read -p "Press any key to continue... " -n1 -s




make target/linux/{clean,prepare} V=s QUILT=1

#If you want to build images for the “TL-WR703N v1 Wifi-Router, select:
#Target System Atheros AR7xxx/AR9xxx
# Modify the installed set of packages
# maybe add luci
#Network -> Web Servers/Proxies -> uhttpd
#Exit and save changes




#base64 -d > $WORK_DIR/940-kksp3.patch  << XEOFX
#LS0tIGEvYXJjaC9taXBzL2F0aDc5L21hY2gtdGwtd3I3MDNuLmMKKysrIGIvYXJjaC9taXBzL2F0
#aDc5L21hY2gtdGwtd3I3MDNuLmMKQEAgLTIxLDcgKzIxLDkgQEAKICNpbmNsdWRlICJkZXYtd21h
#Yy5oIgogI2luY2x1ZGUgIm1hY2h0eXBlcy5oIgogCi0jZGVmaW5lIFRMX1dSNzAzTl9HUElPX0xF
#RF9TWVNURU0JMjcKKyNkZWZpbmUgVExfV1I3MDNOX0dQSU9fTEVEX1NZU1RFTQkyNAorI2RlZmlu
#ZSBUTF9XUjcwM05fR1BJT19MRURfUkVMQVkJMjYKKyNkZWZpbmUgVExfV1I3MDNOX0dQSU9fTEVE
#X0NPTkZJRwkyNwogI2RlZmluZSBUTF9XUjcwM05fR1BJT19CVE5fUkVTRVQJMTEKIAogI2RlZmlu
#ZSBUTF9XUjcwM05fR1BJT19VU0JfUE9XRVIJOApAQCAtNDUsNiArNDcsMTQgQEAgc3RhdGljIHN0
#cnVjdCBncGlvX2xlZCB0bF93cjcwM25fbGVkc19ncAogCQkubmFtZQkJPSAidHAtbGluazpibHVl
#OnN5c3RlbSIsCiAJCS5ncGlvCQk9IFRMX1dSNzAzTl9HUElPX0xFRF9TWVNURU0sCiAJCS5hY3Rp
#dmVfbG93CT0gMSwKKwl9LCB7CisJCS5uYW1lCQk9ICJ0cC1saW5rOmJsdWU6cmVsYXkiLAorCQku
#Z3BpbwkJPSBUTF9XUjcwM05fR1BJT19MRURfUkVMQVksCisJCS5hY3RpdmVfbG93CT0gMCwKKwl9
#LCB7CisJCS5uYW1lCQk9ICJ0cC1saW5rOmJsdWU6Y29uZmlnIiwKKwkJLmdwaW8JCT0gVExfV1I3
#MDNOX0dQSU9fTEVEX0NPTkZJRywKKwkJLmFjdGl2ZV9sb3cJPSAxLAogCX0sCiB9OwogCg==
#XEOFX

cp $WORK_DIR/940-kksp3.patch $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*/patches/platform/940-kksp3.patch

cat $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*/patches/platform/940-kksp3.patch




cp $WORK_DIR/940-kksp3.patch $WORK_DIR/lede/target/linux/ar71xx/patches-4.4/940-kksp3.patch 

cat $WORK_DIR/lede/target/linux/ar71xx/patches-4.4/940-kksp3.patch












sleep 10
#Change to the prepared source directory.

cd $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*



#also $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*/patches/platform maybe? 

#To add a completely new patch to an existing package example start with preparing the source directory:


#Apply all existing patches using quilt push.

quilt push -a



#After the changes are finished, they can be reviewed with the quilt diff command.

#quilt diff


#If the diff looks okay, proceed with quilt refresh to update the platform/940-kksp3.patch file with the #changes made.

quilt refresh





#Change back to the toplevel directory of the buildroot.

cd $WORK_DIR/lede



#To move the new patch file over to the buildroot, run update on the package:

make target/linux/update package/index V=s


#Finally rebuild the package to test the changes:

make target/linux/{clean,compile} package/index V=s

#If problems occur, the patch needs to be edited again to solve the issues. Refer to the section below to #learn how to edit existing patches.





























echo run make menuconfig and set target
read -p "Press any key to continue... " -n1 -s
make menuconfig

echo run make defconfig to set default config for build system and device
#read -p "Press any key to continue... " -n1 -s
make defconfig

echo make menuconfig and modify set of package
echo
echo You can also modify the installed set of packages
echo Webserver
echo "Network -> Web Servers/Proxies -> uhttpd"
echo Optional luci
echo "LuCI -> Collections -> luci"
echo Then exit saving the changes
echo

read -p "Press any key to continue... " -n1 -s
make menuconfig


# (save your changes in the text file mydiffconfig);

scripts/diffconfig.sh >mydiffconfig

#test files
cat $WORK_DIR/lede/files/etc/uci-defaults/98_kksp3
cat $WORK_DIR/lede/files/etc/config/system
cat $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*/arch/mips/ath79/mach-tl-wr703n.c
cat $WORK_DIR/lede/files/etc/rc.button/reset
cat $WORK_DIR/lede/target/linux/ar71xx/patches-4.4/940-kksp3.patch
cat $WORK_DIR/lede/build_dir/target-mips_24kc_musl/linux-ar71xx_generic/linux-4.4.*/patches/platform/940-kksp3.patch



#Now build the images. This may take some time:
#make

#make -j1 V=s
make -j2 V=s

#Afterwards, the images can be found in ./bin/targets/ar71xx/generic/ - done. 8-)
