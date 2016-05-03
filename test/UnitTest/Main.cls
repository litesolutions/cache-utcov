Class UnitTest.Main
{

ClassMethod Run()
{
	Do ##class(utcov.Data).%KillExtent()
	Do ##class(utcov.Manager).RunAllTests("UnitTest",,,$ListBuild("UnitTest.SampleTestedClass","UnitTest.SampleUnitTest"))
}

}
