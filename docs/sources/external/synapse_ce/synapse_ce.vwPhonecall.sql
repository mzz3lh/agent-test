CREATE   VIEW [synapse_ce].[vwPhonecall]
AS
SELECT 
	pc.[ActivityId],
	pc.[ActivityTypeCode],
	pc.[ActualStart],
	pc.[ActualEnd],
	pc.[Category],

	pc.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	pc.[createdon] AS [Created_On],
	pc.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	pc.[modifiedon] AS [Modified_On],
	pc.[Description],
	pc.[DirectionCode],
	dircode.[LocalizedLabel] AS [DirectionCode_Description],
	pc.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	pc.[RegardingObjectId],
--	pc.[RegardingObjectIdName],
	pc.[StateCode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	pc.[StatusCode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	pc.[Subject],

	pc.[Subcategory],
	pc.apuk_subjectareaid,
	subjarea.[title] AS apuk_subjectareaid_description,
	pc.[prioritycode],
	prioritycode.[LocalizedLabel] AS prioritycode_description,
	pc.[onholdtime],
	pc.[apitil_precedingactivitycompleted],
	pc.[apitil_precedingactivitytask],
	pc.[apitil_precedingactivityphonecall],
	pc.[apitil_nextactivitytask],
	pc.[apitil_nextactivityphonecall],
	pc.[apitil_movetostage],
	pc.[actualdurationminutes],
	pc.[msdyn_ci_keywords]

FROM synapse_ce.phonecall pc
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON pc.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'phonecall'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON pc.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'phonecall'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON pc.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON pc.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON pc.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.OptionSetMetadata dircode
		ON pc.[directioncode] = dircode.[Option]
			AND dircode.[EntityName] = 'phonecall'
			AND dircode.[OptionSetName] = 'directioncode'
	LEFT JOIN synapse_ce.OptionSetMetadata prioritycode
		ON pc.[prioritycode] = prioritycode.[Option]
			AND prioritycode.[EntityName] = 'phonecall'
			AND prioritycode.[OptionSetName] = 'prioritycode'
	LEFT JOIN synapse_ce.subject subjarea
		ON pc.[apuk_subjectareaid] = subjarea.[subjectid]
