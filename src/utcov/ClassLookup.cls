Class utcov.ClassLookup Extends %RegisteredObject
{

Parameter CLSTYPE As %String [ Final, Internal ] = "CLS";

Parameter PKGTYPE As %String [ Final, Internal ] = "PKG";

Parameter UTCLASS As %String [ Final, Internal ] = "%UnitTest.TestCase";

Property cfg As utcov.Configuration [ Private ];

Property classList As %ListOfDataTypes;

Method %OnNew(cfg As utcov.Configuration) As %Status [ Private, ServerOnly = 1 ]
{
	if ('cfg) {
		throw ##class(%Exception.General).%New("configuration must be defined", -1)
	}

	set ..classList = ##class(%ListOfDataTypes).%New()

	set ..cfg = cfg

	do ..computeClasses()
	return $$$OK
}

Method computeClasses() [ Private ]
{
	if (..cfg.namespace '= "") {
		w "changing namespace to " _ ..cfg.namespace, !
		new $namespace
		znspace ..cfg.namespace
	}

	if (..cfg.projectName = "") {
		throw ##class(%Exception.General).%New("non project retrieval currently not supported", -1)
	}

	#dim project as %Studio.Project
	#dim status as %Status

	set project = ##class(%Studio.Project).%OpenId(..cfg.projectName, /* default */, .status)

	if ($$$ISERR(status)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(status)
	}

	do ..retrieveClassesFromProject(project)
}

Method retrieveClassesFromProject(project As %Studio.Project) [ Private ]
{
	#dim key as %String
	#dim item as %Studio.ProjectItem
	#dim name as %String

	set key = ""
	do {
		set item = project.Items.GetNext(.key)

		if (item = "") {
			continue
		}

		set name = item.Name

		if (item.Type = ..#CLSTYPE) {
			do ..doInsert(name)
			continue
		}

		if (item.Type = ..#PKGTYPE) {
			do ..addClassesFromPackage(name)
		}

	} while (key '= "")
}

Method addClassesFromPackage(pkg As %String) [ Private ]
{
	#dim result as %SQL.StatementResult

	set result = ##class(%SQL.Statement).%ExecDirect(,
		"select Name from %Dictionary.ClassDefinition where Name %STARTSWITH ?",
		pkg _ "."
	)

	if (result.%SQLCODE) {
		throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,
			"failed to retrieve list of classes for package " _ pkg)
	}

	#dim position as %Integer
	#dim value as %CacheString

	while (result.%Next()) {
		do ..doInsert(result.Name)
	}
}

Method isTestClass(className As %String) As %Boolean [ Private ]
{
	#if 0
	w "Testing classname -->" _ className _ "<--", !

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
		} else {
			return ..isTestClass(firstChar _ "Library." _ $extract(className, 2))
		}
	}

	#dim super as %String = c.Super

	if (super = "") {
		return 0
	}

	#dim children
	#dim len as %Integer
	#dim i as %Integer

	set children = $listFromString(c.Super, ",")
	set len = $listLength(children)

	for index = 1:1:len {
		if ..isTestClass($listGet(children, index)) {
			return 1
		}
	}

	return 0
}

Method doInsert(className As %String) [ Private ]
{
	#dim testClass as %Boolean = ..isTestClass(className)

	do ..classList.Insert(className _ ": " _ testClass)
}

}

