CREATE    VIEW [FAM].[vwFindAMember]
AS
SELECT 
	m.ContactID,
	m.FirstName, 
	m.LastName, 
	m.ContactNumber, 
	m.CMemberGrade, 
	m.EmpFirmName,
	m.About,
	m.EmpJobTitle,
	m.EmpBusinessEmail,
	m.EmpBusinessPhone, 
	m.entityimage_url,
	m.address1_country,
	m.address1_city,
	m.PrimaryProfessionalGroup, 
	m.OtherProfessionalGroup,

	c.CharteredDesignation, 
	q.CompletionDate, 
	--s.Skill, 
	--o.Affiliation,
	m.EmpAddressCity,
	m.EmpCountry,
	m.EmpCountryCode,
	m.EmpAddressLine1,
	m.EmpAddressLine2,
	m.EmpAddressLine3,
	m.TwitterURL,
	m.LinkedInURL,
	/*
	IIF(IIF(m.modifiedon > ISNULL(c.modifiedon, '1900-01-01'), m.modifiedon, ISNULL(c.modifiedon, '1900-01-01')) > ISNULL(q.modifiedon, '1900-01-01'),
	IIF(m.modifiedon > ISNULL(c.modifiedon, '1900-01-01'), m.modifiedon, ISNULL(c.modifiedon, '1900-01-01')), ISNULL(q.modifiedon, '1900-01-01')
	)	AS modifiedon,
	*/
	m.Modifiedon,
	q.CourseName,
	q.InstitutionName,
	m.statecode,
	m.statuscode,
	m.HasMembershipLapsed,
	m.[apuk_professionalGroupIdName],
	m.entityimage,
	m.websiteurl,
	m.[IsTestMember]
	/*
	,
	m.emailaddress1,
	m.emailaddress2,
	m.emailaddress3,
	m.address1_telephone2,
	m.address1_telephone3,
	m.address2_telephone1,
	m.address2_telephone3,
	m.address3_telephone1,
	m.address3_telephone2,
	m.address3_telephone3,
	m.mobilephone
	*/
FROM FAM.vwMember m
	FULL OUTER JOIN FAM.vwCharteredDesignations AS c 
		ON m.ContactID = c.ContactID 
	FULL OUTER JOIN FAM.vwQualifications AS q 
		ON m.ContactID = q.ContactID  
	--FULL OUTER JOIN FAM.vwSkill AS s 
	--	ON m.ContactID = s.ContactID  
	--FULL OUTER JOIN FAM.vwOtherProfessionalBody AS o 
	--	ON m.ContactID = o.ContactID
