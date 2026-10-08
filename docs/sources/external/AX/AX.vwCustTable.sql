CREATE VIEW [AX].[vwCustTable]
AS
SELECT 
	[AccountNum],
	[Name],
	[CustGroup],
	[Currency],
	[CountryRegionId],
	[ZipCode],
	[PaymMode],
	[RicActive],
	[PartyID],
	[RecID],
	[DataAreaID],
	[BI_Created],
	[BI_Modified],
	[BI_Deleted],
	[City],
	[TaxGroup]
FROM [Ext].[PBI02_AX_vwCustTable]
