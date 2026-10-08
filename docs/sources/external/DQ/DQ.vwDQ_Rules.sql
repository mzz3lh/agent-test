CREATE   VIEW [DQ].[vwDQ_Rules] AS

	SELECT 
     [RuleId] AS 'Rule ID'
	,[PriorityDataField] AS 'Rule'
	,PriorityDataField + ' (' + DQDimension + ')' AS 'Rule w/ Dimension'
	,[D365Entity] AS 'Entity'
	,[D365FieldName] AS 'Field'
	,PKFieldName AS 'PK Field'
	,[DQDimension] AS 'Dimension'
	,[FailureReason]
	,[Threshold]
	,[Active]
	,[DataMapId]
	,BaseFilter
	,RuleScript
	,'SELECT ' + CASE WHEN SelectDistinct = 'Y' THEN 'DISTINCT ' ELSE '' END
		+ CAST(RuleId AS VARCHAR(10))
		+ ',' + CASE WHEN FieldDataType = 'Date' THEN
			'CAST(' + COALESCE(TableAlias + '.', '') + FieldName + ' AS DATE)'
			ELSE 'CAST(' + COALESCE(TableAlias + '.', '') + FieldName + ' AS VARCHAR(1000))' END
		+ ',' + COALESCE(TableAlias + '.', '') + PKFieldName 
		+ ',' + ExtraFieldList AS Exec_Script_Part_1
	,' FROM ' + TableName + COALESCE(' ' + TableAlias, '') 
		+ CASE WHEN RuleScriptJOIN IS NOT NULL THEN ' ' + RuleScriptJOIN ELSE '' END 
		+ COALESCE(' ' + BaseFilter + ' ' + [RuleScript] , '') AS Exec_Script_Part_2
	,'SELECT ' + CAST(RuleId AS VARCHAR(10)) + ', ' + 
		CASE WHEN SelectDistinct = 'Y' THEN 'COUNT(DISTINCT ' + PKFieldName + ')' ELSE 'COUNT(*)' END 
		AS Count_Script_Part_1
	,'FROM'
		+TableName + COALESCE(' ' + TableAlias, '') 
		+ CASE WHEN RuleScriptJOIN IS NOT NULL THEN ' ' + RuleScriptJOIN ELSE '' END 
		+ COALESCE(' ' + BaseFilter , '') AS Count_Script_Part_2
	FROM [DQ].[Rules] R
