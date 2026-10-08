*/
/****** Object:  View [dbo].[vwQueueItem]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwQueueItem]
AS
SELECT
	qi.[QueueItemId],
	qi.[createdon] AS [Created_On],
	qi.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	qi.[modifiedon] AS [Modified_On],
	qi.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	qi.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	qi.[OwnerIdType],
	qi.[QueueId], 
	q.[name] AS [QueueIdName],
	qi.[OrganizationId], 
	org.[name] AS [OrganizationIdName],
	qi.[TransactionCurrencyId],
	curr.[currencyname] AS [TransactionCurrencyIdName],
	qi.[ObjectId], 
	NULL AS [ObjectIdName], --portcomm.[description] AS [ObjectIdName],
	qi.[ObjectTypeCode],
	objtypecode.[LocalizedLabel] AS [ObjectTypeCode_Description],
	qi.[Title],
	qi.[EnteredOn],
	qi.[Priority],
	qi.[state],
	qi.[status],
	qi.[StateCode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	qi.[StatusCode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	qi.[ToRecipients],
	qi.[Sender],
	qi.[WorkerId], 
	qi.[WorkerIdName],
	qi.[WorkerIdType],
	qi.[ExchangeRate]
FROM synapse_ce.queueitem qi
	LEFT JOIN synapse_ce.queue q
		ON qi.[queueid] = q.[queueid]
	LEFT JOIN synapse_ce.organization org
		ON qi.[organizationid] = org.[organizationid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON qi.[transactioncurrencyid] = curr.[transactioncurrencyid]
	--LEFT JOIN synapse_ce.adx_portalcomment portcomm
	--	ON qi.[objectid] = portcomm.[activityid]
	LEFT JOIN synapse_ce.OptionSetMetadata objtypecode
		ON qi.[objecttypecode] = objtypecode.[Option]
			AND objtypecode.[EntityName] = 'queueitem'
			AND objtypecode.[OptionSetName] = 'objecttypecode'
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON qi.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'queueitem'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON qi.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'queueitem'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON qi.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON qi.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON qi.[ownerid] = ownid.[systemuserid]
