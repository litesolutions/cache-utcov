Class UnitTest.SampleUnitTest extends %UnitTest.TestCase
{

Method TestRunTests()
{
	Do ##class(UnitTest.SampleTestedClass).MyMethod()
	Do $$$AssertEquals(1,1,"Test")
}

}