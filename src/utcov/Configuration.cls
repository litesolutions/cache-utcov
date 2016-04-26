///
/// Configuration for a unit test/coverage run
///
Class utcov.Configuration Extends %RegisteredObject
{

///
/// The namespace to switch to, if any
///
/// If none is specified, then the current namespace is used.
///
Property namespace As %String;

///
/// The project to use, if any
///
/// If not specified, then the full list of classes of the current namespace is considered;
/// otherwise, the program will attempt to load the classes from this project only.
///
Property projectName As %String;

}

