Include %occInclude

Class utcov.Utils
{

ClassMethod GetLineText(pRoutineName, pRoutineType, pLineNumber) As %String [ SqlProc ]
{
	Set tText = "not yet implemented"
	If (pRoutineType = "int") {
		Quit $Text(@("+"_pLineNumber_"^"_pRoutineName))
	}
	Quit tText
}

ClassMethod ConvertToClassCoverage(pTestIndex As %String)
{
	// Get .int routines
	Set tRes = ##class(%SQL.Statement).%ExecDirect(,"select distinct %exact RoutineName RoutineName from utcov.Data where TestIndex = ? and RoutineType = 'int'",pTestIndex)
	While tRes.%Next(.tSC) {
		$$$ThrowOnError(tSC)
		Set tRtnName = tRes.%Get("RoutineName")
		Set tOther = ##class(%Library.RoutineMgr).GetOther(tRtnName,"int",-1)
		Set tClassName = $Piece(tOther,".",1,*-1)
		If (tOther '= "") && ($Piece(tOther,".",*) = "CLS") {
			If '$Data(tVisistedClasses(tOther)) {
				Kill tDocumentText, tMethodMap
				$$$ThrowOnError(##class(%Compiler.UDL.TextServices).GetTextAsArray(,tClassName,.tDocumentText))
				
				// Clear existing data
				&sql(delete from utcov.Data where TestIndex = :pTestIndex and RoutineName = :tClassName and RoutineType = 'cls')
				
				// Create table with class document's text
				Set tMethod = "", tInBlockComment = 0
				Set tDocumentText = $Order(tDocumentText(""),-1)
				For i=1:1:$Get(tDocumentText) {
					Set tLine = tDocumentText(i)
					&sql(insert or update into utcov.Data
						(TestIndex, TestClass, TestMethod,
							RoutineName, RoutineType,
							LineText, LineNumber, LineCovered)
						select distinct by (NVL(TestClass,''),NVL(TestMethod,'')) :pTestIndex, TestClass, TestMethod,
							:tClassName, 'cls',
							:tLine, :i, 0
						from utcov.Data
							where TestIndex = :pTestIndex
								and RoutineType = 'int'
								and RoutineName = :tRtnName)
					If (SQLCODE < 0) {
						Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
					}
					
					// Extract line offset of method in class
					Set tStart = $Extract(tLine,1,6)
					If (tStart = "ClassM") || (tStart = "Method") {
						Set tMethod = $Piece($Piece(tLine,"(")," ",2)
						Set tMethodMap(tMethod) = i
					}
				}
				
				Merge tVisistedClasses(tOther) = tDocumentText
				Merge tMethodMaps(tOther) = tMethodMap
			}
			
			// Try to map each executed line in the routine back to a line in the class.
			Set tResLines = ##class(%SQL.Statement).%ExecDirect(,"select distinct LineNumber "_
					"from utcov.Data "_
					"where TestIndex = ? "_
					"	and RoutineType = 'int' "_
					"	and RoutineName = ? "_
					"	and LineCovered = 1 ", pTestIndex, tRtnName)
			While (tResLines.%Next(.tSC)) {
				$$$ThrowOnError(tSC)
				Kill tMap
				$$$ThrowOnError(##class(%Studio.Debugger).SourceLine(tRtnName, tResLines.%Get("LineNumber"), 1, tResLines.%Get("LineNumber"), $Length(..GetLineText(tRtnName,"int",tResLines.%Get("LineNumber"))), $Namespace, .tMap))
				
				If $Data(tMap("CLS",1),tData1) && $Data(tMap("CLS",2),tData2) {
					Set $ListBuild(tClass1,tMethod1,tLine1) = tData1
					Set $ListBuild(tClass2,tMethod2,tLine2) = tData2
					If $Data(tMethodMaps(tOther,tMethod1),tMethodOffset) {
						For tLine = tLine1:1:tLine2 {
							Set tClassLine = tMethodOffset+1+tLine
							&sql(update utcov.Data
								set LineCovered = 1
								where TestIndex = :pTestIndex
									and RoutineType = 'cls'
									and RoutineName = :tClassName
									and LineNumber = :tClassLine
									/*and exists (
										select top 1 1 from utcov.Data OTHER
										where OTHER.TestIndex = :pTestIndex
											and OTHER.RoutineType = 'int'
											and OTHER.RoutineName = :tRtnName
											and OTHER.LineNumber = :tRes.%Get("LineNumber")
											and OTHER.LineCovered = 1
											and OTHER.TestClass = D.TestClass
											and OTHER.TestMethod = D.TestMethod
									)*/
							)
							If (SQLCODE < 0) {
								Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE,%msg)
							}
						}
					}
				}
			}
			$$$ThrowOnError(tSC)
		}
	}
	$$$ThrowOnError(tSC)
}

Query Result(pRoutine As %String) As %Query(ROWSPEC = "LineNumber:%Integer,LineCovered:%Boolean") [ SqlProc ]
{
}

ClassMethod ResultExecute(ByRef qHandle As %Binary, pRoutine As %String) As %Status
{
	Quit ##class(%Monitor.System.LineByLine).ResultExecute(.qHandle,pRoutine)
}

ClassMethod ResultFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ PlaceAfter = ResultExecute ]
{
	Set tLine = $Piece(qHandle,"^",2)
	Set tSC = ##class(%Monitor.System.LineByLine).ResultFetch(.qHandle,.Row,.AtEnd)
	If 'AtEnd {
		Set tCovered = $Case($ListGet($List(Row,1),1),0:0,"":0,:1)
		Set Row = $ListBuild(tLine,tCovered)
	}
	Quit $$$OK
}

ClassMethod ResultClose(ByRef qHandle As %Binary) As %Status [ PlaceAfter = ResultExecute ]
{
	Quit ##class(%Monitor.System.LineByLine).ResultClose(.qHandle)
}

}
