Generate Source Code Documentation
==================================

Call `./generate.sh` to generate an HTML documentation.

It will contain the source code documentation of the *ACU* framework and the
implemented *ACU Portscan* and *ACU Lattice* as well as of the generic
*Honeypot Connector*. It also includes some meta information of the readme
files found in these repositories.

The start of the generated documentation is found in
`_build/html/index.html`.

## Hints:

* All needed repositories have to be placed in the same location as this
  repository.
* The script will inform you about missing software and not found repositories.
* For a clean setup, do `rm -rf _*`.
* Using `./generate.sh -p` automatically pushes changes onto `gh-pages`.

<!--
gh-pages setup inspire by:
https://gist.github.com/brantfaircloth/791759
-->
