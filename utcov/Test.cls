Class utcov.Test Extends %RegisteredObject
{

ClassMethod m2()
{
	#dim cfg as utcov.Configuration 
	
	set cfg = ##class(utcov.Configuration).%New()
	
	set cfg.namespace = "USER"
	set cfg.projectName = "SonarQubeRulesTests"
	
	#dim classLookup as utcov.ClassLookup
	
	set classLookup = ##class(utcov.ClassLookup).%New(cfg)
	
	#dim list as %ListOfDataTypes = classLookup.classList
	
	#dim i as %Integer
	
	for i = 1:1:list.Count() {
		w list.GetAt(i), !
	}
}

}

