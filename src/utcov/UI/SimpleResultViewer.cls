Class utcov.UI.SimpleResultViewer extends %ZEN.Component.page {

Parameter PAGENAME = "Unit Test Coverage - Simple Results Viewer";

XData Style
{

<style type="text/css">
/* From http://codepen.io/elomatreb/pen/hbgxp */
body {
  background-color: #eee;
  color: #555;
}

/* Modified from pre.coverage */
.box {
  background-color: #fff;
  padding: 0.5em;
  margin-top: 2em;
  border-radius: .25em;
  box-shadow: 0.1em 0.1em 0.5em rgba(0, 0, 0, 0.45);
}

/* From http://codepen.io/elomatreb/pen/hbgxp */
pre.coverage {
  font-family: monospace;
  background-color: #fff;
  margin-top: 2em;
  margin-left: 4em auto;
  margin-right: 4em auto;
  padding: 0.5em;
  border-radius: .25em;
  box-shadow: 0.1em 0.1em 0.5em rgba(0, 0, 0, 0.45);
  line-height: 0;
  counter-reset: line;
}
pre.coverage span {
  display: block;
  line-height: 1.5rem;
}
pre.coverage span:before {
  counter-increment: line;
  content: counter(line);
  display: inline-block;
  border-right: 1px solid #ddd;
  padding: 0 .5em;
  margin-right: .5em;
  min-width: 3em;
  color: #888;
}

/* Classes for display of code coverage */
pre.coverage span.executable {
  background-color: #f66;
}

pre.coverage span.covered {
  background-color: #6f6;
}

</style>
}

XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen">

<vgroup width="80%" align="center">
<vgroup labelPosition="left" align="left" enclosingClass="box">
<select id="testIndex" label="Test Index" sql="select distinct TestIndex from utcov.Data" onchange="zenPage.testFilterChanged(zenThis)" />
<select id="testClass" label="Test Class" sql="select distinct %exact TestClass from utcov.Data where TestIndex = ?" onchange="zenPage.testFilterChanged(zenThis)">
<parameter value="" />
</select>
<select id="testMethod" label="Test Method" sql="select distinct %exact TestMethod from utcov.Data where TestIndex = ? and TestClass = ?" onchange="zenPage.testFilterChanged(zenThis)">
<parameter value="" />
<parameter value="" />
</select>

<spacer height="25px" />

<select id="codeCovered" label = "Code Module"
	sql="select distinct %exact RoutineName||'.'||RoutineType
			from utcov.Data d,(select ? as TestIndex, ? as TestClass, ? as TestMethod) params
			where d.TestIndex = params.TestIndex
				and (params.TestClass is null or params.TestClass = d.TestClass)
				and (params.TestMethod is null or params.TestMethod = d.TestMethod)
			order by DECODE(RoutineType,'cls',1,'mac',2,3)"
	onchange="zenPage.showCodeCoverage();">
<parameter value="" />
<parameter value="" />
<parameter value="" />
</select>
</vgroup>

<altJSONSQLProvider id="coverageDataProvider" 
	sql="select distinct d.LineText text, MAX(d.LineCovered) covered, d.Executable executable
			from utcov.Data d,(select ? as TestIndex, ? as TestClass, ? as TestMethod, ? as RoutineName, ? as RoutineType) params
			where d.TestIndex = params.TestIndex
				and (params.TestClass is null or params.TestClass = d.TestClass)
				and (params.TestMethod is null or params.TestMethod = d.TestMethod)
				and d.RoutineName = params.RoutineName
				and d.RoutineType = params.RoutineType
			group by LineNumber
			order by LineNumber">
<!--TODO: Find out if there's a better way to identify/use parameters by paramName?-->
<parameter paramName="1" value="" />
<parameter paramName="2" value="" />
<parameter paramName="3" value="" />
<parameter paramName="4" value="" />
<parameter paramName="5" value="" />
</altJSONSQLProvider>

<html id="coverageResults" align="left">
</html>

</vgroup>

</page>
}

ClientMethod testFilterChanged(pSrcComponent As %ZEN.Component.select) [ Language = javascript ]
{
	if (pSrcComponent.id == 'testIndex') {
		zen('testClass').parameters[0].value = pSrcComponent.getValue();
		zen('testMethod').parameters[0].value = pSrcComponent.getValue();
		zen('codeCovered').parameters[0].value = pSrcComponent.getValue();
		zen('coverageDataProvider').parameters[1].value = pSrcComponent.getValue();
	}
	
	if (pSrcComponent.id == 'testClass') {
		zen('testMethod').parameters[1].value = pSrcComponent.getValue();
		zen('codeCovered').parameters[1].value = pSrcComponent.getValue();
		zen('coverageDataProvider').parameters[2].value = pSrcComponent.getValue();
	}
	
	if (pSrcComponent.id == 'testMethod') {
		zen('codeCovered').parameters[2].value = pSrcComponent.getValue();
		zen('coverageDataProvider').parameters[3].value = pSrcComponent.getValue();
	}	
	
	zen('testClass').refreshContents();
	zen('testMethod').refreshContents();
	zen('codeCovered').refreshContents();

	if (zen('codeCovered').getValue() != '') {
		this.showCodeCoverage();
	}
}

ClientMethod showCodeCoverage() [ Language = javascript ]
{
	var targetCode = zen('codeCovered').getValue().split('.');
	var targetType = targetCode.pop();
	var targetName = targetCode.join('.');
	zen('coverageDataProvider').parameters[4].value = targetName;
	zen('coverageDataProvider').parameters[5].value = targetType;
	zen('coverageDataProvider').reloadContentsAsynch(function() {
		var code = zen('coverageDataProvider').getContentObject().children;
		var html = '<pre class="coverage">\r\n';
		for (var i = 0; i < code.length; i++) {
			var classes = new Array();
			if (code[i].covered) classes.push("covered");
			if (code[i].executable) classes.push("executable");
			html += '<span class="'+classes.join(' ')+'">'+code[i].text.escapeHTML()+'</span>\r\n';
		}
		html += '</pre>';
		zen('coverageResults').setContent(html);
	});
}

Method %OnDrawObjectProperties()
{
	//From http://stackoverflow.com/questions/5499078/fastest-method-to-escape-html-tags-as-html-entities
	&js<
		String.prototype.escapeHTML = function() {
		    var tagsToReplace = {
		        '&': '&amp;',
		        '<': '&lt;',
		        '>': '&gt;'
		    };
		    return this.replace(/[&<>]/g, function(tag) {
		        return tagsToReplace[tag] || tag;
		    });
		};
	>
}

}