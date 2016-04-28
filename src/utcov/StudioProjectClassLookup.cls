Class utcov.StudioProjectClassLookup Extends utcov.ClassLookup2 [ Final ]
{

Parameter CLSTYPE As %String [ Final, Internal ] = "CLS";

Parameter PKGTYPE As %String [ Final, Internal ] = "PKG";

Property projectName As %String [ Private, Required ];

Method %OnNew(cfg As utcov.Configuration) As %Status
{
	do ##super(cfg)
	set ..projectName = cfg.projectName
	return $$$OK
}

Method doComputeClassRepository()
{
	#dim repository as utcov.ClassRepository = ##class(utcov.ClassRepository).%New()

	set repository.namespace = ..namespace

	#dim project as %Studio.Project
	#dim status as %Status

	set project = ##class(%Studio.Project).%OpenId(..projectName, /* default */, .status)

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
			do ..addClass(name)
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
		do ..addClass(result.Name)
	}
}

}

