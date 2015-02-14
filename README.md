robot-nps
=========
Robot NPS is a Network Protocol Simulator for Robot Framework. 

[![Build Status](https://travis-ci.org/da4089/robot-nps.svg?branch=master)](https://travis-ci.org/da4089/robot-nps)
[![Code Health](https://landscape.io/github/da4089/robot-nps/master/landscape.svg?style=flat)](https://landscape.io/github/da4089/robot-nps/master)

Robot Framework is a system-testing framework, originally developed
primarily by Pekka Klarck at Nokia Siemens Networks.  It provides a
simple language for writing tests, a range of libraries for different
test features, and a standard protocol for so-called remote servers.

This project implements a remote server that simulates both client and
server sides of various application-layer network protocols, including
financial order entry and market data protocols.  In combination with
Robot Framework, tests can be written to exercise applications using
these protocols.

Features
--------
- Enables easy simulation of message-oriented application protocols.
- Supports simulation of multiple peers (eg. client and server) within a single
  process.
- Supports distributed testing using multiple processes.
- Runs on Linux, OSX and Windows.
- Easily extended to support new protocols.

Complete documentation available at http://robot-nps.readthedocs.org/en/latest/

Installation
------------

Install robot-nps by running:

    pip install robot-nps

Contribute
----------

- Issue Tracker: https://github.com/da4089/robot-nps/issues
- Source Code: https://github.com/da4089/robot-nps

Support
-------

If you are having issues, please let us know.
We have a mailing list located at: robot-nps@googlegroups.com

License
-------

The project is licensed under the GPLv3 license.
