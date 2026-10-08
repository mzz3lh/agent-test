CREATE   VIEW [FAM].[vwMemberLastModified]
AS
	SELECT tab.ContactId, MAX(tab.modifiedon) AS modifiedon
	FROM
	(
		SELECT apuk_contactid as ContactId, MAX(modifiedon) AS modifiedon, 'ricsrecord' as Source
		FROM synapse_ce.apuk_ricsrecord
		GROUP BY apuk_contactid

		UNION

		SELECT contactid, MAX(apuk_memberupdatedphoto) AS modifiedon, 'picture updated' as source
		FROM	FAM.tblContactImages
		GROUP BY contactid

		UNION

		SELECT 
			C.[contactid], MAX(MCD.modifiedon) AS modifiedon, 'chartered desig' as source
		FROM [synapse_ce].[contact] C
			 LEFT JOIN [synapse_ce].[apuk_ricsrecord] RR 
				ON C.contactid = RR.apuk_ContactID
			 LEFT JOIN [synapse_ce].[apuk_memberchartereddesignation] MCD 
				ON RR.apuk_ricsrecordid = MCD.apuk_ricsrecordid
			 LEFT JOIN [synapse_ce].[apuk_chartereddesignation] CD 
				ON MCD.apuk_chartereddesignationid = CD.apuk_chartereddesignationid
	
		WHERE MCD.apuk_enddate IS NULL
			  AND MCD.statecode = 0
			  AND CD.id IS NOT NULL
		GROUP BY C.contactid
	
	UNION 

	SELECT 
		CRR.apuk_contact AS ContactID, 
		MAX(CR.modifiedon) AS modifiedon,
		'credential' as source
	FROM [synapse_ce].[apuk_credential] CR
		LEFT JOIN  [synapse_ce].[apuk_credentialrecord] CRR 
			ON CR.ID= CRR.apuk_credential
	WHERE --apuk_credential NOT IN (SELECT ID FROM [synapse_ce].[apuk_credential] WHERE apuk_name LIKE '%Expert Witness%' AND statecode = 0 )
		--AND 
		(CRR.apuk_endDate IS NULL OR CRR.apuk_enddate >= GETDATE())
		AND CRR.statecode = 0
		AND CRR.apuk_contact IS NOT NULL
	GROUP BY 
		CRR.apuk_contact

		UNION 

		SELECT  
			D.apuk_contactid,
			MAX(D.modifiedon) AS modifiedon,
			'disciplinary' as source
		FROM [synapse_ce].[apuk_disciplinary] D 
		WHERE D.apuk_enddate IS NULL  --Only Active Disciplinaries
			AND apuk_weblink IS NOT NULL
			AND apuk_startDate IS NOT NULL
		GROUP BY 
			D.apuk_contactid

		UNION 

		SELECT ER.apuk_contactid, MAX(ER.modifiedon) AS modifiedon, 'employment relationship' as source
		FROM [synapse_ce].[apuk_employmentrelationship] ER
		WHERE ER.apuk_enddate IS NULL  --Only Active Employment Relationships
			--AND apuk_startDate IS NOT NULL
			AND ER.apuk_primaryemployment = 1
			AND ER.statecode = 0		
		GROUP  BY
			ER.apuk_contactid

		UNION 

	SELECT 
		CRR.apuk_contact AS ContactID, 
		MAX(IIF(CR.modifiedon > ISNULL(CRR.modifiedon, '1900-01-01'), CR.modifiedon, ISNULL(CRR.modifiedon, '1900-01-01'))) AS modifiedon,
		'expert witness credential' as source
	FROM [synapse_ce].[apuk_credential] CR
		LEFT JOIN  [synapse_ce].[apuk_credentialrecord] CRR 
			ON CR.ID= CRR.apuk_credential
	WHERE apuk_credential  IN (SELECT ID FROM [synapse_ce].[apuk_credential] WHERE apuk_name LIKE '%Expert Witness%' AND statecode = 0 )
		AND CRR.apuk_endDate IS NULL
		AND CRR.statecode = 0
		AND CRR.apuk_contact IS NOT NULL
	GROUP BY
		CRR.apuk_contact

		UNION 

		SELECT ER.apuk_contactid, MAX(ER.modifiedon) AS modifiedon, 'other employment' as source
		FROM [synapse_ce].[apuk_employmentrelationship] ER
		WHERE 
			ER.apuk_PrimaryEmployment <> 1
			--AND ER.apuk_startdate IS NOT NULL
			AND ER.statecode =0
			AND ER.apuk_enddate IS NULL
		GROUP BY 
			ER.apuk_contactid

		UNION 

		SELECT 
			OPBM.apuk_contactid, 
			MAX(IIF(OPBM.modifiedon > ISNULL(OPB.modifiedon, '1900-01-01'), OPBM.modifiedon, ISNULL(OPB.modifiedon, '1900-01-01'))) AS modifiedon,
			'other professional body' as source
		FROM synapse_ce.apuk_otherprofessionalbodymembership OPBM
		LEFT JOIN synapse_ce.apuk_otherprofessionalbody opb
			ON OPBM.apuk_otherprofessionalbodyid = opb.apuk_otherprofessionalbodyid
		WHERE OPBM.apuk_contactid is not null
			AND OPBM.statecode = 0
		GROUP BY 
			apuk_contactid

		UNION 

		SELECT 
			Q.apuk_ContactID AS ContactID,
			MAX(IIF(Q.modifiedon > ISNULL(AP.modifiedon, '1900-01-01'), Q.modifiedon, ISNULL(AP.modifiedon, '1900-01-01'))) AS modifiedon,
			'qualification' as source
		FROM [synapse_ce].[apuk_qualification] Q
			LEFT JOIN [synapse_ce].[apuk_accreditedprogramme] AP 
				ON Q.apuk_ricsaccreditedcourse = AP.ID
		WHERE Q.apuk_contactid IS NOT NULL
		GROUP BY
			Q.apuk_contactid

		UNION 

		SELECT 
				CS.apuk_ContactID AS ContactID, 
				MAX(s.modifiedon) AS modifiedon,
				'skill' as source
			FROM [synapse_ce].[apuk_contactskill] CS
				LEFT JOIN [synapse_ce].[apuk_skill] S 
					ON S.ID = CS.apuk_skillid
		GROUP BY 		
			CS.apuk_ContactID
	) tab
	GROUP BY 
		tab.ContactId
