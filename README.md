Project Beemaster
==================================================

This is the overview repository of the Beemaster project - an IDS based on
*Bro*, using *ACU* (Alert Correlation Units) to create Meta-Alerts from data
provided by a *Bro* or a honeypot. Results can be visualized using the *CIM*
(Cyber Incident Monitor).

## Repositories

The project and its documentation (Readme, Source Code) is splitted in multiple repositories:

* [UHH-ISS / beemaster-bro](https://github.com/UHH-ISS/beemaster-bro) - Customizations for *Bro*
* [UHH-ISS / beemaster-hp](https://github.com/UHH-ISS/beemaster-hp) - Contains the generic honeypot connector and configuration files for the honeypot *Dionaea*
* [UHH-ISS / beemaster-acu-fw](https://github.com/UHH-ISS/beemaster-acu-fw) - *Alert Correlation Unit Framework*, the basis for concrete *ACU* implementations
* [UHH-ISS / beemaster-acu-portscan](https://github.com/UHH-ISS/beemaster-acu) - *ACU Portscan*
* [UHH-ISS / beemaster-acu-lattice](https://github.com/UHH-ISS/beemaster-acu) - *ACU Lattice*
* [UHH-ISS / beemaster-cim](https://github.com/UHH-ISS/beemaster-cim) - *Cyber Incident Monitor*


## Warning

The repositories were moved from the servers of the University of Hamburg.
During this transition the names of the repositories changed. However, the
contents of the repositories do not reflect this change at the time of writing.
For example, you may have to adjust Dockerfile and docker-compose files.

The former `mp-ids-` needs to be changed to `beemaster-`.


## Documentation

You can generate a HTML documentation for the source code and Readme files.
See: **[docs](docs)**.


## Tests

Integration tests (docker based) can be found in the folder [**tests**](tests).
