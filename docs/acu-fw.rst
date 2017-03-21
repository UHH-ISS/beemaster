Alert Correlation Unit (Framework)
==================================

The *ACU Framework* provides an abstraction to underlying messaging work and a
skeleton for concrete implementations. An *ACU* shall receive messages,
aggregate and correlate them and finally send a meta-alert back to the Bro.

.. .. doxygennamespace:: acu
..     :project: acu-fw

Acu
---
.. doxygenclass:: acu::Acu
    :project: acu-fw

Receiver
--------
.. doxygenclass:: acu::Receiver
    :project: acu-fw

AlertMapper
-----------
.. doxygenclass:: acu::AlertMapper
    :project: acu-fw

IncomingAlert
-------------
.. doxygenclass:: acu::IncomingAlert
    :project: acu-fw

Aggregation
-----------
.. doxygenclass:: acu::Aggregation
    :project: acu-fw

Correlation
-----------
.. doxygenclass:: acu::Correlation
    :project: acu-fw

Storage
-------
.. doxygenclass:: acu::Storage
    :project: acu-fw

Threshold
---------
.. doxygenstruct:: acu::Threshold
    :project: acu-fw

OutgoingAlert
-------------
.. doxygenclass:: acu::OutgoingAlert
    :project: acu-fw

Sender
------
.. doxygenclass:: acu::Sender
    :project: acu-fw

Utils
-----
.. doxygenfile:: utils.h
    :project: acu-fw
