CREATE   VIEW [synapse_ce].[vwRics_Panel]
AS
SELECT 
	pnl.[apuk_panelid] AS [Rics_panelId],
	pnl.[apuk_name] AS [Rics_name],
	pnl.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	pnl.[createdon] AS [Created_On],
	pnl.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	pnl.[modifiedon] AS [Modified_On],
	pnl.[apuk_assessmentevent] AS [rics_centreid],
	evt.[apuk_name] AS [rics_centreidName],
	pnl.[apuk_assessmentvenue] AS [rics_venueid],
	venue.[apuk_name] AS [rics_venueidName],
	pnl.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	pnl.[apuk_date] AS [Rics_Date],
	pnl.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	pnl.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	pnl.[apuk_tribunalvenue],
	pnl.[apuk_tribunalmember],
	pnl.[apuk_tribunallegalassessor],
	pnl.[apuk_tribunallaymember],
	pnl.[apuk_tribunalchair],
	pnl.[overriddencreatedon],
	pnl.[apuk_paneltype],
	pnltype.[LocalizedLabel] AS [apuk_paneltype_description],
	pnl.[owningbusinessunit],
	bunit.[name] AS [owningbusinessunitName]
FROM synapse_ce.apuk_panel pnl
	LEFT JOIN synapse_ce.apuk_assessmentevent evt
		ON pnl.[apuk_assessmentevent] = evt.[apuk_assessmenteventid]
	LEFT JOIN synapse_ce.apuk_assessmentvenue venue
		ON pnl.[apuk_assessmentvenue] = venue.[apuk_assessmentvenueid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON pnl.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON pnl.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON pnl.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON pnl.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_panel'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON pnl.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_panel'
	LEFT JOIN synapse_ce.OptionSetMetadata pnltype
		ON pnl.[apuk_paneltype] = pnltype.[Option]
			AND pnltype.[OptionSetName] = 'apuk_paneltype'
	LEFT JOIN synapse_ce.businessunit bunit
		ON pnl.[owningbusinessunit] = bunit.[businessunitid]
--WHERE pnl.apuk_panelid = '00000000-0000-0000-0000-000000000000'
