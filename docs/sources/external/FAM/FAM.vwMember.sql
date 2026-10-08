CREATE      VIEW [FAM].[vwMember]
AS

	SELECT  
		C.Contactid AS ContactID, 
		C.apuk_contactnumber AS ContactNumber, 
		C.firstname AS FirstName, 
		C.lastname AS LastName,
		CASE ISNULL( RR.apuk_lapsecode,0)
           WHEN 0 THEN 0
           ELSE  1
		END AS HasMembershipLapsed, 
		CAST(RR.apuk_datequalified AS DATE) AS MemberSince, 
		RR.apuk_designation AS RRMemberGrade, --changed from apuk_membergrade --see DevOps 22114
		CASE 
			WHEN RR.apuk_designation = 200000000 THEN 'AssocRICS'
			WHEN RR.apuk_designation = 200000001 THEN 'MRICS'  
			WHEN RR.apuk_designation = 200000002  THEN 'FRICS'
			WHEN RR.apuk_designation = 200000003 THEN 'HonRICS'
			WHEN RR.apuk_designation = 200000004  THEN 'N/A'
		END AS CMemberGrade,
		RR.apuk_Membergrade AS RicsContactType, --added as Netcel also needs this (previously known as Professional Grade) see DevOps 22137
		CASE ISNULL(LEN(D.apuk_contactid),0)
			WHEN 0 THEN 0
			ELSE 1
		END AS HasActiveDisciplinary,
		D.apuk_weblink AS DisciplinaryURL,  --this is the latest disciplinary
		CASE ISNULL(LEN(EWC.contactID),0)
			WHEN 0 THEN 0
			ELSE 1
		END AS IsExpertWitness,
		C.apuk_twitterurl AS TwitterURL,
		C.apuk_linkedinurl AS LinkedInURL,
		RR.apuk_aboutyou AS About,
		--RR.apuk_primaryprofessionalgroupidname AS PrimaryProfessionalGroup,  --Check

--		CASE WHEN mpg.apuk_primary = 1 THEN mpg.apuk_name END AS PrimaryProfessionalGroup
		IIF(mpg.apuk_primary = 1,mpg.apuk_name, NULL) AS PrimaryProfessionalGroup,
--		CASE WHEN mpg.apuk_primary = 0 THEN mpg.apuk_name END AS OtherProfessionalGroup,
		IIF(mpg.apuk_primary = 0,mpg.apuk_name,NULL) AS OtherProfessionalGroup,
		mpg.apuk_primary,
		IIF(C.apuk_dateagreedwebtcs IS NULL, 0, 1) AS AcceptedRicsOrgTsAndCs,

--Primary Employment fields
		A.name AS EmpFirmName,
/*      Modified on 2022-11-10 as per the issue raised  
		ER.EmpJobTitle AS EmpJobTitle,
		A.emailaddress1 AS EmpBusinessEmail,
		A.telephone1 AS EmpBusinessPhone,
	*/
		C.jobtitle AS EmpJobTitle,
		C.emailaddress3 AS EmpBusinessEmail,
		C.telephone3 AS EmpBusinessPhone,

		A.address1_line1 AS EmpAddressLine1,
		A.address1_line2 AS EmpAddressLine2,
		A.address1_line3 AS EmpAddressLine3,
		A.address1_city AS EmpAddressCity,
		A.address1_postalCode AS EmpPostCode,
		A.address1_stateorprovince AS EmpCounty,  
		A.address1_country AS EmpCountryRegion, --maps to Address1: country/region
		IIF(A.apuk_countryid IS NULL, CC.apuk_name,AC.apuk_name) AS EmpCountry,
		IIF(A.apuk_countryid IS NULL, CC.apuk_code, AC.apuk_code) AS EmpCountryCode,
		C.entityimage_url,
		C.address1_country,
		C.address1_city,
		C.address2_country,
		C.address2_city,
		C.address3_country,
		C.address3_city,
		C.apuk_twitterurl,
		C.apuk_linkedinurl,

		/*
		IIF(		
			IIF(
				IIF(
					IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) > ISNULL(D.modifiedon, '1900-01-01'),
					IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) , ISNULL(D.modifiedon, '1900-01-01')			
					) > ISNULL(ER.modifiedon, '1900-01-01'), 			IIF(
					IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) > ISNULL(D.modifiedon, '1900-01-01'),
					IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) , ISNULL(D.modifiedon, '1900-01-01')			
					), ISNULL(ER.modifiedon, '1900-01-01')
			) > ISNULL(cntimages.modifiedon, '1900-01-01'),
					IIF(
			IIF(
				IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) > ISNULL(D.modifiedon, '1900-01-01'),
				IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) , ISNULL(D.modifiedon, '1900-01-01')			
				) > ISNULL(ER.modifiedon, '1900-01-01'), 			IIF(
				IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) > ISNULL(D.modifiedon, '1900-01-01'),
				IIF(C.modifiedon > ISNULL(RR.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(RR.modifiedon, '1900-01-01')) , ISNULL(D.modifiedon, '1900-01-01')			
				), ISNULL(ER.modifiedon, '1900-01-01')
		), ISNULL(cntimages.modifiedon, '1900-01-01')) AS Modifiedon,
		*/
		IIF(C.modifiedon > ISNULL(ml.modifiedon, '1900-01-01'), C.modifiedon, ISNULL(ml.modifiedon, '1900-01-01')) AS modifiedon,
		C.statecode,
		C.statuscode,
		pg.[apuk_name] AS [apuk_professionalGroupIdName],
		cntimages.entityimage,
		C.websiteurl,
		c.[apuk_directdebit] AS [IsTestMember]
		/*
		,
		C.emailaddress1,
		C.emailaddress2,
		C.emailaddress3,
		C.address1_telephone2,
		C.address1_telephone3,
		C.address2_telephone1,
		C.address2_telephone3,
		C.address3_telephone1,
		C.address3_telephone2,
		C.address3_telephone3,
		C.mobilephone
		*/

FROM [synapse_ce].[contact] C
		LEFT JOIN [synapse_ce].[apuk_ricsrecord] RR 
			ON C.contactid = RR.apuk_ContactID
		LEFT JOIN FAM.vwDisciplinaries D 
			ON RR.apuk_contactID = D.apuk_contactID  --changed from view to table to optimise. Ensure table is disciplinary populated first
	
	--LEFT JOIN dbo.ExpertWitnessCredential EWC ON EWC.contactID = RR.apuk_ContactID --changed from view to table to optimise. Ensure table is expertwitnesscredential populated first
		OUTER APPLY 
		(
			SELECT TOP 1 ContactID FROM [FAM].[vwExpertWitnessCredential]
			WHERE contactID = RR.apuk_ContactID
		) EWC
	
		LEFT JOIN [FAM].[vwEmploymentRelationship] ER 
			ON ER.apuk_contactID = C.contactid
			AND ER.apuk_PrimaryEmployment = 1
			--AND ER.apuk_startdate IS NOT NULL
			AND ER.statecode =0
			AND ER.apuk_contactID IS NOT NULL
		LEFT JOIN [synapse_ce].[account] A 
			ON A.accountid = ER.apuk_accountid
		LEFT JOIN [synapse_ce].[apuk_country] AC 
			ON A.apuk_countryid = AC.id
		LEFT JOIN [synapse_ce].[apuk_country] CC 
			ON C.apuk_personaladdresscountryid = CC.id
		LEFT JOIN synapse_ce.apuk_membersprofessionalgroup mpg
			ON RR.apuk_primaryprofessionalgroupid = mpg.apuk_membersprofessionalgroupid
		LEFT JOIN synapse_ce.apuk_professionalgroup pg
			ON mpg.apuk_professionalgroupid = pg.apuk_professionalgroupid
		LEFT JOIN FAM.tblContactImages cntimages
			ON C.contactid = cntimages.contactid
	
	LEFT JOIN FAM.vwMemberLastModified ml
		ON C.contactid = ml.contactid 
	WHERE 
	/*    Statecode fields are excluded in the constraints as per meeting on 2022-11-01 1330

		--RR.apuk_lapsecode IS NULL  */
		--AND 
		C.statecode = 0
		AND RR.statecode = 0
		AND RR.apuk_designation IN (200000000, 200000001, 200000002, 200000003 )  --changed from apuk_membergrade --see DevOps 22114. Removed 000000000 --see devops 22138
		--AND C.apuk_membergrade IN ('Qualified Professional - ASSOCRICS' ,'Qualified Professional - MRICS','Qualified Professional - 2 Years - MRICS',
		--'Qualified Professional - FRICS','Qualified Professional - HonRICS')  --changed to RR.apuk_membergrade as per devops ticket 21401
		--AND C.ContactID NOT IN ('00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000','00000000-0000-0000-0000-000000000000')
		--Removed exclusions (see email 21/09/21) - details must be on directory as per bye-laws for public inspection
	
	
	/*  Below script is used to filter test records but the request came to include them and able to filter in FAM search
		AND NOT EXISTS
		(
			SELECT ContactID
			FROM CE.tblContact_Test_Records tst
			WHERE C.contactid = tst.contactid
		)
	*/
