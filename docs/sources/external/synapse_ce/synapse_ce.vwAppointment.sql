CREATE   VIEW [synapse_ce].[vwAppointment]
AS

SELECT 
	ap.[ActivityId],
	ap.[ActivityTypeCode],
	ap.[CreatedOn],
	ap.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ap.[ModifiedOn],
	ap.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	ap.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	ap.[Subject],
	ap.[StateCode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ap.[StatusCode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	ap.[OwningUser],
	ap.[OwningTeam],
	ap.[ActualStart],
	ap.[ActualEnd],
	ap.[ActualDurationMinutes],
	ap.[IsBilled],
	stIsbilled.[LocalizedLabel] AS [IsBilled_Description],
	ap.[Description],
	ap.[ScheduledStart],
	ap.[ScheduledEnd],
	ap.[ScheduledDurationMinutes],
	ap.[PriorityCode],
	stprioritycode.[LocalizedLabel] AS [PriorityCode_Description],
	ap.[RegardingObjectId],
	ap.[RegardingObjectTypeCode],
	ap.[IsRegularActivity],
	isregact.[LocalizedLabel] AS [IsRegularActivity_Description],
	ap.[TransactionCurrencyId],
	curr.[currencyname] AS [TransactionCurrencyIdName],
	ap.[ExchangeRate],
	ap.[IsMapiPrivate],
	ismapiprivate.[LocalizedLabel] AS [IsMapiPrivate_Description]
	--[DeliveryPriorityCode]
FROM synapse_ce.appointment ap
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ap.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ap.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON ap.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON ap.[transactioncurrencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ap.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'appointment'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ap.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'appointment'
	LEFT JOIN synapse_ce.OptionSetMetadata stIsbilled
		ON ap.[isbilled] = stIsbilled.[Option]
			AND stIsbilled.[OptionSetName] = 'isbilled'
			AND stIsbilled.[EntityName] = 'appointment'
	LEFT JOIN synapse_ce.OptionSetMetadata stprioritycode
		ON ap.[prioritycode] = stprioritycode.[Option]
			AND stprioritycode.[OptionSetName] = 'prioritycode'
			AND stprioritycode.[EntityName] = 'appointment'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata isregact
		ON ap.[isregularactivity] = isregact.[Option]
			AND isregact.[OptionSetName] = 'isregularactivity'
			AND isregact.[EntityName] = 'appointment'
	LEFT JOIN synapse_ce.OptionSetMetadata ismapiprivate
		ON ap.[ismapiprivate] = ismapiprivate.[Option]
			AND ismapiprivate.[OptionSetName] = 'ismapiprivate'
			AND ismapiprivate.[EntityName] = 'appointment'
