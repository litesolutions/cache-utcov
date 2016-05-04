Class UnitTest.SampleUnitTest extends %UnitTest.TestCase
{

Method Test1()
{
	Do ##class(UnitTest.SampleTestedClass).MyMethod()
	Do $$$AssertEquals(1,1,"Test")
}

Method Test2()
{
	Set tAnswer = ##class(UnitTest.SampleTestedClass).MyOtherMethod()
	Do $$$AssertEquals(tAnswer,42)
}

Method TestAll()
{
	Do ##class(UnitTest.SampleTestedClass).MyMethod()
	Do $$$AssertEquals(1,1,"Test")
	Set tAnswer = ##class(UnitTest.SampleTestedClass).MyOtherMethod()
	Do $$$AssertEquals(tAnswer,42)
}

}
