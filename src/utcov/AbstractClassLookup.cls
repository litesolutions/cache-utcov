///
/// Base, abstract class lookup class
///
/// This class will be called after the namespace switch, if any.
///
Class utcov.AbstractClassLookup [ Abstract ]
{

Parameter UTCLASS As %String [ Final, Internal ] = "%UnitTest.TestCase";

///
/// Collect all production (ie, non test) and test classes for this lookup
///
/// This method is invoked using an arbitrary namespace; therefore we cannot
/// use classes which are not universally available, and the only class which
/// is universally available and can store several items in our case is a
/// %ListOfDataTypes. While we could use a "typeless" variable, we choose
/// not to here.
///
Method collectClasses(productionClasses As %ListOfDataTypes, testClasses As %ListOfDataTypes) [ Abstract ]
{
	throw ##class(%Exception.General).%New("not implemented", -1)
}

Method addClass(className As %String, productionClasses As %ListOfDataTypes, testClasses As %ListOfDataTypes) [ Final, Private ]
{
		#dim testClass as %Boolean = ..isTestClass(className)
		#dim listToAddTo = $case(testClass, 0:productionClasses, :testClasses)
		do listToAddTo.Insert(className)
}

///
/// Determine whether a class (given by name) is a test class
///
/// Non final for testing purposes only. The default implementation checks
/// whether the class name (given as a string here) inherits
/// %UnitTest.TestCase anywhere in its inheritance tree.
///
/// Classes which start with % are treated specially; if one such class is
/// given as an argument, say, %Foo, and %Foo does not exist, then the method
/// tries to query %Library.Foo.
///
Method isTestClass(className As %String) As %Boolean [ Private ]
{
	if (className = ..#UTCLASS) {
		return 1
	}

	#dim c as %Dictionary.ClassDefinition
	#dim status as %Status

	set c = ##class(%Dictionary.ClassDefinition).%OpenId(className,,.status)

	if ($$$ISERR(status)) {
		/*
		 * We have to extract the first character of the class name here.
		 *
		 * If it's a percent sign (%), then there is a chance that in fact %Foo
		 * does not exist, but %Library.Foo does.
		 *
		 * Therefore the algorithm is:
		 *
		 * - if the first character is not a % then there is no such class,
		 *   this is an error;
		 * - if it is a percent, we check whether it is already %Library.xxx;
		 *   if it is not, we reissue a call to this method with %Library.Foo
		 *   instead of %Foo.
		 */
		#dim firstChar as %String = $extract(className)
		if (firstChar '= "%") {
			throw ##class(%Exception.StatusException).CreateFromStatus(status)
		}
		return $case($find(className, "%Library."),
			0:0,
			:..isTestClass(firstChar _ "Library." _ $extract(className, 2))
		)
	}

	#dim super as %String = c.Super

	if (super = "") {
		return 0
	}

	#dim children
	#dim len as %Integer
	#dim index as %Integer

	set children = $listFromString(c.Super, ",")
	set len = $listLength(children)

	for index=1:1:len {
		if ..isTestClass($listGet(children, index)) {
			return 1
		}
	}

	return 0
}

}

