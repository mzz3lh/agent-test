CREATE VIEW [dbo].[vwSystemUser]
AS

SELECT
	[SystemUserId],
	[BusinessUnitIdName],
	[CreatedBy],
	[CreatedByName],
	[Created_On],
	[ModifiedBy],
	[ModifiedByName],
	[Modified_On],
	[OrganizationId],
	[OrganizationIdName],
	[TerritoryId],
	[TerritoryIdName],
	[FirstName],
	[MiddleName],
	[LastName],
	[FullName],
	[Title],
	[JobTitle],
	[DomainName],
	[IsDisabled],
	[IsActiveDirectoryUser],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted]
FROM [Ext].[PBI02_dbo_vwSystemUser]
