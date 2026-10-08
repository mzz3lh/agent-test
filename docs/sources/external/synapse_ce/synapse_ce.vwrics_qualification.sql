CREATE    VIEW [synapse_ce].[vwrics_qualification]
AS
SELECT 
	qual.[apuk_qualificationid] AS [Rics_QualificationId],
	qual.[apuk_contactid] AS [Rics_ContactId],
	qual.[createdon] AS [Created_On],
	qual.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	qual.[modifiedon] AS [Modified_On],
	qual.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	CAST('00000000-0000-0000-0000-000000000000' AS uniqueidentifier) AS [OrganizationId],
	qual.[apuk_comments] AS [Rics_Comments],
	qual.[apuk_startdate] AS [Rics_StartDate],
	qual.[apuk_enddate] AS [Rics_EndDate],
	qual.[apuk_name] AS [Rics_Name],
	qual.[apuk_result] AS [Rics_Result],
	qual.[statecode],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	qual.[statuscode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description],
	qual.[apuk_ricsaccreditedcourse] AS [Rics_CourseId],
	accprg.[apuk_name] AS [Rics_CourseIdName],
	qual.[apuk_othercourse] AS [Rics_OtherCourse],
	qual.[apuk_otherdeliverymethod] AS [Rics_OtherDeliveryMethod],
	qual.[apuk_academicinstitution] AS [Rics_OtherInstitution],
	qual.[apuk_academicqualification] AS [Rics_OtherQualification],
	qual.[apuk_ricsrecordid],
	qual.[apuk_ricsaccreditedcourse],
	accprg.[apuk_name] AS [apuk_ricsaccreditedcourseName],
	accprg.[apuk_deliverymethod],
	delmethod.[LocalizedLabel] AS [apuk_deliverymethod_description],
	accprg.[apuk_departmentid],
	dep.[apuk_name] AS [apuk_departmentidName],
	accprg.[apuk_level],
	lvl.[LocalizedLabel] AS [apuk_level_description],
	accprg.[apuk_universityid],
	university.[name] AS [apuk_universityidName],
	accprg.[apuk_status],
	apukstatus.[LocalizedLabel] AS [apuk_status_description],
	accprg.[apuk_startyear],
	accprg.[apuk_endyear],
	accprg.[apuk_startdate],
	accprg.[apuk_enddate],
	qual.[apuk_completiondate]
FROM synapse_ce.apuk_qualification qual
	LEFT JOIN synapse_ce.apuk_accreditedprogramme accprg
		ON qual.[apuk_ricsaccreditedcourse] = accprg.[apuk_accreditedprogrammeid]

	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON qual.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON qual.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON qual.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON qual.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN [synapse_ce].[businessunit] busunit
		ON qual.[owningbusinessunit] = busunit.[businessunitid]
	LEFT JOIN [synapse_ce].[StateMetadata] statecode
		ON qual.[statecode] = statecode.[State]
			AND statecode.[EntityName] = 'apuk_Qualification'
	LEFT JOIN [synapse_ce].[StatusMetadata] statuscode
		ON qual.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'apuk_Qualification'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata delmethod
		ON accprg.[apuk_deliverymethod] = delmethod.[Option]
		AND delmethod.[OptionSetName] = 'apuk_deliverymethod'
		AND delmethod.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.apuk_department dep
		ON accprg.[apuk_departmentid] = dep.[apuk_departmentid]
	LEFT JOIN synapse_ce.account university
		ON accprg.[apuk_universityid] = university.[accountid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata lvl
		ON accprg.[apuk_level] = lvl.[Option]
		AND lvl.[OptionSetName] = 'apuk_level'
		AND lvl.[EntityName] = 'apuk_accreditedprogramme'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus
		ON accprg.[apuk_status] = apukstatus.[Option]
		AND apukstatus.[OptionSetName] = 'apuk_status'
		AND apukstatus.[EntityName] = 'apuk_accreditedprogramme'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = qual.[apuk_contactid]
		)
--WHERE apuk_qualificationid = '00000000-0000-0000-0000-000000000000'
