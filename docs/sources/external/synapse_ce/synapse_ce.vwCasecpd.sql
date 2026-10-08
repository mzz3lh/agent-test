CREATE   VIEW [synapse_ce].[vwCasecpd]
AS
SELECT 
	  cpd.apuk_casecpdid
	, cpd.apuk_name
	, cpd.createdon
	, cpd.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, cpd.modifiedon
	, cpd.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, cpd.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, cpd.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, cpd.apuk_showonline
	, cpd.apuk_ruleofconduct2
	, cpd.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, cpd.apuk_ricsrecordid
	, cpd.overriddencreatedon
	, cpd.apuk_offercpdexemption
	, cpd.apuk_escalationlevel
	, cpd.apuk_concessiongrantedid
	, cpd.apuk_casestatus
	, apukcasestatus.[LocalizedLabel] AS [apuk_casestatus_Description]
	, cpd.apuk_casereference
	, cpd.apuk_casegroupreference
	, cpd.apuk_casedescription
	, cpd.apuk_caseclosuredate
	, cpd.apuk_areaofpractice
	, areaofpractice.[title] AS [apuk_areaofpracticeName]
	, cpd.apuk_areaofbreach3
	, areaofbreach3.[title] AS [apuk_areaofbreach3Name]
	, cpd.apuk_areaofbreach2
	, areaofbreach2.[title] AS [apuk_areaofbreach2Name]
	, cpd.apuk_areaofbreach
	, areaofbreach.[title] AS [apuk_areaofbreachName]
	, cpd.apuk_applicantid
	, cpd.apuk_ageofcase
	, cpd.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, cpd.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_casecpd cpd
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON cpd.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON cpd.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON cpd.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON cpd.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON cpd.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_caseinvestigation'
	LEFT JOIN synapse_ce.businessunit bunit
		ON cpd.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subjruleofconduct
		ON cpd.[apuk_ruleofconduct2] = subjruleofconduct.[subjectid]
	LEFT JOIN synapse_ce.subject subj
		ON cpd.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach
		ON cpd.[apuk_areaofbreach] = areaofbreach.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach2
		ON cpd.[apuk_areaofbreach2] = areaofbreach2.[subjectid]
	LEFT JOIN synapse_ce.subject areaofbreach3
		ON cpd.[apuk_areaofbreach3] = areaofbreach3.[subjectid]
	LEFT JOIN synapse_ce.subject areaofpractice
		ON cpd.[apuk_areaofpractice] = areaofpractice.[subjectid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukcasestatus
		ON cpd.[apuk_casestatus] = apukcasestatus.[Option]
		AND apukcasestatus.[OptionSetName] = 'apuk_casestatus'
		AND apukcasestatus.[EntityName] = 'apuk_casecpd'
