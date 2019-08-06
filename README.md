True Crypto OSS
=====================

https://truedividendcrypto.org

What is True Dividend Crypto?
-----------------------------

True Dividend Crypto (or TDC) is an experimental digital currency that enables
instant payments to anyone, anywhere in the world. TDC uses peer-to-peer technology
to operate with no central authority: managing transactions and issuing money are carried
out collectively by the network.

TDC network nodes who choose to stake their wallet balances are rewarded for their participation
with every new block added to the TDC blockchain. Dedicated community participants may convert
their standard network nodes into masternodes by staking a pre-determined quantity of TDC and
allowing their masternode to remain connected to the TDC network in a permanent manner.

Masternodes operators are rewarded for their participation with a share of every new block added
to the TDC blockchain. See [DETAILS](DETAILS.md) for more information about block frequency,
block rewards, and staking percentages.

True Crypto OSS is the name of the open source software which enables the use of this currency.

License
-------

True Crypto OSS is released under the terms of the MIT license. See [COPYING](COPYING) for more
information or see https://opensource.org/licenses/MIT.

Development Process
-------------------

The `master` and `development` branches are regularly built and tested, but are not guaranteed to be
completely stable. [Tags](https://github.com/truedividendcrypto/truecrypto-oss/tags) are created
regularly to indicate new official, stable release versions of True Crypto OSS.

The contribution workflow is described in [CONTRIBUTING.md](CONTRIBUTING.md)
and useful hints for developers can be found in [docs/developer-notes.md](docs/developer-notes.md).

### Automated Testing

Developers are strongly encouraged to write [unit tests](src/test/README.md) for new code, and to
submit new unit tests for old code. Unit tests can be compiled and run
(assuming they weren't disabled in configure) with: `make check`. Further details on running
and extending unit tests can be found in [/src/test/README.md](/src/test/README.md).

There are also [regression and integration tests](/test), written
in Python, that are run automatically on the build server.
These tests can be run (if the [test dependencies](/test) are installed) with: `test/functional/test_runner.py`

### Manual Quality Assurance (QA) Testing

Changes should be tested by somebody other than the developer who wrote the
code. This is especially important for large or high-risk changes. It is useful
to add a test plan to the pull request description if testing the changes is
not straightforward.

Translations
------------

**Important**: Our translation process is currently being figured out, we apologize for the poor quality of the current translations.
