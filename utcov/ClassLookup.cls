Class utcov.ClassLookup Extends %RegisteredObject
{

Parameter CLSTYPE As %String [ Final, Internal ] = "CLS";

Parameter PKGTYPE As %String [ Final, Internal ] = "PKG";

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

Method addClassesFromPackage(pkg As %String)
{
	// FIXME: is the test correct?
	if ($find(pkg, "%") = 1) {
		new $namespace
		znspace "%SYS"
	}
	
	#dim result as %SQL.StatementResult
	
	set result = ##class(%SQL.Statement).%ExecDirect(, 
		"select name from %Dictionary.ClassDefinition where name %STARTSWITH ?",
		pkg _ "."
	)
	
	if (result.%SQLCODE) {
		throw ##class(%Exception.General).%New("failed to retrieve list of classes from package" _ pkg,
			result.%SQLCODE)
	}
	
	if (result.%OutputColumnCount = 0) {
		// FIXME... What to do here? That should not happen, right?
		w "Eh? No results?", !
		return
	}
	
	#dim position as %Integer
	#dim value as %CacheString
	
	set position = ""
	
	while (1) {
		set value = result.%NextOutputValue(.position)
		if (position = "") {
			return
		}
		w value, !
		do ..classList.Insert(value)
	}
}

}

