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
	
	set key = ""
	do {
		set item = project.Items.GetNext(.key)
	
		if (item = "") {
			continue
		}
		
		if (item.Type = ..#CLSTYPE) {
			do ..classList.Insert(item.Name)
			continue
		}
		
		if (item.Type = ..#PKGTYPE) {
			do ..addClassesFromPackage(item.Name)
		}
		
	} while (key '= "")
}

Method addClassesFromPackage(pkg As %String) [ Private ]
{
	#dim result as %SQL.StatementResult
	
	set result = ##class(%SQL.Statement).%ExecDirect(, 
		"select id from %Dictionary.ClassDefinition where id %STARTSWITH ?",
		pkg _ "."
	)
	
	if (result.%SQLCODE) {
		throw ##class(%Exception.SQL).CreateFromSQLCODE(result.%SQLCODE,
			"failed to retrieve list of classes for package " _ pkg)
	}
	
	#dim position as %Integer
	#dim value as %CacheString
	
	while (result.%Next()) {
		do ..classList.Insert(result.id)
	}
}

Method isTestClass(className As %String) As %Boolean
{
	if (className = ..#UTCLASS) {
		return 1
	}
	
	#dim c as %Dictionary.ClassDefinition
	#dim status as %Status
		
	set c = ##class(%Dictionary.ClassDefinition).%OpenId(className,,.status)
	
	if ($$$ISERR(status)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(status)
	}
	
	if ('c.SuperIsDefined()) {
		return 0
	}
	
	#dim children
	#dim len as %Integer
	#dim i as %Integer
	
	set children = $listFromString(c.Super, ",")
	set len = $listLength(children)
	
	for i = 1:1:len {
		if ..isTestClass($listGet(children, i)) {
			return 1
		}
	}
	
	return 0
}

}

