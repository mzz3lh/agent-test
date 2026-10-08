CREATE VIEW CE.vwARC_Psuedo_Contact_No AS
	SELECT
	[Contact No]
	,abs(checksum(NewId()) % 1000000) AS 'Random ID'
	FROM (
		SELECT
		Rics_contactno AS 'Contact No'
		FROM [CE].[vwRics_Assessor] ASS
		LEFT JOIN CE.vwContact CON
			ON CON.ContactId = ASS.rics_contactid 
		GROUP BY Rics_contactno

		UNION

		SELECT
		rics_contactno
		FROM [CE].[tblApplications] APP
		GROUP BY Rics_contactno
		) UNI
	WHERE [Contact No] IS NOT NULL
