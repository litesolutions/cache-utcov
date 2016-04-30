Class utcov.StudioProjectLookup Extends (utcov.AbstractClassLookup, %Library.RegisteredObject) [ Final ]
{

Parameter CLSTYPE As %String [ Final, Internal ] = "CLS";

Parameter PKGTYPE As %String [ Final, Internal ] = "PKG";

Property projectName As %String;

Method %OnNew(projectName As %String) As %Status [ Private, ServerOnly = 1 ]
{
	set ..projectName = projectName
	return $$$OK
}

Method collectClasses(productionClasses As %ListOfDataTypes, testClasses As %ListOfDataTypes)
{
	#dim project as %Studio.Project
	#dim status as %Status

	set project = ##class(%Studio.Project).%OpenId(..projectName,,.status)

	if ($$$ISERR(status)) {
		throw ##class(%Exception.StatusException).CreateFromStatus(status)
	}

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
			do ..addClass(name, productionClasses, testClasses)
			continue
		}

		if (item.Type = ..#PKGTYPE) {
			do ..addClassesFromPackage(name, productionClasses, testClasses)
		}

	} while (key '= "")
}

Method addClassesFromPackage(pkg As %String, productionClasses As %ListOfDataTypes, testClasses As %ListOfDataTypes) [ Final, Private ]
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

	while (result.%Next()) {
		do ..addClass(result.Name, productionClasses, testClasses)
	}
}

}

