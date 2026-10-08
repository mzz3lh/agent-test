CREATE VIEW [dbo].[vwTeam]
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
FROM [Ext].[PBI02_dbo_vwTeam]
