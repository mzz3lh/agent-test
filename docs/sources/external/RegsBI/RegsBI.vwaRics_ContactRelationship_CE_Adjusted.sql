CREATE VIEW [RegsBI].[vwaRics_ContactRelationship_CE_Adjusted] AS 

WITH MAXX AS (
	SELECT 
	 rics_contactid
	,rics_accountid
	,MAX(Created_On) AS Max_Created_Date
	FROM [synapse_ce].[vwRics_ContactRelationship]
	WHERE Rics_EndDate IS NULL
	GROUP BY rics_contactid, rics_accountid
	)

SELECT 
	CRL.[Rics_contactrelationshipId],
	CRL.[Rics_name],
	CRL.[rics_contactid],
	CRL.[ContactIdName],
	CRL.[rics_accountid],
	CRL.[AccountIdName],
	CRL.[Rics_FirmNumber],
	CRL.[Created_On],
	CRL.[CreatedBy],
	CRL.[CreatedByName],
	CRL.[Modified_On],
	CRL.[ModifiedBy],
	CRL.[ModifiedByName],
	CRL.[Rics_RelationshipType],
	CRL.[Rics_RelationshipType_Description],
	CRL.[Rics_PublishinDirectory],
	CRL.[Rics_PublishinDirectory_Description],
	CRL.[Rics_StartDate],
	CRL.[Rics_EndDate],
	CRL.[statecode],
	CRL.[StateCode_Description],
	CRL.[statuscode],
	CRL.[StatusCode_Description],
	CRL.[Rics_IsParentAccount],
	CRL.[Rics_BusinessPhone],
	CRL.[Rics_BusinessEmail],
	CRL.[Rics_JobTitle],
	CRL.apuk_primaryemployment
FROM [synapse_ce].[vwRics_ContactRelationship] CRL
INNER JOIN MAXX MAXX
	ON MAXX.rics_contactid = CRL.rics_contactid
	AND MAXX.rics_accountid = CRL.rics_accountid
	AND MAXX.Max_Created_Date = CRL.Created_On
WHERE CRL.Rics_EndDate IS NULL
AND CRL.statecode = 0
