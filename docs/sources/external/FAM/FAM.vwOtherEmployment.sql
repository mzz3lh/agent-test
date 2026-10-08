CREATE    VIEW [FAM].[vwOtherEmployment]
AS

	SELECT --DISTINCT 
		ER.id AS OtherEmpRecId,
		C.ContactID,
		A.name AS EmpFirmNameOE,
		ER.apuk_jobtitle AS EmpJobTitleOE,
		--A.emailaddress1 AS EmpBusinessEmailOE,  //Updated on 2023-01-25 with ER.apuk_businessemailaddress as below
		ER.apuk_businessemailaddress AS EmpBusinessEmailOE,
		--A.telephone1 AS EmpBusinessPhoneOE,
		ER.apuk_businessphonenumber AS EmpBusinessPhoneOE,
		A.address1_line1 AS EmpAddressLine1OE,
		A.address1_line2 AS EmpAddressLine2OE,
		A.address1_line3 AS EmpAddressLine3OE,
		A.address1_city AS EmpAddressCityOE,
		A.address1_postalCode AS EmpPostCodeOE,
		A.address1_stateorprovince AS EmpCountyOE,  
		A.address1_country AS EmpCountryRegionOE, --maps to Address1: country/region
		AC.apuk_name AS EmpCountry,
		ER.apuk_PrimaryEmployment,
		ER.apuk_startdate

	FROM [synapse_ce].[apuk_employmentrelationship] ER
		LEFT JOIN [synapse_ce].[contact] C 
			ON ER.apuk_contactID = C.contactid
		LEFT JOIN [synapse_ce].[account] A 
			ON A.accountid = ER.apuk_accountid
		LEFT JOIN [synapse_ce].[apuk_country] AC 
			ON A.apuk_countryid = AC.id
		INNER JOIN FAM.vwMember M 
			ON M.ContactID = C.contactid
	WHERE 
		ER.apuk_PrimaryEmployment <> 1
		--AND ER.apuk_startdate IS NOT NULL
		AND ER.statecode =0
		AND ER.apuk_enddate IS NULL

	GROUP BY
		ER.id,
		C.ContactID,
		A.name,
		ER.apuk_jobtitle,
		--A.emailaddress1 AS EmpBusinessEmailOE,  //Updated on 2023-01-25 with ER.apuk_businessemailaddress as below
		ER.apuk_businessemailaddress,
		--A.telephone1 AS EmpBusinessPhoneOE,
		ER.apuk_businessphonenumber,
		A.address1_line1,
		A.address1_line2,
		A.address1_line3,
		A.address1_city,
		A.address1_postalCode,
		A.address1_stateorprovince,  
		A.address1_country, --maps to Address1: country/region
		AC.apuk_name,
		ER.apuk_PrimaryEmployment,
		ER.apuk_startdate
