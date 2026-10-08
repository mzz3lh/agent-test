CREATE   VIEW [synapse_ce].[vwCasefitandproper]
AS
SELECT 
	  fit.apuk_casefitandproperid
	, fit.apuk_name
	, fit.createdon
	, fit.createdby
	, usrcreatedby.[fullname] AS [CreatedByName]
	, fit.modifiedon
	, fit.modifiedby
	, usrmodifiedby.[fullname] AS [ModifiedByName]
	, fit.ownerid
	, ownid.[fullname] AS [OwnerIdName]
	, fit.owningbusinessunit
	, bunit.[name] AS [owningbusinessunitName]
	, fit.apuk_tribunal
	, fit.apuk_subject
	, subj.[title] AS [apuk_subjectName]
	, fit.apuk_showonline
	, fit.overriddencreatedon
	, fit.apuk_readmissionapplication
	, appl.[apuk_name] AS [apuk_readmissionapplicationName]
	, fit.apuk_outcome
	, apukoutcome.[LocalizedLabel] AS [apuk_outcome_Description]
	, fit.apuk_description
	, fit.apuk_memberid    --Contact
	, fit.apuk_casegroupreference
	, fit.statecode
	, stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, fit.statuscode
	, stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_casefitandproper fit
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON fit.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON fit.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON fit.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON fit.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_casefitandproper'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON fit.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_casefitandproper'
	LEFT JOIN synapse_ce.businessunit bunit
		ON fit.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.subject subj
		ON fit.[apuk_subject] = subj.[subjectid]
	LEFT JOIN synapse_ce.apuk_application appl
		ON fit.[apuk_readmissionapplication] = appl.[apuk_applicationid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata apukoutcome
		ON fit.[apuk_outcome] = apukoutcome.[Option]
		AND apukoutcome.[OptionSetName] = 'apuk_outcome'
		AND apukoutcome.[EntityName] = 'apuk_casefitandproper'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = fit.apuk_memberid
		)
