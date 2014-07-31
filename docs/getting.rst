.. _getting:

Installation
============

robot-nps has several dependencies.  Firstly, it is known to run on
Python_ 2.6 and 2.7, and known not to run on Python 3.x.

You can install it using pip_::

    $ pip install robot-nps

or using easy_install_::

    $ easy_install robot-nps

It's usually a good idea to install robot-nps into a virtualenv, to avoid issues
with incompatible versions and system packaging schemes.

Getting the code
----------------

You can also get the code from PyPI_ or GitHub_. You can either clone the public repository::

    $ git clone git://github.com/da4089/robot-nps.git

Download the tarball::

    $ curl -OL https://github.com/da4089/robot-nps/tarball/master

Or, download the zipball::

    $ curl -OL https://github.com/da4089/robot-nps/zipball/master

Once you have a copy of the source you can install it into your site-packages
easily::

    $ python setup.py install



.. _easy_install: http://pypi.python.org/pypi/setuptools
.. _GitHub: https://github.com/hgrecco/pint
.. _Python: http://www.python.org/
.. _PyPI: https://pypi.python.org/pypi/Pint/
.. _pip: http://www.pip-installer.org/
