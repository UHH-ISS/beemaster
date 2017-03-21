#!/usr/bin/env bash
DIONAEA_HOST=${DIONAEA_HOST:-dionaea}
ELASTIC_HOST=${ELASTIC_HOST:-es-master}
ELASTIC_INDEX=${ELASTIC_INDEX:-logstash-*}
SLEEP_TIME=${SLEEP_TIME:-90s}
PASSED_COUNT=0
FAILED_COUNT=0
# Wait for all containers to start. Change this accordingly.
sleep $SLEEP_TIME
# Set test timestamp
EPOCH_TIME=$(printf '%(%s)T\n' -1)

# HTTP access
echo 'Testing HTTP access (port 80)'
curl http://$DIONAEA_HOST:80

# HTTPS access
echo 'Testing HTTPS access (port 443)'
curl -k https://$DIONAEA_HOST:443

# Blackhole access - Telnet
echo 'Testing Blackhole acces - Telnet (port 23)'
echo blackhole-telnet-test | ncat -i 5s $DIONAEA_HOST 23

# Blackhole access - DNS TCP
echo 'Testing Blackhole access - DNS TCP (port 53)'
echo blackhole-dns-tcp-test | ncat -i 5s $DIONAEA_HOST 53

# Blackhole access - DNS UDP
echo 'Testing Blackhole access - DNS UDP (port 53)'
echo blackhole-dns-udp-test | ncat -u -i 5s $DIONAEA_HOST 53

# Blackhole access - NTP
echo 'Testing Blackhole access - NTP UDP (port 123)'
echo blackhole-ntp-test | ncat -u -i 5s $DIONAEA_HOST 123

# Mysql access
echo 'Testing MySQL access (port 3306)'
mysql -h $DIONAEA_HOST -u mysql-test -Bse "mysql-test"

# FTP test
echo 'Testing FTP access (port 21)'
curl -u ftp-testuser:ftp-testpw ftp://$DIONAEA_HOST

# SMB test

msfconsole -x "use windows/smb/ms10_061_spoolss;\
  set RHOST $DIONAEA_HOST;\
  set PNAME XPSPrinter;\
  set RPORT 445;\
  exploit"

# Sleep for a few secs
sleep 20s

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_access/_count?default_operator=AND&q=local_port:80+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]]; then
        echo -e "HTTP (80/tcp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"
else
        echo -e "HTTP (80/tcp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"
fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_access/_count?default_operator=AND&q=local_port:443+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]]; then
        echo -e "HTTPS (443/tcp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "HTTPS (443/tcp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_access/_count?default_operator=AND&q=local_port:23+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_blackhole/_count?default_operator=AND&q=input:"blackhole-telnet-test"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]]; then
        echo -e "Blackhole Telnet (23/tcp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "Blackhole Telnet (23/tcp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_access/_count?default_operator=AND&q=local_port:53+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_blackhole/_count?default_operator=AND&q=input:"blackhole-dns-tcp-test"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]]; then
        echo -e "Blackhole DNS (53/tcp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "Blackhole DNS (53/tcp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_blackhole/_count?default_operator=AND&q=input:"blackhole-dns-udp-test"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]]; then
        echo -e "Blackhole DNS (53/udp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "Blackhole DNS (53/udp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_blackhole/_count?default_operator=AND&q=input:"blackhole-ntp-test"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]]; then
        echo -e "Blackhole NTP (123/udp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "Blackhole NTP (123/udp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_access/_count?default_operator=AND&q=local_port:3306+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_login/_count?default_operator=AND&q=username:"mysql-test"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_mysql_command/_count?default_operator=AND&q=command:"mysql-test"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] ; then
        echo -e "MySQL (3306/tcp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "MySQL (3306/tcp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_access/_count?default_operator=AND&q=local_port:21+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_login/_count?default_operator=AND&q=username:"ftp-testuser"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_ftp/_count?default_operator=AND&q=command:"USER"+arguments:"ftp-testuser"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] ; then
        echo -e "FTP (21/tcp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "FTP (21/tcp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi

if [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_access/_count?default_operator=AND&q=local_port:445+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_download_complete/_count?default_operator=AND&q=origin:"dionaea.download.complete.hash"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_download_complete/_count?default_operator=AND&q=origin:"dionaea.download.complete.unique"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_download_offer/_count?default_operator=AND&q=origin:"dionaea.download.complete"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_download_offer/_count?default_operator=AND&q=origin:"dionaea.download.offer"+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_smb_bind/_count?default_operator=AND&q=local_port:445+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]] && \
    [[ $(curl --globoff -s -XGET $ELASTIC_HOST':9200/'$ELASTIC_INDEX'/dionaea_smb_request/_count?default_operator=AND&q=local_port:445+ts:['$EPOCH_TIME'+TO+*]&filter_path=count' | grep -Eo '[0-9]+') -ge 1 ]]; then

        echo -e "SMB (445/tcp) - \e[32mpassed\e[0m"
        let "PASSED_COUNT++"

else
        echo -e "SMB (445/tcp) - \e[31mfailed\e[0m"
        let "FAILED_COUNT++"

fi
echo ""
echo "------------------------------------------------------------------------"
echo -e "Tests done! \e[32mPASSED\e[0m: $PASSED_COUNT, \e[31mFAILED\e[0m: $FAILED_COUNT"
echo "Use CTRL-C or docker-compose down to exit"
