CREATE VIEW [D365_Exception].[RICS_Record_Multiple_Actives] AS

WITH CTE AS (
	SELECT 
	 r.apuk_contactid
	,Rics_contactno AS apuk_contactnumber
	,COUNT(r.apuk_contactid) ConCount
	FROM [synapse_ce].[apuk_ricsrecord] r
	LEFT JOIN synapse_ce.vwContact c
		ON c.contactid = r.apuk_contactid
	WHERE r.statecode = 0
	GROUP BY  
	r.apuk_contactid
	,Rics_contactno
	HAVING COUNT(r.apuk_contactid) > 1
	)

SELECT 
 r.apuk_contactid
,CTE.apuk_contactnumber
,r.createdon
,r.createdbyname
,r.statecode
,r.statuscode
FROM synapse_ce.apuk_ricsrecord r
INNER JOIN CTE
	ON CTE.apuk_contactid = r.apuk_contactid
