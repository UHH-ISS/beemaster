# Integrationstest

Um den Durchstich zu testen, kann diese mit `Docker-Compose` erstellbare Testumgebung
verwendet werden. Überprüft wird, ob Zugriffe auf *Dionaea* korrekt in Elasticsearch
abgebildet werden, was die Fehlerfreiheit der Strecke
  Dionaea -> Connector ->
  Bro-Slave -> Bro-Master -> Logstash -> Elasticsearch
sicherstellt.

## Durchführung

Es sind mindestens 6 GiB RAM und 9 GiB Festplattenspeicher erforderlich, da alle
Container des Projekts lokal gestartet werden. Aktuell ist 
es erforderlich, die Dateien `dc-test.sh` und `dc-testing.yml` in den Ordner zu 
verschieben, der auch die Repositories `beemaster*` beinhaltet, sodass folgende 
Ordnerstruktur entsteht:

```
...
dc-test.sh
dc-testing.yml
 |- beemaster
 |- beemaster-bro
 |- beemaster-hp
 |- beemaster-cim
```

Zum Starten des Tests muss `./dc-test.sh` ausgeführt werden. Zusätzlich zu allen
bekannten Containern des Projekts wird ein *[Metasploit](https://github.com/UHH-ISS/beemaster-hp/blob/master/METASPLOIT.md)*-Container gestartet, der das
Skript `tests.sh` ausführt. Dieses Skript nutzt `curl`, `ncat`, `mysql` und Metasploit,
um Zugriffe auf *Dionaea* zu simulieren. Anschließend werden die Ergebnisse in Elasticsearch
mittels `curl` verifiziert.

Standardmäßig wird am Anfang des Skripts `sleep 90` ausgeführt, um zu verhindern,
dass die anderen Container noch nicht bereit sind. Dieser Wert muss ggf. angepasst werden. Dies
kann über die Umgebungsvariable `SLEEP_TIME` erfolgen.
Die Ergebnisse des Tests werden im Output von `Docker-Compose` in der Form `Testname - Ergebnis`
dargestellt.

## Konfiguration

Das Testskript kann mit den folgenden Umgebungsvariablen angepasst werden:

```yaml
$DIONAEA_HOST     # Default: dionaea
$ELASTIC_HOST     # Default: es-master
$ELASTIC_INDEX    # Default: logstash-*
$SLEEP_TIME       # Default: 90s
```

Die Variablen können dem Container mit der Anweisung `environment` in der Compose-Datei
übergeben werden:

```yaml
services:
  testing:
    build: beemaster/server/tests
    environment:
      - DIONAEA_HOST=new_dionaea_host
      - ELASTIC_HOST=new_elastic_host
      - ELASTIC_INDEX=new_elastic_index
      - SLEEP_TIME=120s
```
