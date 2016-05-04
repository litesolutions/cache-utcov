Class utcov.Data Extends %Persistent
{

Index CoverageDataPK On (TestIndex, TestClass, TestMethod, RoutineName, RoutineType, LineNumber) [ Data = (LineText, LineCovered, Executable), Unique ];

Property TestIndex As %String;

Property TestClass As %String(COLLATION = "SQLUPPER(125)", MAXLEN = 255);

Property TestMethod As %String(COLLATION = "SQLUPPER(125)", MAXLEN = 255);

Property RoutineName As %String(COLLATION = "SQLUPPER(125)", MAXLEN = 255);

Property RoutineType As %String(MAXLEN = 3);

Property LineNumber As %Integer;

Property LineText As %String(MAXLEN = "");

Property LineCovered As %Boolean;

Property Executable As %Boolean [ InitialExpression = 0 ];

Index TestIndex On TestIndex [ Type = bitmap ];

Index TestClass On TestClass [ Type = bitmap ];

Index TestMethod On TestMethod [ Type = bitmap ];

Index RoutineName On RoutineName [ Type = bitmap ];

Index RoutineType On RoutineType [ Type = bitmap ];

Index LineNumber On LineNumber [ Type = bitmap ];

Index LineCovered On LineCovered [ Type = bitmap ];

Index Executable On Executable [ Type = bitmap ];

/// Supports Coverage.Utils:ConvertToClassCoverage
Index TestedRoutine On (TestIndex, RoutineType, RoutineName As Exact, LineNumber);

/// Supports Coverage.Utils:ConvertToClassCoverage
Index CoveredIntLines On (TestIndex, RoutineType, RoutineName, LineNumber, LineCovered, TestClass, TestMethod);

Storage Default
{
<Data name="DataDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>TestIndex</Value>
</Value>
<Value name="3">
<Value>TestClass</Value>
</Value>
<Value name="4">
<Value>TestMethod</Value>
</Value>
<Value name="5">
<Value>RoutineName</Value>
</Value>
<Value name="6">
<Value>RoutineType</Value>
</Value>
<Value name="7">
<Value>LineNumber</Value>
</Value>
<Value name="8">
<Value>LineText</Value>
</Value>
<Value name="9">
<Value>LineCovered</Value>
</Value>
<Value name="10">
<Value>Executable</Value>
</Value>
</Data>
<DataLocation>^Coverage.DataD</DataLocation>
<DefaultData>DataDefaultData</DefaultData>
<IdLocation>^Coverage.DataD</IdLocation>
<IndexLocation>^Coverage.DataI</IndexLocation>
<StreamLocation>^Coverage.DataS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
