CREATE   VIEW [synapse_ce].[vwRics_assessoravailability]
AS
SELECT
	ap.[apuk_availabilityid] AS [Rics_assessoravailabilityId],
	ap.[apuk_name] AS [Rics_name],
	ap.[apuk_contactid] AS [rics_assessorid],
	ap.[apuk_assessmentevent] AS [rics_sessionid],
	assevent.[apuk_name] AS [rics_sessionidname], --Need to pull from child entity
	ap.[OrganizationId],
	--ap.[Rics_DayOne],
	--ap.[Rics_DayTwo],
	--ap.[Rics_DayThree],
	--ap.[Rics_DayFour],
	--ap.[Rics_DayFive],
	--ap.[Rics_DaySix],
	ap.[apuk_startdate] AS [Rics_DateOne],
	--ap.[Rics_DateTwo],
	--ap.[Rics_DateThree],
	--ap.[Rics_DateFour],
	--ap.[Rics_DateFive],
	--ap.[Rics_DateSix],
	ap.[createdon] AS [Created_On],
	ap.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ap.[modifiedon] AS [Modified_On],
	ap.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	ap.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ap.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	ap.[apuk_enddate],
	ap.[apuk_availabilityhours],
	availhrs.[LocalizedLabel] AS [apuk_availabilityhours_Description],
	ap.[apuk_maximumnumberofdays],
	ap.apuk_availabilitytype
FROM synapse_ce.apuk_availability ap
	LEFT JOIN synapse_ce.apuk_assessmentevent assevent
		ON ap.[apuk_assessmentevent] = assevent.[apuk_assessmenteventid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ap.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_availability'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ap.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_availability'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ap.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ap.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata availhrs
		ON ap.[apuk_availabilityhours] = availhrs.[Option]
			AND availhrs.[OptionSetName] = 'apuk_availabilityhours'
			AND availhrs.[EntityName] = 'apuk_availability'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = ap.[apuk_contactid] 
		)
--WHERE ap.[apuk_availabilityid] = '00000000-0000-0000-0000-000000000000'
