CREATE VIEW [DQ].[vwDQ_ResultsHistory]
AS 

/*=============================================
	Author:			srini.akula
	Create date:	07.02.2022
	Description:	Returns the aggregated dats fro the DQ rule validation results. The purpose is to return only the aggregated values rather than the entire results for each run period

	Change history			
		07/05/2022	s.akula	Added JOINs to get data from [DQ].Rules & [DQ].DataMap

					
	Purpose:		This view feeds the DQ Dashboard/reports(PBI)

	SELECT * FROM [DQ].[vwDQResultsSummary] 
===============================================================================*/

	SELECT
	  res.RunDate AS 'Run Date'
	 ,res.RuleId
	--,dm.L1 AS Domain
	--,dm.[DataOwner]
	--,res.[DQDimension]
	--,r.[PriorityDataField]
	,Pass
	,Fail
	,Pass + Fail AS Total
	 FROM DQ.ValidationResultsSummary res
	LEFT JOIN [DQ].Rules r 
		ON r.RuleId = res.RuleId
	LEFT JOIN [DQ].DataMap dm 
		ON dm.DataMapId = r.DataMapId
