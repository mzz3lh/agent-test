/****** Object:  View [dbo].[vwEmploymentRelationship]    Script Date: 26/08/2022 10:50:32 ******/
CREATE   VIEW [FAM].[vwEmploymentRelationship]
AS

	SELECT 
		apuk_contactId, 
		EmpJobTitle,
		ERRecId,
		apuk_PrimaryEmployment, 
		apuk_startdate, 
		statecode,
		apuk_accountid,
		modifiedon
	FROM 
	(
		SELECT 
			ER.apuk_contactid, 
			ER.apuk_jobtitle AS EmpJobTitle,
			ROW_NUMBER() OVER(PARTITION BY apuk_contactid ORDER BY apuk_startdate DESC) AS rn,
			ER.id AS ERRecId,
			ER.apuk_PrimaryEmployment,
			ER.apuk_startdate,
			ER.statecode,
			ER.apuk_accountid,
			ER.modifiedon
		FROM [synapse_ce].[apuk_employmentrelationship] ER
		WHERE ER.apuk_enddate IS NULL  --Only Active Employment Relationships
			--AND apuk_startDate IS NOT NULL
			AND apuk_primaryemployment = 1
			AND statecode = 0

		) T
	WHERE T.rn = 1   --Get latest one if more than one primary employment (there are about 600+ in live)
