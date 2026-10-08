/****** Object:  View [dbo].[vwricsv2_commercialproductsandstandards]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwricsv2_commercialproductsandstandards]
AS
SELECT
	cps.[apuk_commercialproductorstandardid] AS [ricsv2_commercialproductsandstandardsId],
	cps.[apuk_name] AS [ricsv2_name],
	cps.[apuk_currencyid] AS [TransactionCurrencyId],
	curr.[currencyname] AS [TransactionCurrencyIdName],
	pg.[apuk_name] AS [ricsv2_ProductGroupIdName],
	cps.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	cps.[Createdon] AS [Created_On],
	cps.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	cps.[modifiedon] AS [Modified_On],
	cps.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	cps.[OwningBusinessUnit],
	cps.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	cps.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	cps.[apuk_currentstatus] AS [ricsv2_CurrentStatus],
	currstatus.[LocalizedLabel] AS [ricsv2_CurrentStatus_Description],
	cps.[apuk_commercialaccountid] AS [ricsv2_CommercialAccountId],
	cps.[apuk_productgroupid] AS [ricsv2_ProductGroupId],
	cps.[apuk_performancestatus] AS [ricsv2_PerformanceStatus],
	perfstatus.[LocalizedLabel] AS [ricsv2_PerformanceStatus_Description],
	cps.[apuk_targetstatus] AS [ricsv2_TargetStatus],
	targetstatus.[LocalizedLabel] AS [ricsv2_TargetStatus_Description],
	cps.[apuk_performancesummary] AS [ricsv2_PerformanceSummary],
	cps.[apuk_stage1activitysummary] AS [ricsv2_Stage1ActivitySummary],
	cps.[apuk_stage1completiondate] AS [ricsv2_Stage1CompletionDate],
	cps.[apuk_stage1revisedtargetdate] AS [ricsv2_Stage1RevisedTargetDate],
	cps.[apuk_stage1targetdate] AS [ricsv2_Stage1TargetDate],
	cps.[apuk_stage2activitysummary] AS [ricsv2_Stage2ActivitySummary],
	cps.[apuk_stage2completiondate] AS [ricsv2_Stage2CompletionDate],
	cps.[apuk_stage2revisedtargetdate] AS [ricsv2_Stage2RevisedTargetDate],
	cps.[apuk_stage2targetdate] AS [ricsv2_Stage2TargetDate],
	cps.[apuk_stage3activitysummary] AS [ricsv2_Stage3ActivitySummary],
	cps.[apuk_stage3completiondate] AS [ricsv2_Stage3CompletionDate],
	cps.[apuk_stage3revisedtargetdate] AS [ricsv2_Stage3RevisedTargetDate],
	cps.[apuk_stage3targetdate] AS [ricsv2_Stage3TargetDate],
	cps.[apuk_stage4activitysummary] AS [ricsv2_Stage4ActivitySummary],
	cps.[apuk_stage4completiondate] AS [ricsv2_Stage4CompletionDate],
	cps.[apuk_stage4revisedtargetdate] AS [ricsv2_Stage4RevisedTargetDate],
	cps.[apuk_stage4targetdate] AS [ricsv2_Stage4TargetDate],
	cps.[apuk_stage5activitysummary] AS [ricsv2_Stage5ActivitySummary],
	cps.[apuk_stage5completiondate] AS [ricsv2_Stage5CompletionDate],
	cps.[apuk_stage5revisedtargetdate] AS [ricsv2_Stage5RevisedTargetDate],
	cps.[apuk_stage5targetdate] AS [ricsv2_Stage5TargetDate]
FROM synapse_ce.apuk_commercialproductorstandard cps
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cps.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_commercialproductorstandard'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cps.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_commercialproductorstandard'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cps.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cps.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cps.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON cps.[apuk_currencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.OptionSetMetadata currstatus
		ON cps.[apuk_currentstatus] = currstatus.[Option]
			AND currstatus.[EntityName] = 'apuk_commercialproductorstandard'
			AND currstatus.[OptionSetName] = 'apuk_currentstatus'
	LEFT JOIN synapse_ce.apuk_productgroup pg
		ON cps.[apuk_productgroupid] = pg.[apuk_productgroupid]
	LEFT JOIN synapse_ce.OptionSetMetadata perfstatus
		ON cps.[apuk_performancestatus] = perfstatus.[Option]
			AND perfstatus.[EntityName] = 'apuk_commercialproductorstandard'
			AND perfstatus.[OptionSetName] = 'apuk_performancestatus'
	LEFT JOIN synapse_ce.OptionSetMetadata targetstatus
		ON cps.[apuk_targetstatus] = targetstatus.[Option]
			AND targetstatus.[EntityName] = 'apuk_commercialproductorstandard'
			AND targetstatus.[OptionSetName] = 'apuk_targetstatus'
