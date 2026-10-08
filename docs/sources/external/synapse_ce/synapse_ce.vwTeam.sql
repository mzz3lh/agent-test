/****** Object:  View [dbo].[vwTeam]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwTeam]
AS
SELECT 
	tm.[TeamId],
	tm.[Name],
	tm.[createdon] AS [Created_On],
	tm.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	tm.[modifiedon] AS [Modified_On],
	tm.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	tm.[BusinessUnitId],
	bu.[name] AS [BusinessUnitIdName],
	tm.[OrganizationId],
	org.[name] AS [OrganizationIdName],
	tm.[QueueId],
	q.[name] AS [QueueIdName],
	tm.[AdministratorId],
	usradmin.[fullname] AS [AdministratorIdName],
	tm.[TransactionCurrencyId],
	curr.[currencyname] AS [TransactionCurrencyIdName],
	tm.[Description],
	tm.[ExchangeRate],
	tm.[TeamType],
	teammtype.[LocalizedLabel] AS [TeamType_Description]
FROM [synapse_ce].[team] tm
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON tm.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON tm.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.businessunit bu
		ON tm.[businessunitid] = bu.[businessunitid]
	LEFT JOIN synapse_ce.organization org
		ON tm.[organizationid] = org.organizationid
	LEFT JOIN synapse_ce.queue q
		ON tm.[queueid] = q.[queueid]
	LEFT JOIN synapse_ce.systemuser usradmin
		ON tm.[administratorid] = usradmin.[systemuserid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON tm.[transactioncurrencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.OptionSetMetadata teammtype
		ON tm.[teamtype] = teammtype.[Option]
			AND teammtype.[EntityName] = 'team'
			AND teammtype.[OptionSetName] = 'teamtype'
