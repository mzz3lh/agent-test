CREATE   VIEW [FAM].[vwContactImagesNotInFAM]
AS

	WITH cte as 
	(
		SELECT c.id, c.apuk_contactnumber,c.entityimage_url, c.createdon, c.modifiedon, c.entityimageid, apuk_memberupdatedphoto
		FROM [synapse_ce].[contact] c
		WHERE c.entityimage_url IS NOT NULL
			--AND c.apuk_memberupdatedphoto IS NULL 
			
	)
	SELECT t1.[apuk_contactnumber] 
	FROM cte t1
		LEFT JOIN [FAM].[tblContactImages] ci
			ON t1.Id = ci.contactid
	WHERE ci.contactid IS NULL
