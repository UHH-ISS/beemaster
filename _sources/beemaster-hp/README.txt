MP-IDS Honeypot
===============

This repository contains the sources of a generic **Connector** with configuration files to be used in conjunction with the [Dionaea](https://github.com/DinoTools/dionaea) honeypot.
Furthermore, it contains configuration files for *Dionaea* to make it send incidents to the *Connector*.

*Dionaea* is used to provide a broad artificial attack vector. Whatever input *Dionaea* records, it gets forwarded to the *Connector*. The *Connector* is configured to handle the JSON data *Dionaea* sends and transforms them into *Broker* messages. Messages are then sent via *Broker* to a peered *Bro* master or slave instance.

Please have a look at the setup of the [integration test](https://github.com/UHH-ISS/beemaster/tree/master/tests), if you are interested in how the *Connector* and *Dionaea* work together with the other *Beemaster* components.


## Generic *Connector*

You find all information about using the generic *Connector* together with *Dionaea* in the [connector](connector) folder.
The following topics will be discussed:
* [Configuration of the *Connector*](connector/README.md#setup-development-environment)
* [Usage with and without Docker](connector/README.md#usage)
* [Setup development environment](connector/README.md#setup-development-environment)

## Dionaea Honeypot

You find all information about using *Dionaea* in a Docker environment and ready to use configurations in the [dionaea](dionaea) folder.

## Further Documentation
* [Dionaea](dionaea/README.md#logging): Logs a lot by default.
* [Connector](connector/README.md#logging): Does not log by default to a file. (Your start script may log the console output, though.)

## License attribution

The dionaea honeypot is licensed under the GPL v2 license ([Dionaea License](https://github.com/DinoTools/dionaea/blob/master/LICENSE)).

Beemaster does solely use the Dionaea Honeypot without any modification of source code. All credits regarding Dionaea belong to the respective creator. Beemaster does not claim to own, modify or redistribute any of the used software components. The applied MIT license only regards the work done during the Beemaster project, including but not limitting to the creation of provided scripts, configuration files and the `connector` source files.
