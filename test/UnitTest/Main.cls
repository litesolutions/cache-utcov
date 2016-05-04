Class UnitTest.Main
{

ClassMethod Run(pCoverageLevel As %Integer = 0)
{
	Do ##class(utcov.Data).%KillExtent()
	Do ##class(utcov.Manager).RunAllTests("UnitTest",,,$ListBuild("UnitTest.SampleTestedClass","UnitTest.SampleUnitTest"),,pCoverageLevel)
}

}
