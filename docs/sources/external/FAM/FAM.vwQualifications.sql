/****** Object:  View [dbo].[vwQualifications]    Script Date: 26/08/2022 10:50:32 ******/
CREATE   VIEW [FAM].[vwQualifications]
AS

	SELECT DISTINCT 
		Q.Id AS QualRecID,
		AP.id AS CourseRecId,
		Q.apuk_ContactID AS ContactID,
		AP.id AS CourseID, 
		ISNULL(ISNULL(AP.apuk_name, Q.apuk_academiccoursename),'Other Course') AS CourseName, 

		--ISNULL(A.name, ISNULL(Q.apuk_academicinstitution ,'Other Institution')) AS InstitutionName,
		NULL AS OtherInstitution,
		ISNULL(ISNULL(accuni.name, Q.apuk_academicinstitution), 'Other Institution') AS InstitutionName, 
		Q.apuk_completiondate AS CompletionDate,
		Q.modifiedon
	FROM [synapse_ce].[apuk_qualification] Q
		LEFT JOIN [synapse_ce].[account] A 
			ON Q.apuk_institutionid = A.accountid
		LEFT JOIN [synapse_ce].[apuk_accreditedprogramme] AP 
			ON Q.apuk_ricsaccreditedcourse = AP.ID
		LEFT JOIN synapse_ce.account accuni
			ON accuni.accountid = AP.apuk_universityid

		INNER JOIN FAM.vwMember M 
			ON M.ContactID = Q.apuk_contactid
	WHERE apuk_contactid IS NOT NULL
