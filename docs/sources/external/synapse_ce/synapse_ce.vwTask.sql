/****** Object:  View [dbo].[vwTask]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwTask]
AS
SELECT
	tsk.[ActivityId],
	tsk.[createdon] AS [Created_On],
	tsk.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	tsk.[CreatedOnBehalfBy],
	usrcreatedonbehalfby.[fullname] AS [CreatedOnBehalfByName],
	tsk.[modifiedon] AS [Modified_On],
	tsk.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	tsk.[ModifiedOnBehalfBy],
	usrmodifiedonbehalfby.[fullname] AS [ModifiedOnBehalfByName],
	tsk.[TransactionCurrencyId],
	curr.[currencyname] AS [TransactionCurrencyIdName],
	tsk.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	tsk.[Subject],
	tsk.[Description],
	tsk.[ActualStart],
	tsk.[ActualEnd],
	tsk.[RegardingObjectId], 
	rec.[apuk_name] AS [RegardingObjectIdName],
	tsk.[ScheduledDurationMinutes],
	tsk.[ScheduledStart],
	tsk.[ScheduledEnd],
	tsk.[Category],
	tsk.[Subcategory],
	tsk.[IsWorkflowCreated],
	iswrkflow.[LocalizedLabel] AS [IsWorkflowCreated_Description],
	tsk.[PercentComplete],
	tsk.[SubscriptionId],
	tsk.[PriorityCode],
	priorcode.[LocalizedLabel] AS [PriorityCode_Description],
	tsk.[ServiceId], 
	tsk.[ActualDurationMinutes],
	tsk.[StateCode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	tsk.[StatusCode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	tsk.[IsBilled],
	isbilled.[LocalizedLabel] AS [isbilled_Description],
	tsk.[RegardingObjectTypeCode],
	tsk.[OverriddenCreatedOn],
	tsk.[IsRegularActivity],
	isregact.[OptionSetName] AS [isregularactivity_Description],
	tsk.[ActivityTypeCode],
	tsk.[ExchangeRate],
	tsk.[ProcessId], 
	tsk.[OwningTeam],
	tsk.[OwningUser],
	tsk.[OnHoldTime],
	tsk.[LastOnHoldTime],
	tsk.[SLAId],
	tsk.[SLAName],
	tsk.[StageId]
FROM synapse_ce.task tsk
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON tsk.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'task'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON tsk.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'task'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON tsk.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON tsk.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON tsk.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrcreatedonbehalfby
		ON tsk.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedonbehalfby
		ON tsk.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON tsk.[transactioncurrencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.apuk_ricsrecord rec
		ON tsk.[regardingobjectid] = rec.[apuk_ricsrecordid]
	LEFT JOIN synapse_ce.OptionSetMetadata priorcode
		ON tsk.[prioritycode] = priorcode.[Option]
			AND priorcode.[EntityName] = 'task'
			AND priorcode.[OptionSetName] = 'prioritycode'
	LEFT JOIN synapse_ce.OptionSetMetadata iswrkflow
		ON tsk.[isworkflowcreated] = iswrkflow.[Option]
			AND iswrkflow.[EntityName] = 'task'
			AND iswrkflow.[OptionSetName] = 'isworkflowcreated'
	LEFT JOIN synapse_ce.OptionSetMetadata isbilled
		ON tsk.[isbilled] = isbilled.[Option]
			AND isbilled.[EntityName] = 'task'
			AND isbilled.[OptionSetName] = 'isbilled'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata isregact
		ON tsk.[isregularactivity] = isregact.[Option]
			AND isregact.OptionSetName = 'isregularactivity'
			AND isregact.[EntityName] = 'task'
