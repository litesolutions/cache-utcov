Class utcov.ClassLookup2 [ Abstract ]
{

Parameter UTCLASS As %String [ Final, Internal ] = "%UnitTest.TestCase";

Property namespace As %String [ Required ];

Property repository As utcov.ClassRepository [ InitialExpression = {##class(utcov.ClassRepository).%New()} ];

Method %OnNew(cfg As utcov.Configuration) As %Status [ Private, ServerOnly = 1 ]
{
	set ..namespace = cfg.namespace
	set ..repository.namespace = cfg.namespace
	return $$$OK
}

Method computeClassRepository() As utcov.ClassRepository [ Final ]
{
	if (..namespace) {
		new $namespace
		set $namespace = ..namespace
	}

	do ..doComputeClassRepository()

	return ..repository
}

Method doComputeClassRepository() [ Abstract, Private ]
{
	throw ##class(%Exception.General).%New("missing implementation", -1)
}

Method addClass(className As %String) [ Final, Private ]
{
	#dim testClass as %Boolean
	#dim listToAddTo as %ListOfDataTypes

	set testClass = ..isTestClass(className)
	set listToAddTo = $case(testClass, 0:..repository.productionClasses, :repository.testClasses)
	do ..listToAddTo.Insert(className)
}

Method isTestClass(className As %String) As %Boolean [ Final, Private ]
{
	if (className = ..#UTCLASS) {
		return 1
	}

	#dim c as %Dictionary.ClassDefinition
	#dim status as %Status

	set c = ##class(%Dictionary.ClassDefinition).%OpenId(className,,.status)

	if ($$$ISERR(status)) {
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

