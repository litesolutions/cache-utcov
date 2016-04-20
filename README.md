## What this is

The goal of this package is to provide a framework, runnable from at least the
Caché terminal, to be able to:

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

## How

At this point in time, the mechanism is not fully defined.

It is known however that Caché has what it takes to perform the task:

* [The %Studio.Project
  class](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=%25Studio.Project)
  can list all of the elements in a given project; this includes all COS
  classes, including test cases, which all inherit
  [%UnitTest.TestCase](http://docs.intersystems.com/latest/csp/documatic/%25CSP.Documatic.cls?PAGE=CLASS&LIBRARY=%25SYS&CLASSNAME=%25UnitTest.TestCase).
* [The `ZBREAK`
  command](http://docs.intersystems.com/latest/csp/docbook/DocBook.UI.Page.cls?KEY=RCOS_czbreak)
  can be used to collect traces in INT code in a non interactive manner, and to
  a dedicated device (and that includes a file): `zbreak /TRACE:ON:thefile`.

Those two elements and others can be used to perform a full unit test run and
coverage report.

## Help needed

The code as it stands is still a proof of concept. Right now it consists of
various tidbits which have to be plugged in together so as to ultimately form a
coherent, usable module.

Feedback is welcome. In this order, you want to:

* [send the author an email](mailto:francis.galiegue@litesolutions.es);
* give feedback on the IRC channel (network: Freenode; channel: ##cos; I am
  idletask there).
