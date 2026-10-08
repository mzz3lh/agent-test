CREATE   VIEW [RegsBI].[vwTeam_CE]
AS 
SELECT 
	[TeamId],
	[Name],
	[Created_On],
	[CreatedBy],
	[CreatedByName],
	[Modified_On],
	[ModifiedBy],
	[ModifiedByName],
	[BusinessUnitId],
	[BusinessUnitIdName],
	[OrganizationId],
	[OrganizationIdName],
	[QueueId],
	[QueueIdName],
	[AdministratorId],
	[AdministratorIdName],
	[TransactionCurrencyId],
	[TransactionCurrencyIdName],
	[Description],
	[ExchangeRate],
	[TeamType],
	[TeamType_Description]
FROM [synapse_ce].[vwTeam]
