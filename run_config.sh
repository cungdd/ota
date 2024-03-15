cd /etc/mosquitto
rm -rf passwd.txt
CONFIG_MQTT_PASSWD
mosquitto_passwd -U passwd.txt
rm -rf mosquitto.conf
echo -e "#Default listener
port 1883
allow_anonymous false
password_file /etc/mosquitto/passwd.txt" >> mosquitto.conf
/etc/init.d/mosquitto enable
/etc/init.d/mosquitto restart

read mac < /sys/class/net/eth0/address
MAC=$(echo "$mac" | awk '{print toupper($0)}')
Mac1=${MAC:12:2}
Mac2=${MAC:15:2}
temp="$Mac1$Mac2"

echo "$MAC"
touch /etc/crontabs/root
echo -e "0 8 * * * LOG">> /etc/crontabs/root
echo -e "0 3 */1 * * sleep 120 && /sbin/reboot -f">> /etc/crontabs/root
/etc/init.d/cron enable
/etc/init.d/cron start
sleep 3
uci set wireless.default_radio0.ssid="RD_HC_$temp"
uci set wireless.default_radio0.key='ABC123456'
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.disabled='0'
uci set wireless.radio0.disabled='0'
uci set system.@system[0].hostname="RD_HC_$temp"
uci set network.wan=interface
uci set network.wan.proto='dhcp'
uci set system.@system[0].zonename='Asia/Ho Chi Minh'
uci set system.@system[0].timezone='<+7>-7'
uci set network.wan.ifname='eth0'
uci set network.lan.macaddr="$MAC"
uci set network.lan.force_link='1'
uci set network.lan.ipaddr='10.10.10.1'
uci del network.lan.ifname
uci add dhcp domain
uci set dhcp.@domain[0].name="RD_HC_$temp"
uci set dhcp.@domain[0].ip='10.10.10.1'
uci commit
/etc/init.d/wireless restart
/etc/init.d/network restart
/etc/init.d/system restart
