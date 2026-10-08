CREATE   VIEW [synapse_ce].[vwCaseregulatorychange]
AS
SELECT 
	regchg.[apuk_caseregulatorychangeid],
	regchg.[apuk_name],
	regchg.[createdon],
	regchg.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	regchg.[modifiedon],
	regchg.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	regchg.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	regchg.[apuk_regardingtype],
	regtype.[LocalizedLabel] AS [apuk_regardingtype_description],
	regchg.[apuk_status],
	apukstatus.[LocalizedLabel] AS [apuk_status_description],
	regchg.[apuk_showonline],
	regchg.[apuk_escalationlevel],
	regchg.[apuk_origin],
	apukorigin.[LocalizedLabel] AS [apuk_origin_description],
	regchg.[apuk_ruleofconduct2],

	regchg.[apuk_regulatedscheme],
	regchg.[apuk_regulatorycontactid],
	regchg.[apuk_responsibleprincipal],  --Contact
	regchg.[apuk_areaofpractice],
	regchg.[apuk_areaofbreach],

	regchg.[apuk_regulatedfirm], --account
	regchg.[owningbusinessunit],
	bunit.[name] AS [owningbusinessunitName],
	regchg.[apuk_regulatedindividual], --contact
	regchg.[apuk_areaofbreach2],

	regchg.[apuk_areaofbreach3],

	regchg.[createdonbehalfby],
	regchg.[modifiedonbehalfby],
	regchg.[owninguser],
	owninguser.[fullname] AS [owninguserName],
	regchg.[apuk_subject],
	subj.[title] AS [apuk_subject_title],
	subj.[description] AS [apuk_subject_description],
	regchg.[apuk_customerid], --contact
	regchg.[apuk_caseclosuredate],
	regchg.[apuk_casegroupreference],
	regchg.[apuk_ageofcase],
	regchg.[overriddencreatedon],
	regchg.[apuk_description],
	regchg.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	regchg.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]

FROM synapse_ce.apuk_caseregulatorychange regchg
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON regchg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON regchg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON regchg.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON regchg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_caseregulatorychange'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON regchg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_caseregulatorychange'
	LEFT JOIN synapse_ce.businessunit bunit
		ON regchg.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subj
		ON regchg.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.systemuser owninguser
		ON regchg.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON regchg.[apuk_regardingtype] = regtype.[Option]
			AND regtype.[OptionSetName] = 'apuk_regardingtype'
			AND regtype.[EntityName] = 'apuk_caseregulatorychange'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukstatus
		ON regchg.[apuk_status] = apukstatus.[Option]
			AND apukstatus.[OptionSetName] = 'apuk_status'
			AND apukstatus.[EntityName] = 'apuk_caseregulatorychange'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukorigin
		ON regchg.[apuk_origin] = apukorigin.[Option]
			AND apukorigin.[OptionSetName] = 'apuk_origin'
			AND apukorigin.[EntityName] = 'apuk_caseregulatorychange'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = regchg.[apuk_responsibleprincipal]
		OR TST.contactid = 	regchg.[apuk_regulatedindividual]
		OR TST.contactid = 	regchg.[apuk_customerid]
		)
