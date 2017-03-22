.. Beemaster documentation master file.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Beemaster IDS Documentation
===========================

This documentation provides developer information about the Beemaster project.
The Beemaster project is an intrusion detection system, combining honeypots,
networktaps and custom alert correlation units with the power of the `Bro IDS
<https://www.bro.org/>`__. All together is visualised on a cyber incident
monitor.

The following documentations provide more indepth vision into some of
Beemaster's components; namely: Honeypot (consisting of a Connector and Dionaea
as an example) and ACU (the framework, as well as an implementation).


.. toctree::
    :maxdepth: 2

    STYLEGUIDE

Honeypot
--------
.. toctree::
    :maxdepth: 2

    beemaster-hp/README
    beemaster-hp/connector/README
    beemaster-hp/dionaea/README
    connector

Alert Correlation Unit
----------------------
.. toctree::
    :maxdepth: 2

    beemaster-acu-fw/README
    acu-fw
    beemaster-acu-portscan/README
    acu-portscan

Appendices
==========

* :ref:`genindex`
* :ref:`search`

.. * :ref:`modindex`
