/**************************************************************************************************

View for K and C stats using source tables

Connection: az-pbi-prod-uks-epdbs01.database.windows.net
Database: az-sqldb-uks-dev-pbi01

********************************************************************************************************/
CREATE VIEW [dbo].[vwKandCStats]
AS

SELECT DISTINCT SUB.ricsv1_SubscriptionProductName AS SubscriptionProduct,
c.EMailAddress1 AS Email,   
c.ContactId AS ContactId,
	   c.firstname AS FirstName, 
	   C.LastName AS LastName,
       c.Rics_contactno AS ContactNo,
	   SUBO.Created_On AS DateSOCreated,
	   SO.DateFulfilled AS DateSOFulfilled,--SUBO.CreatedOn AS DateSOCreated,
	   SOD.Product_Name AS ProductName, --was --SP.ricsv2_Code AS ProductCode,
	   CAST(SOD.Quantity AS int) AS NoOfPackages,
	   CASE SUBO.SubscriptionOwnerId
		 WHEN  '00000000-0000-0000-0000-000000000000' THEN 100  --Cushman and Wakefield incorrect no of licenses
		 ELSE SUBO.ricsv1_totalLicences
		 END AS TotalNoOfLicences,
	   SUBO.ricsv2_subscriptionownerNo AS OwnerNo,
	   SO.SalesOrderID,
	   SOD.ExtendedAmount_Base AS LineTotal,       --SOD.BaseAmount_Base AS LineTotal,         --+ SOD.Tax_base AS LineTotal -- Changed to Ex-VAT value 22/02/2021 DBA/PS,
	   CASE  ISNULL(SO.ricsv1_source,'CRM') 
	   WHEN 'CRM' THEN 'Non-Digital'
	   WHEN 'Web' THEN 'Digital'
	   END AS Channel,
	   C.rics_countryidName AS Country,

	   --Additional Fields
	   SUB.ricsv2_subscriptionId,
	   SUB.ricsv2_SubscriptionNo,
	   SUB.ricsv2_Subscriptionsid,
	   SUB.ricsv2_SubscriptionsidName,
		C.rics_localgroupid,
		C.rics_localgroupidName,
		RG.Rics_ReportingLocalGroup,
		RG.Rics_ReportingRegionIdName,
		RG.Rics_ReportingSubWorldRegion,
		RG.ricsv2_ReportingWorldRegionIdName,
		C.rics_primaryprofessionalgroupid,
		C.rics_primaryprofessionalgroupidName,
		0 AS IsFirstTimeMarket,
		C.MemberGrade_Description AS [Member Grade]

FROM [dbo].[vwricsv2subscription] SUB 
LEFT JOIN [dbo].[vwsubscriptionowner] SUBO ON SUB.ricsv2_subscriptionsid = SUBO.subscriptionownerid 
LEFT JOIN dbo.vwcontact C ON SUBO. ricsv2_Contact= c.contactid
LEFT JOIN dbo.vwSalesOrder SO ON SO.SalesOrderId = SUB.ricsv1_SalesOrderId
LEFT JOIN dbo.vwSalesOrderDetail AS SOD ON SO.SalesOrderId = SOD.SalesOrderId
																				AND SOD.ricsv1_SubscriptionProduct = SUB.ricsv1_SubscriptionProduct
LEFT JOIN dbo.vwStringMap AS SM1 ON SUBO.ricsv2_Channel = SM1.AttributeValue
                                                      AND SM1.AttributeName = 'ricsv2_Channel'
                                                      AND SM1.ObjectTypeCode = '00000'
LEFT JOIN dbo.vwRicsgroup RG ON C.rics_localgroupid = RG.Rics_groupId
														AND RG.Rics_name LIKE 'Local Group%'
														AND RG.statecode = 0
WHERE SOD.ProductId IN('00000000-0000-0000-0000-000000000000', '00000000-0000-0000-0000-000000000000') --SP.ricsv2_Code IN ('KACMP','KACCP')
AND SO.DateFulfilled >='2020-08-01T00:00:00.000'  --was --SO.CreatedOn >='2020-09-01T00:00:00.000'  --initial start datetime   -what is the start of the  fiscal year?
AND SO.SalesOrderId IS NOT NULL
AND SO.StateCode = 3  --Fulfilled
