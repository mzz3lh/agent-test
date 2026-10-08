CREATE   VIEW [synapse_ce].[vwConcession]
AS
SELECT 
	conc.[apuk_concessionid],
	conc.[apuk_name],
	conc.[apuk_concessiontypeid],
	ct.[apuk_name] AS [apuk_concessiontypeid_Name],
	conc.[apuk_subscriptionyear],
	conc.[apuk_dualmembership],
	conc.[createdon],
	conc.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	conc.[modifiedon],
	conc.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	conc.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	conc.[apuk_ricsrecordid],
	conc.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	conc.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	conc.[apuk_startdate],
	conc.[apuk_enddate],
	rec.[apuk_contactid],
	prd.[ProductId],
	ct.[apuk_perpetualnonperpetual],
	perp.[LocalizedLabel] AS [apuk_perpetualnonperpetual_description],
	ct.[apuk_discount],
	conc.[apuk_subsonlineupdate],
	conc.[overriddencreatedon],
	conc.[owningbusinessunit],  
	bunit.[name] AS [owningbusinessunitName],
	conc.[modifiedonbehalfby],
	conc.[apuk_dualmembershipfirmid], 
	conc.[createdonbehalfby]

FROM synapse_ce.apuk_concession conc
	LEFT JOIN synapse_ce.apuk_concessiontype ct
		ON conc.apuk_concessiontypeid = ct.apuk_concessiontypeid
	LEFT JOIN synapse_ce.vwProduct prd
		ON ct.apuk_productid = prd.ProductId
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON conc.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON conc.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON conc.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.businessunit bunit
		ON conc.[owningbusinessunit] = bunit.[businessunitid]

	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON conc.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_concession'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON conc.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_concession'
	LEFT JOIN synapse_ce.apuk_ricsrecord rec
		ON conc.apuk_ricsrecordid = rec.apuk_ricsrecordid
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata perp
		ON ct.[apuk_perpetualnonperpetual] = perp.[Option]
			AND perp.[OptionSetName] = 'apuk_perpetualnonperpetual'
			AND perp.[EntityName] = 'apuk_concessiontype'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = rec.[apuk_contactid]
		)
