FROM linuxkonsult/kali-metasploit:latest
RUN apt-get update && apt-get install -y \
  mariadb-client

COPY tests.sh tests.sh

CMD ["bin/bash", "tests.sh"]
