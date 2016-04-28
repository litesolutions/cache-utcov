Class utcov.Test Extends %RegisteredObject
{

ClassMethod m2()
{
	#dim cfg as utcov.Configuration

	set cfg = ##class(utcov.Configuration).%New()

	set cfg.namespace = "USER"
	set cfg.projectName = "cache-tort-git"

	#dim classLookup as utcov.ClassLookup2

	set classLookup = ##class(utcov.ClassLookup2).fromConfiguration(cfg)

	#dim repo as utcov.ClassRepository = classLookup.computeClassRepository()

	zwrite repo
}

}

