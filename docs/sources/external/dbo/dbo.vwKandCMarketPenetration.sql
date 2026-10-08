CREATE VIEW [dbo].[vwKandCMarketPenetration]
AS

SELECT DISTINCT 
KC.ContactNo AS [Contact No], 
KC.[Member Grade],
KC.rics_localgroupidName AS [Local Group], 
KC.SubscriptionProduct AS Package,
KC.Channel,
KC.NoOfPackages AS [No of Packages],
KC.ContactNo AS [Subscription Owner Contact No],
CASE ISNULL(CS.[Owner ContactNo],0)
WHEN 0 THEN 'No'
ELSE 'Yes'
END AS [Is Corporate],
CS.[Company Name],
CASE ISNULL(SP.[rics_contactno],0)
WHEN 0 THEN 'No'
ELSE 'Yes'
END AS [Paid Member],
ISNULL(KC.Rics_ReportingSubWorldRegion,'Not Known') AS [Sub World Region]
 FROM [dbo].[vwKandCStats] KC
  LEFT JOIN   [SubsRep_BI].[vwSubsPayments] SP ON SP.rics_contactno = KC.ContactNo
  AND  SP.CampaignYear >= 2021
  LEFT JOIN [dbo].[vwCorporateSubscribers] CS ON KC.ContactNo = CS.[Owner ContactNo]
