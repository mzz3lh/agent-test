CREATE   VIEW [synapse_ce].[vwRegulatoryReturn]
AS
SELECT 
	  reg.apuk_regulatoryreturnid
	, reg.apuk_name
	, reg.createdon
	, reg.createdby
	,usrcreatedby.[fullname] AS CreatedByName
	, reg.modifiedon
	, reg.modifiedby
	,usrmodifiedby.[fullname] AS ModifiedByName
  	, reg.ownerid
	,ownid.[fullname] AS [OwnerIdName]
	, reg.apuk_withdrawalreason
	, wthreason.[LocalizedLabel] AS [apuk_withdrawalreason_Description]
	, reg.apuk_submitteddate
	, reg.apuk_submittedbyid
	, reg.apuk_score
	, reg.apuk_returntype
	, rettype.[apuk_name] AS apuk_returntypeName
	, reg.apuk_returnstatus
	, retstatus.[LocalizedLabel] AS [apuk_returnstatus_Description]
	, reg.apuk_returnduedate
	, reg.apuk_returncheckstatus
	, retcheckstatus.[LocalizedLabel] AS [apuk_returncheckstatus_Description]
	, reg.apuk_responsibleprincipal   --Contact
	, reg.apuk_regulatoryreturnreference
	, reg.apuk_regulatorycontactofficerid    --Contact
	, reg.apuk_regulationtype
	, regtype.[LocalizedLabel] AS [apuk_regulationtype_Description]
	, reg.apuk_regulatedschemeid
	, reg.apuk_regulatedmemberid    --Contact
	, reg.apuk_regulatedfirmid  --Account
	, reg.overriddencreatedon
	, reg.owningbusinessunit
	,bunit.[name] AS [OwningBusinessUnitName]
	, reg.apuk_localgroupid    --Localgroup
	, reg.apuk_extensionreason
	, extreason.[LocalizedLabel] AS [apuk_extensionreason_Description]
	, reg.apuk_extendedsubmissiondate
	, reg.apuk_donotchaseseton
	, reg.apuk_donotchasesetby
	, reg.apuk_donotchase
	, reg.apuk_caseregulatedschemeregistrationid
	, regschstat.apuk_name AS apuk_caseregulatedschemeregistrationidName
	, reg.apuk_casecomplianceid
	, casecomp.[apuk_name] AS [apuk_casecomplianceidName]
	, reg.apuk_caseannualreturnid
	, annret.[apuk_name] AS [apuk_caseannualreturnidName]
	, reg.statecode
	,stStateCode.[LocalizedLabel] AS [StateCode_Description]
	, reg.statuscode
	,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_regulatoryreturn reg
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON reg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON reg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON reg.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.businessunit bunit
		ON reg.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON reg.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON reg.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.apuk_regulatoryreturntype rettype
		ON reg.[apuk_returntype] = rettype.[apuk_regulatoryreturntypeid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
		ON reg.[apuk_regulationtype] = regtype.[Option]
		AND regtype.[OptionSetName] = 'apuk_regulationtype'
		AND regtype.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata wthreason
		ON reg.[apuk_withdrawalreason] = wthreason.[Option]
		AND wthreason.[OptionSetName] = 'apuk_withdrawalreason'
		AND wthreason.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata retstatus
		ON reg.[apuk_returnstatus] = retstatus.[Option]
		AND retstatus.[OptionSetName] = 'apuk_returnstatus'
		AND retstatus.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata retcheckstatus
		ON reg.[apuk_returncheckstatus] = retcheckstatus.[Option]
		AND retcheckstatus.[OptionSetName] = 'apuk_returncheckstatus'
		AND retcheckstatus.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata extreason
		ON reg.[apuk_extensionreason] = extreason.[Option]
		AND extreason.[OptionSetName] = 'apuk_extensionreason'
		AND extreason.[EntityName] = 'apuk_regulatoryreturn'
	LEFT JOIN synapse_ce.apuk_caseregulschemeregistration regschstat
		ON reg.[apuk_caseregulatedschemeregistrationid] = regschstat.[apuk_caseregulschemeregistrationid]
	LEFT JOIN synapse_ce.apuk_casecompliance casecomp
		ON reg.[apuk_casecomplianceid] = casecomp.[apuk_casecomplianceid]
	LEFT JOIN synapse_ce.apuk_caseannualreturn annret
		ON reg.[apuk_caseannualreturnid] = annret.[apuk_caseannualreturnid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = reg.apuk_responsibleprincipal
		OR TST.contactid = reg.apuk_regulatorycontactofficerid
		OR TST.contactid = reg.apuk_regulatedmemberid
		)
