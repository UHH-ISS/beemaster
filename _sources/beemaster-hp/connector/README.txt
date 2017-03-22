Generic Connector
=================

The generic *Connector* of *Beemaster* is responsible for connecting a honeypot with the *Bro* cluster. The *Connecter* generally accepts JSON-formatted input via HTTP, maps it to *Broker*-compatible data types and sends a *Broker*-message to a configurable endpoint.

You are highly encouraged to always run the *Connector* on the same machine as the corresponding honeypot, use only one *Connector* per honeypot and hide the *Connector* from the outside.

The following topics are be discussed:
* [Configuration of the *Connector*](#configuration)
* [Usage with and without Docker](#usage)
* [Setup development environment](#setup-development-environment)


## Configuration
### Connection
Connection-related settings of the *Connecter* can be configured by passing arguments at start or specifying a configuration file. The following arguments are supported:

```
positional arguments:
  file                  Configuration file to use.

optional arguments:
  -h, --help              Show this help message and exit
  --laddr address         Address to listen on.
  --lport port            Port to listen on.
  --saddr address         Address to send to.
  --sport port            Port to send to.
  --mappings directory    Directory to look for mappings.
  --topic topic           Topic for sent messages.
  --endpoint_prefix name  Prefix name for the Broker endpoint.
  --id connector_id       This connector's unique id.
  --log-file file         The file to log to. 'stderr' and 'stdout' work as special names for standard-error and -out respectively.
  --log-level level       Set the log-level. {'INFO', 'DEBUG', 'WARNING', 'ERROR', 'CRITICAL'}
  --log-datefmt format    Set the date/time format to use for logging ('asctime' placeholder in log-format). Python's strftime format is used.
  --log-format format     Set the logging format. Use the 'asctime' placeholder to include the date. See the python docs for more information on this.
```

The positional argument accepts configuration files written in YAML with the following format:

```yaml
listen:
    address: 0.0.0.0                        # Address to listen on.
    port: 8080                              # Port to listen on.
send:
    address: 127.0.0.1                      # Address to send to.
    port: 5000                              # Port to send to.
mappings: mappings                          # Directory to look for mappings.
broker:
    topic: honeypot/dionaea/                # Topic for sent messages.
    endpoint_prefix: beemaster-connector-   # Prefix name for the broker endpoint.
```
The values shown in the example above are the default values the *Connecter* falls back to, in case no arguments are passed.

By default, the *Connecter* uses the hostname to identify itself. You can change it to whatever name you like, but it *must be a unique name in your network*:
```yaml
connector_id: my_unique_connector_name       # Remove this to use the hostname by default
```

<a name="logging" ></a>
Furthermore, the *Connecter* is able to write logs. Just let him know in what information you are interested in:
```yaml
logging:
    file: stderr
    level: ERROR
    datefmt: None
    format: "[ %(asctime)s | %(name)10s | %(levelname)8s ] %(message)s"
```
Tip: Writing the `INFO` level to `stdout` or a file, mounted by the host to the Docker container, makes it easier to see the traffic throughput of the *Connecter*.

### Mapping
The mappings used by the *Connecter* are configurable via YAML files. Below is an example of a mapping for a Dionaea access event:

```yaml
# one file per access type
#
# name: name of the event (for bro)
# mapping: the structure of the arriving json
#          to map to the desired broker-type
#          (implemented in mapper)
# message: the structure of the message, as it
#          will be put into the broker message
name: dionaea_access
mapping:
    timestamp: time_point
    src_hostname: string
    src_ip: address
    src_port: port_count
    dst_ip: address
    dst_port: port_count
    connection:
        type: string
        protocol: string
        transport: string
message:
    - timestamp
    - dst_ip
    - dst_port
    - src_hostname
    - src_ip
    - src_port
    - transport
    - protocol
```

Once you create a mapping, be sure to create the corresponding event handler on the *Bro* side of the connection.

## Usage
The *Connector* can be used within a Docker container or locally for testing.
We advise you to run the *Connector* always on the same host as the *Dionaea* honeypot.

**Important:** Make sure that the configured *Broker* endpoint (send to) is available as the *Connector* will not accept data on its listening port (listen from) otherwise.

*Note:* We provide a setup for a *Raspberry Pi*. The official [project documentation](https://git.informatik.uni-hamburg.de/iss/mp-ids/blob/master/dokumente/dokumentation/produktdoku/Dokumentation.pdf) (in German) describes the setup.

### Docker Setup

If you want to use the *Connector* in conjunction with *Dionaea*, you can use the following compose file (and make sure all directories are present, or change them accordingly).

By default (inside the container), the contents of the `conf` directory are copied into the `src` directory. Thus the `connector.py` can be started by passing the configuration filename directly (see the [`docker-compose`](../docker-compose.yaml) file example below):

```yaml
version: '2'
services:
  connector:
    build: ./mp-ids-hp/connector
    command: ["config-docker.yaml"]
  dionaea:
    build: ./mp-ids-hp/dionaea
    ports:
      - "21:21"
      - "23:23"
      - "53:53/udp"
      - "53:53"
      - "80:80"
      - "123:123/udp"
      - "443:443"
      - "445:445"
      - "3306:3306"
```

Run `docker-compose up --build`.

Be sure to expose only those ports of *Dionaea* you want to be accessible for attackers.

Instead of passing [`config-docker.yaml`](conf/config-docker.yaml) as an argument (which is a configuration adjusted for this compose file), you could also pass your own values, e.g.:
```yaml
  connector:
    command: ["--sport","1337","--topic","leetevent/"]
```

You can also run the *Connecter* as a standalone container by appending the correct arguments to the `docker run` command:

```
docker build -t connector .
docker run connector --sport 1337 --topic leetevent/
```

**For testing purposes**, you might want to run *Dionaea* and the *Connector* 
together with *Bro*. Have a look at the [compose file](https://github.com/UHH-ISS/beemaster-bro/blob/master/docker-compose.yml) of the *Beemaster Bro* repository. There you can find a simple *Bro* cluster setup.

### Without Docker

Ensure that you sourced the virtual environment as described [here](#setup-development-environment). The *Connector* needs to run on Python 2 and requires modules which are not located in the `src` folder but included in the environment.

Start the *Connector* via `python connector.py` and use the correct arguments for your environment. This repository holds a configuration file that can be used for [local testing](conf/config-local.yaml), which is identical to the default configuration, apart from sending to port `9999`.

`python connector.py ../conf/config-local.yaml`

It will bind to port `8080` and listen for JSON post input. See the [*Dionaea* readme](../dionaea/README.md#talk-to-dionaea) for information about how to communicate with it.


## Setup Development Environment

The [setup.sh](../setup.sh) script can be used to set up a development and testing environment.
  
```sh
./setup.sh -h
# Usage: ./setup.sh -h
#        ./setup.sh [-i|u] [-d] [-s]
#        ./setup.sh -c
#
# Options:
#     -h      Print this help message and exit.
#     -i      Install virtualenv, if not installed.
#     -u      Update environment(s) with new requirements.
#     -d      Setup development environment (for linting etc.)
#     -s      Adds symlinks for easier environment sourcing.
#     -c      Removes everything, created by this setup and exits.
```

#### Development

Execute `./setup.sh -d` to setup all required environments. `flake8` will be
accessible in the main directory so you do not necessarily need to source the
environment to use the linter (if sourced, `flake8` will be in your `PATH`).

#### Execution Only

If you only need to run the code, use `./setup.sh` to install the minimal
environment.

Source the environment with `. env/bin/activate` (or use the symlink, provided
by `./setup.sh -s`). Be aware, that the activation only applies for the current
shell.
