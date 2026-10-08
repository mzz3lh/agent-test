/****** Object:  View [dbo].[vwDisciplinaries]    Script Date: 26/08/2022 10:50:32 ******/
CREATE   VIEW [FAM].[vwDisciplinaries]
AS

	SELECT 
		apuk_contactId, 
		apuk_weblink,
		DisciplinaryRecId,
		modifiedon
	FROM 
		(
			SELECT  
				D.apuk_contactid,
				apuk_weblink,
				ROW_NUMBER() OVER(PARTITION BY apuk_contactid ORDER BY apuk_contactid DESC) AS rn,
				D.id AS DisciplinaryRecId,
				D.modifiedon
			FROM [synapse_ce].[apuk_disciplinary] D 
			WHERE D.apuk_enddate IS NULL  --Only Active Disciplinaries
				AND apuk_weblink IS NOT NULL
				AND apuk_startDate IS NOT NULL
		) T
	WHERE T.rn = 1  --only the latest disciplinary
