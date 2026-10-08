CREATE   VIEW [synapse_ce].[vwSanction]
AS
SELECT 
	s.[apuk_sanctionid],
	s.[apuk_name],
	s.[createdon],
	s.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	s.[modifiedon],
	s.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	s.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	s.[apuk_sanctiontype],
	sanctype.[LocalizedLabel] AS [apuk_sanctiontype_description],
	s.[apuk_sanctionidnumber],
	s.[apuk_sanctiondetails],
	s.[apuk_rehearingrequired],
	s.[overriddencreatedon],
	s.[apuk_finelevel],
	s.[apuk_fineincluded],
	s.[apuk_fineamount],
	s.[apuk_fineamount_base],
	s.[apuk_chargeid],
	chg.[apuk_name] AS [apuk_chargeidName],
	s.[apuk_appealed],
	s.[apuk_appealstatus],
	appstatus.[LocalizedLabel] AS [apuk_appealstatus_description],
	s.[apuk_appealdate],
	s.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	s.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	s.[owningbusinessunit],
	bunit.[name] AS [OwningBusinessUnitName],
	s.apuk_tribunalid,
	s.apuk_appealtribunalid
FROM synapse_ce.apuk_sanction s
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON s.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON s.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON s.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON s.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON s.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.businessunit bunit
		ON s.[owningbusinessunit] = bunit.[businessunitid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata appstatus
		ON s.[apuk_appealstatus] = appstatus.[Option]
		AND appstatus.[OptionSetName] = 'apuk_appealstatus'
		AND appstatus.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata sanctype
		ON s.[apuk_sanctiontype] = sanctype.[Option]
		AND sanctype.[OptionSetName] = 'apuk_sanctiontype'
		AND sanctype.[EntityName] = 'apuk_sanction'
	LEFT JOIN synapse_ce.apuk_charge chg
		ON s.[apuk_chargeid] = chg.[apuk_chargeid]
