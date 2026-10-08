CREATE   VIEW [synapse_ce].[vwCondition] 
AS
	/*
		SELECT * FROM [dbo].[vwCondition] 
	*/

	SELECT 
		cond.[apuk_conditionid]
		,cond.[apuk_name]

		,cond.[createdon]
		,cond.[createdby]
		,usrcreatedby.[fullname] AS [CreatedByName]
		,cond.[createdonbehalfby]
		,usrCrBehalf.[fullname] AS [createdonbehalfbyname]

		,cond.[modifiedon]
		,cond.[modifiedby]
		,usrmodifiedby.[fullname] AS [ModifiedByName]
		,cond.[modifiedonbehalfby]
		,usrModBehalf.[fullname] AS [modifiedonbehalfbyname]

		,cond.[ownerid]
		,ownid.[fullname] AS [OwnerIdName]
		,cond.[owninguser]
		,owninguser.[fullname] AS [OwningUserName]
		,cond.[owningbusinessunit]
		,bunit.[name] AS [owningbusinessunitName]
		,cond.[owningteam]

		,cond.[apuk_failuretocomplyaction]
		,cond.[apuk_conditiontype]
		,condType.LocalizedLabel AS apuk_conditiontype_description
		,cond.[apuk_regardingtype]
		,regtype.LocalizedLabel AS apuk_regardingtype_description
		,cond.[apuk_termtype]
		,termType.LocalizedLabel AS apuk_termtype_description
		,cond.[apuk_termstatus]
		,termSts.LocalizedLabel AS apuk_termstatus_description
		
		,cond.[apuk_regulatoryauditcase]
		,cond.[apuk_regulatedfirm]
		,cond.[apuk_regulationcaseid]
		,cond.[apuk_compliancecaseworkerid]
		,compCaseWrkr.[fullname] AS apuk_compliancecaseworkeridName
		,cond.[apuk_memberid]
		,cond.[apuk_compliancecase]
		,cond.[apuk_regulatorycontact]
		,cond.[apuk_tribunalid]
		,cond.[apuk_regulatedschemeid]

		,cond.[owneridtype]
		,cond.[apuk_compliancerequiredby]
		,cond.[apuk_requiredcompliancedate]
		,cond.[apuk_regulatoryauditcasename]
		,cond.[apuk_conditionexpirydate]
		,cond.[apuk_termdescription]
		,cond.[apuk_memberidname]
		,cond.[importsequencenumber]
		,cond.[apuk_actualcompliancedate]
		,cond.[apuk_regulationcaseidname]
		,cond.[overriddencreatedon]
		,cond.[apuk_datetermadded]
		,cond.[apuk_regulatedfirmname]
		,cond.[apuk_regulatedschemeidname]
		,cond.[apuk_conditiondetails]
		,cond.[utcconversiontimezonecode]
		,cond.[apuk_tribunalidname]
		,cond.[apuk_compliancecasename]
		,cond.[apuk_regulatorycontactname]
		,cond.[statecode]
		,stStateCode.[LocalizedLabel] AS [StateCode_Description]

		,cond.[statuscode]
		,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]

	FROM [synapse_ce].[apuk_condition] cond
		LEFT JOIN synapse_ce.systemuser usrcreatedby
			ON cond.[createdby] = usrcreatedby.[systemuserid]
		LEFT JOIN synapse_ce.systemuser usrmodifiedby
			ON cond.[modifiedby] = usrmodifiedby.[systemuserid]
		LEFT JOIN synapse_ce.systemuser ownid
			ON cond.[ownerid] = ownid.[systemuserid]
		LEFT JOIN synapse_ce.systemuser owninguser
			ON cond.[owninguser] = owninguser.[systemuserid]
		LEFT JOIN synapse_ce.businessunit bunit
			ON cond.[owningbusinessunit] = bunit.[businessunitid]
		LEFT JOIN synapse_ce.systemuser usrCrBehalf
			ON cond.[createdonbehalfby] = usrCrBehalf.[systemuserid]
		LEFT JOIN synapse_ce.systemuser usrModBehalf
			ON cond.[modifiedonbehalfby] = usrModBehalf.[systemuserid]
		LEFT JOIN synapse_ce.systemuser compCaseWrkr
			ON cond.[apuk_compliancecaseworkerid] = compCaseWrkr.[systemuserid]
		LEFT JOIN synapse_ce.GlobalOptionSetMetadata condType
			ON cond.[apuk_conditiontype] = condType.[Option]
			AND condType.[OptionSetName] = 'apuk_conditiontype'
			AND condType.[EntityName] = 'apuk_condition'
		LEFT JOIN synapse_ce.GlobalOptionSetMetadata regtype
			ON cond.[apuk_regardingtype] = regtype.[Option]
			AND regtype.[OptionSetName] = 'apuk_regardingtype'
			AND regtype.[EntityName] = 'apuk_condition'
		LEFT JOIN synapse_ce.GlobalOptionSetMetadata termType
			ON cond.[apuk_termtype] = termType.[Option]
			AND regtype.[OptionSetName] = 'apuk_termtype'
			AND regtype.[EntityName] = 'apuk_condition'
		LEFT JOIN synapse_ce.GlobalOptionSetMetadata termSts
			ON cond.[apuk_termstatus] = termSts.[Option]
			AND termSts.[OptionSetName] = 'apuk_termstatus'
			AND termSts.[EntityName] = 'apuk_condition'
		LEFT JOIN synapse_ce.StateMetadata stStateCode
			ON cond.[statecode] = stStateCode.[State]
				AND stStateCode.[EntityName] = 'apuk_condition'
		LEFT JOIN synapse_ce.StatusMetadata stStatusCode
			ON cond.[statuscode] = stStatusCode.[Status]
				AND stStatusCode.[EntityName] = 'apuk_condition'
