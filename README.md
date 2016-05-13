## What this is

The goal of this package is to provide a library to:

* run unit tests on a particular project, and
* collect code coverage information.

## Why

Unit tests are an accepted practice to validate your code; coverage information
further helps developers/software engineers to identify "grey areas" in the
code; that is, code which unit tests do not cover.

Caché has a builtin mechanism to both run unit tests and collect trace
information; but, unlike other major programming languages, it does not provide
a convenient way to link unit test execution and code coverage.

This package intends to fill the gap.

## Projected design

This package should be able to perform the following:

* accept a user-supplied configuration defining where the "production" and
  "test" classes are;
* given this configuration, run the unit tests and collect the results;
* be able to export these results to third parties.


### Data collection

For data collection, the plan is to:

* collect all classes according to the configuration;
* split apart classes extending
* [`%UnitTest.TestCase`](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=%25UnitTest.TestCase)
  and flag them as unit tests;
* run all unit tests, collect the data (TODO: how?).

### Exporting

This is one part which is yet to be defined.

The prior objective of this package is to make the data available to [Caché
Quality](https://www.cachequality.com) ([demo](https://demo.cachequality.com)),
and it is written in Java...

Therefore it means that the Java side must be able to collect this data. One
possibility is to use the provided Caché jars, but that is not the only
possibility: one could also imagine collecting this data via a provided REST
API.

## Some links

* [The %Studio.Project
  class](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=%25Studio.Project)
  can list all of the elements in a given project; this includes all COS
  classes, including test cases, which all inherit
  [%UnitTest.TestCase](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=%25UnitTest.TestCase).
* [The `ZBREAK`
  command](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_czbreak)
  can be used to collect traces in INT code in a non interactive manner, and to
  a dedicated device (and that includes a file): `zbreak /TRACE:ON:thefile`.

## Help needed

The code as it stands is still a proof of concept. Right now it consists of
various tidbits which have to be plugged in together so as to ultimately form a
coherent, usable module.

Feedback is welcome. In this order, you want to:

* [send the author an email](mailto:francis.galiegue@litesolutions.es);
* give feedback on the IRC channel (network: Freenode; channel: ##cos; I am
  idletask there).
