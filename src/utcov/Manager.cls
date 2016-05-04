Class utcov.Manager Extends %UnitTest.Manager
{

/// Not yet respected - level to aggregate coverage data.
Property CoverageDetail As %String(DISPLAYLIST = ",Overall,Class,Method", VALUELIST = ",0,1,2") [ InitialExpression = 2 ];

Property CoverageTargets As %List [ Internal, Private ];

Property CurrentTestClass As %String(MAXLEN = 255) [ Internal, Private ];

Property CurrentTestMethod As %String(MAXLEN = 255) [ Internal, Private ];

/// Invoked externally to run all unit tests.
/// Presupposes that unit tests have been included in the build.
ClassMethod RunAllTests(pPackage As %String = "", pLogFile As %String = "", pUnitTestClasses As %List = "", pCoverageClasses As %List = "", pCoverageRoutines As %List = "", pCoverageLevel As %Integer = 0) As %Status
{
	#dim tUnitTestManager As utcov.Manager
	Set tSuccess = 1
	Try {
		Set tLogFileOpen = 0
		Set tOldIO = $io
		If (pLogFile '= "") {
			Open pLogFile:"WNS":10
			Set tLogFileOpen = 1
			Use pLogFile
		}
		
		Write "*** Unit tests starting at ",$zdt($h,3)," ***",!
	
		Set tBegin = $zh
	
		Set tUnitTestManager = ..%New()
		Set tUnitTestManager.Display = "log,error"
		Do tUnitTestManager.SetCoverageTargets(pCoverageClasses,pCoverageRoutines)
		Set tUnitTestManager.CoverageDetail = pCoverageLevel
		Set tStmt = ##class(%SQL.Statement).%New()
		$$$ThrowOnError(tStmt.%PrepareClassQuery("%Dictionary.ClassDefinition","SubclassOf"))
		Set tRes = tStmt.%Execute("%UnitTest.TestCase",pPackage)
		While tRes.%Next(.tSC) {
			$$$ThrowOnError(tSC)
			Do tUnitTestManager.RunUnitTestClass(tRes.%Get("Name"))
		}
		$$$ThrowOnError(tSC)
	
		If $IsObject(tUnitTestManager) {
			Do tUnitTestManager.SaveResult($zh-tBegin)
			Do tUnitTestManager.PrintURL()
			
			Set (tFailed,tPassed,tSkipped) = 0
			&sql(select sum(case when c.Status = 0 then 1 else 0 end) as failed,
						sum(case when c.Status = 1 then 1 else 0 end) as passed,
						sum(case when c.Status = 2 then 1 else 0 end) as skipped
						into :tFailed, :tPassed, :tSkipped
				   from %UnitTest_Result.TestSuite s
				   join %UnitTest_Result.TestCase c
				     on s.Id = c.TestSuite
				  where s.TestInstance = :tUnitTestManager.LogIndex)

			If (tFailed '= 0) {
				Set tSuccess = 0
			}
		} Else {
			Write "No unit tests found matching package: ",pPackage,!
		}
	} Catch anyException {
		Set tSuccess = 0
		Write anyException.DisplayString(),!
	}
	Write !,!,"Test cases: ",tPassed," passed, ",tSkipped," skipped, ",tFailed," failed",!
	If 'tSuccess {
		Write !,"ERROR(S) OCCURRED."
	}
	Use tOldIO
	Close:tLogFileOpen pLogFile
	Quit $Select(tSuccess:1,1:$$$ERROR($$$GeneralError,"One or more errors occurred in unit tests."))
}

Method RunUnitTestClass(pClassName As %String)
{
	Set tTestSuite = $Piece(pClassName,".",1,$length(pClassName,".")-1)
	Set qspec = "/noload/nodelete"
	Set tSC = $$$qualifierParseAlterDefault("UnitTest","/keepsource",.qspec,.qstruct)
	Do ..RunOneTestSuite("",$Replace(tTestSuite,".","/"),tTestSuite_":"_pClassName,.qstruct)
}

Method SetCoverageTargets(pClasses As %List = "", pRoutines As %List = "")
{
	Set tList = "", tPtr = 0
	While $ListNext(pClasses,tPtr,tClass) {
		// Use a wildcard to include all .int files associated with the class.
		Set tList = tList_$ListBuild(tClass_".*") 
	}
	While $ListNext(pRoutines,tPtr,tRoutine) {
		Set tList = tList_$ListBuild(tRoutine)
	}
	Set ..CoverageTargets = tList
}

Method StartCoverageTracking(pTestClass As %String, pTestMethod As %String) As %Status
{
	Set tSC = $$$OK
	Try {
		If (..CoverageTargets '= "") {
			Set ..CurrentTestClass = pTestClass
			Set ..CurrentTestMethod = pTestMethod
			$$$ThrowOnError(##class(%Monitor.System.LineByLine).Start(..CoverageTargets,$ListBuild("RtnLine"),$ListBuild($Job)))
		}
	} Catch anyException { 
		Set tSC = anyException.AsStatus()
	}
	Quit tSC
}

Method EndCoverageTracking() As %Status
{
	Set tSC = $$$OK
	Try {
		If (..CoverageTargets '= "") {
			// Pause the monitor.
			$$$ThrowOnError(##class(%Monitor.System.LineByLine).Pause())
			
			Set tTextIndex = "TEMP-"_..TempLogIndex
			Set tTestClass = ..CurrentTestClass
			Set tTestMethod = ..CurrentTestMethod
			
			Set tRtnCount = ##class(%Monitor.System.LineByLine).GetRoutineCount()
			For i=1:1:tRtnCount {
				Set tRtnName = ##class(%Monitor.System.LineByLine).GetRoutineName(i)
				// Capture line-by-line monitor results to Coverage.Data, possibly updating existing data
				&sql(insert or update into utcov.Data
					(TestIndex, TestClass, TestMethod,
						RoutineName, RoutineType,
						LineText, LineNumber, LineCovered)
					select :tTextIndex, :tTestClass, :tTestMethod,
						:tRtnName, 'int',
						utcov.Utils_GetLineText(:tRtnName,'int',LineNumber), LineNumber,
						CASE R.LineCovered WHEN 1 THEN 1 ELSE 
							NVL((select MAX(LineCovered)
								from utcov.Data D
								where D.TestIndex = :tTestIndex
									and D.TestClass = :tTestClass
									and D.TestMethod = :tTestMethod
									and D.RoutineName = :tRtnName
									and D.RoutineType = 'int'
									and R.LineNumber = D.LineNumber),0)
						END
					from utcov.Utils_Result(:tRtnName) R
				)
				If (SQLCODE < 0) {
					Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,$g(%msg))
				}
			}
			
			// Stop the monitor.
			$$$ThrowOnError(##class(%Monitor.System.LineByLine).Stop())
		}
	} Catch anyException {
		// Ensure that the monitor is stopped.
		Do ##class(%Monitor.System.LineByLine).Stop()
		Set tSC = anyException.AsStatus()
	}
	Quit tSC
}

Method SaveResult(duration)
{
	Do ##super()
	Set tOldLogIndex = "TEMP-"_..TempLogIndex
	Set tLogIndex = ..LogIndex
	&sql(update utcov.Data set TestIndex = :tLogIndex where TestIndex = :tOldLogIndex)
	
	Do ##class(utcov.Utils).ConvertToClassCoverage(tLogIndex)
	
	Quit
}

/// Record the end of a test and also return the status of this 
Method LogStateBegin(testsuite, testcase = "", testmethod = "")
{
	Do ##super(testsuite,testcase,testmethod)
	Do ..StartCoverageTracking($Select(..CoverageDetail>0:testcase,1:""),
		$Select(..CoverageDetail>1:testmethod,1:""))
}

/// Record the end of a test and also return the status of this 
Method LogStateEnd(duration) As %Integer
{
	Do ..EndCoverageTracking()
	Quit ##super(duration)
}

}
