# Dionaea

We suggest using *Dionaea* in a dockerized environment. The following sections describe how to use *Dionaea* with the Docker files provided in this repository.

The following topics will be discussed:
* [Run Dionaea](#run-dionaea)
* [Test Dionaea](#test-dionaea)
* [Configure Dionaea](#configure-dionaea)

## Run Dionaea

The following describes how to run *Dionaea* using Docker. Read the [official documentation](http://dionaea.readthedocs.io/en/latest/installation.html) if you are interested in running it locally.

### Run Docker container

Use the [run.sh](run.sh) script to build and run a Docker container with *Dionaea* installed and properly configured.

You could also use a `docker-compose` file like explained [here](README.md#docker-setup) to start *Dionaea* together with a properly configured *Connector*.

### Manual Build & Run

With the command `docker build . -t dio-local` a Docker image called `dio-local` gets built from this folders sources. It can then be started with `docker run -p 80:80 --rm dio-local`. Please have a look at the [Dockerfile](Dockerfile) to see all possibly exposable ports.

## Test Dionaea

### Send incidents

If the `run.sh` script was used to start *Dionaea*, several ports of the container are now exposed to localhost. Below are some sample commands to interact with the honeypot:

```curl localhost```
Calls localhost on port 80.

```curl --insecure https://localhost```
Calls localhost on port 443 (SSL).

```ftp localhost```
FTP login to localhost.

```mysql --host=127.0.0.1```
MySQL login to localhost. Always use `127.0.0.1`. (Else MySQL will use the `lo` interface and cannot connect.)

*Dionaea* will log a JSON string per event and send that to the address that is configured in the respective iHandler configuration.

##### Exploits on Dionaea

[Metasploit](/METASPLOIT.md) can be used to use predefined cyber-attacks against *Dionaea*.
It also contains *fuzzers* to find buffer overflows. They are also handy for stress tests.

### Log ihandler Output (Start Python Dummy Logger)

A simple [python service](logging-dummy.py) can be started to log all incoming `POST` messages. This way it is possible to conveniently inspect what the different *Dionaea* iHandlers are sending. An iHandler requires some address to send the data to. This has to be set to `172.17.0.1:8080` if *Dionaea* is run within a container, while the logger is running locally. The log output is then to be found in the same folder: `log.txt`.


## Configure Dionaea

### Add Custom Service / iHandler

Add whatever service or iHandler you want to ```services/``` or ```ihandlers/``` directory, respectively. 
Then you must rebuild the container. All new files in those directories with a `.yaml` extension will get copied into the container.

For example, sqlite logging is disabled by us by default. You may want to [enable it](http://dionaea.readthedocs.io/en/latest/ihandler/log_sqlite.html).

### Disable iHandlers

Only those iHandlers and services located in our `services` and `ihandlers` folders are used. Removing a file (or simply removing the `.yaml` extension) and rebuilding the container "disables" the feature.

### Logging

By default (inside the container) *Dionaea* gets started with the following command: `dionaea -l all,-debug -L '*' -c /etc/dionaea/dionaea.conf`. The configuration makes *Dionaea* write its logs to two files, `dionaea.log` and `dionaea-errors.log`. Furthermore, the commandline arguments trigger that all logs are written to `stdout`.

If you need to persist the *Dionaea* logs, it is recommended to use a mount volume from outside the container and have *Dionaea* log there.

Logging can be configured in the [dionaea.conf](dionaea.conf). E.g. only log critical errors:

```
[logging]
default.levels=critical
errors.levels=critical
```

Removing all the lines in the `[logging]` section will disable logging entirely. Make sure to leave the section header in place as *Dionaea* will crash otherwise.

##### Downloading Files

For the *Beemaster* project, *Dionaea* is configured to download malicious files for later analysis. This setting is backed by the [store.yaml](ihandlers/store.yaml) iHandler. The iHandler triggers the incidents like `dionaea.download.offer` and `dionaea.download.complete`[^1]. It may make sense for some setups to [disable](#disable-ihandlers) this iHandler.

###### FTP

The [FTP service](services/ftp.yaml) is separated from the store iHandler. It lets everyone write to the configured FTP root folder. The only way to disable writing files is to disable the service.

##### Persisting Downloaded Files

When *Dionaea* is run inside a Docker container, downloaded files will be lost when the container is stopped. To persist those files, it is recommended to use a mount volume from the host system. Change the following lines in the [docker-compose.yaml](../docker-compose.yaml):
```
...
  dionaea:
    build: ./dionaea
    volumes:
      - /var/beemaster/log/dionaea-logs:/var/dionaea/logs
      - /var/beemaster/dionaea/binaries:/var/dionaea/binaries/
      - /var/beemaster/dionaea/ftp:/var/dionaea/roots/ftp
...
```
**Warning**: Please be aware that this might pose a security risk, as you are enabling anyone to upload files
to your server, storing them persistently. Vulnerabilities in *Dionaea*, Docker or other software could
very well lead to a compromise of the host system.

[^1]: The incident `dionaea.download.complete.hash` gets triggered if a md5 hash could be generated. If so, one of the following incidents will be triggered, too: `origin:dionaea.download.complete.unique` or `origin:dionaea.download.complete.again`
