CREATE VIEW [DQ].[vwDQ_Results] AS

	SELECT
	 res.ResultId
	,res.RuleId
	--,r.DQDimension
	--,r.DataMapId
	--,r.PriorityDataField
	--,dm.L1 Domain
	--,dm.DataOwner
	--,r.[RuleId]
	--,r.D365Entity
	--,r.TableName
	--,r.FieldName
	,res.[FieldValue] AS 'Field Value'
	--,CASE WHEN res.[Result] = 1 THEN 'Pass' WHEN res.[Result] = 0 THEN 'Fail' ELSE NULL END AS PassOrFail
	--,CASE WHEN res.[Result] = 1 THEN 1 ELSE NULL END Pass
	--,CASE WHEN res.[Result] = 0 THEN 1 ELSE NULL END Fail
	--,res.Result
	--,CASE WHEN res.[Result] = 0 THEN r.FailureReason END AS FailureReason		
	,res.CreatedBy AS 'Created By'
	,res.ModifiedBy AS 'Modified By'
	,res.Region AS 'local_group_id'
	,res.[SourceRowId]
	,res.ExtraInfo1
	,res.ExtraInfo2
	--,res.[JobExecId]
	,CAST(l.StartDateTime AS DATE) AS ExecDate
	FROM 
	[DQ].[RuleValidationResults] res
	LEFT JOIN [DQ].RulesExecLog l
		ON l.ExecId = res.JobExecId
