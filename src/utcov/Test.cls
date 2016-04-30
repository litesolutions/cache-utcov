Class utcov.Test Extends %RegisteredObject
{

ClassMethod m3()
{
	#dim cfg as utcov.Configuration

	set cfg = ##class(utcov.Configuration).%New()

	set cfg.namespace = "USER"
	set cfg.projectName = "cache-tort-git"

	#dim repo as utcov.ClassRepository = ..run(cfg)

	do ..writeList(repo.productionClasses)
	do ..writeList(repo.testClasses)
}

ClassMethod run(cfg As utcov.Configuration) As utcov.ClassRepository
{
	#dim classLookup as utcov.AbstractClassLookup

	set classLookup = ##class(utcov.StudioProjectLookup).%New(cfg.projectName)

	#dim repo as utcov.ClassRepository = ##class(utcov.ClassRepository).%New()
	#dim productionClasses as %ListOfDataTypes = ##class(%ListOfDataTypes).%New()
	#dim testClasses as %ListOfDataTypes = ##class(%ListOfDataTypes).%New()

	set repo.productionClasses = productionClasses
	set repo.testClasses = testClasses

	new $namespace
	set $namespace = cfg.namespace

	do classLookup.collectClasses(productionClasses, testClasses)

	return repo
}

ClassMethod writeList(list As %ListOfDataTypes)
{
	#dim len as %Integer = list.Count()
	#dim index as %Integer

	for index=1:1:len {
		write list.GetAt(index)
	}
}

}

