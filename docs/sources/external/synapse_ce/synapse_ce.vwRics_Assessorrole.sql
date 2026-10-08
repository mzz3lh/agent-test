CREATE   VIEW [synapse_ce].[vwRics_Assessorrole]
AS
SELECT
	asr.[apuk_assessorroleid] AS [Rics_assessorroleId],
	asr.[modifiedonbehalfbyyominame],
	--asr.[ModifiedOnBehalfByName],
	asr.[createdonbehalfbyyominame],
	--asr.[CreatedOnBehalfByName],
	asr.[createdbyyominame],
	asr.[modifiedbyyominame],
	asr.[apuk_assessorname] AS [rics_assessoridName],
	--asr.[TransactionCurrencyIdName],
	asr.[apuk_panelname] AS [rics_panelidName],
	asr.[OwnerId],
	ownid.[fullname] AS [OwnerIdName],
	asr.[OwnerIdYomiName],
	--asr.[OwnerIdDsc],
	asr.[OwnerIdType],
	asr.[OwningUser],
	asr.[OwningTeam],
	asr.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	asr.[createdon] AS [Created_On],
	asr.[ImportSequenceNumber],
	asr.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	asr.[modifiedon] AS [Modified_On],
	asr.[OverriddenCreatedOn],
	asr.[OwningBusinessUnit],
	--asr.[Rics_Air],
	--asr.[TransactionCurrencyId],
	--asr.[ExchangeRate],
	--asr.[rics_air_Base],
	--asr.[Rics_AssessorFeeClaimFormRecd],
	--asr.[Rics_AssessorFeeType],
	--asr.[Rics_Car],
	--asr.[rics_car_Base],
	--asr.[Rics_ClaimStatus],
	asr.[apuk_date] AS [Rics_Date],
	--asr.[Rics_Details],
	--asr.[Rics_ExpenseBatchNumber],
	--asr.[Rics_ExpenseClaimFormRecd],
	--asr.[Rics_ExpenseValue],
	--asr.[rics_expensevalue_Base],
	--asr.[Rics_FeeBatchNumber],
	asr.[apuk_feevalue],
	asr.[apuk_feevalue_base],
	asr.[apuk_assessorfeeclaimformreceived],
	asr.[apuk_feebatchnumber],
	asr.[apuk_assessorfeetype],
	asrfeetype.[LocalizedLabel] AS [apuk_assessorfeetype_description],
	asr.[apuk_claimstatus],
	claimstatus.[LocalizedLabel] AS [apuk_claimstatus_description],
	asr.[apuk_lionheartdonation],
	asr.[transactioncurrencyid],
	curr.[currencyname] AS [TransactionCurrencyIdName],
	--asr.[Rics_Hotel],
	--asr.[rics_hotel_Base],
	--asr.[Rics_Meals],
	--asr.[rics_meals_Base],
	asr.[apuk_name] AS [Rics_name],
	--asr.[Rics_Other],
	--asr.[rics_other_Base],
	--asr.[Rics_OvernightAccommodationRequired],
	asr.[apuk_papersdispatched] AS [Rics_PapersDispatched],
	--asr.[Rics_Parking],
	--asr.[rics_parking_Base],
	--asr.[Rics_Rail],
	--asr.[rics_rail_Base],
	asr.[apuk_role] AS [Rics_Role],
	ricsrole.[LocalizedLabel] AS [Rics_Role_Description],
	--asr.[Rics_Taxi],
	--asr.[rics_taxi_Base],
	asr.[statecode],
	stStaeCode.[LocalizedLabel] AS [StateCode_Description],
	asr.[statuscode],
	stStausCode.[LocalizedLabel] AS [StatusCode_Description],
	asr.[apuk_panel] AS [rics_panelid],
	asr.[apuk_assessor] AS [rics_assessorid],
	--asr.[Rics_AssessorExpenseType],
	--asr.[Rics_LionheartDonation],
	asr.[CreatedOnBehalfBy],
	usrcreatedonbehalf.[fullname] AS [CreatedOnBehalfByName],
	asr.[ModifiedOnBehalfBy],
	usrmodifiedonbehalf.[fullname] AS [ModifiedOnBehalfByName]
FROM synapse_ce.apuk_assessorrole asr
	LEFT JOIN synapse_ce.StateMetadata stStaeCode
		ON asr.[statecode] = stStaeCode.[State]
			AND stStaeCode.[EntityName] = 'apuk_assessorrole'
	LEFT JOIN synapse_ce.StatusMetadata stStausCode
		ON asr.[statuscode] = stStausCode.[Status]
			AND stStausCode.[EntityName] = 'apuk_assessorrole'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON asr.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON asr.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON asr.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.OptionSetMetadata ricsrole
		ON asr.[apuk_role] = ricsrole.[Option]
			AND ricsrole.[EntityName] = 'apuk_assessorrole'
			AND ricsrole.[OptionSetName] = 'apuk_role'
	LEFT JOIN synapse_ce.systemuser usrcreatedonbehalf
		ON asr.[createdonbehalfby] = usrcreatedonbehalf.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedonbehalf
		ON asr.[modifiedonbehalfby] = usrmodifiedonbehalf.[systemuserid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON asr.[transactioncurrencyid] = curr.[transactioncurrencyid]
	LEFT JOIN synapse_ce.OptionSetMetadata claimstatus
		ON asr.[apuk_claimstatus] = claimstatus.[Option]
		AND claimstatus.[OptionSetName] = 'apuk_claimstatus'
		AND claimstatus.[EntityName] = 'apuk_assessorrole'
	LEFT JOIN synapse_ce.OptionSetMetadata asrfeetype
		ON asr.[apuk_assessorfeetype] = asrfeetype.[Option]
		AND asrfeetype.[OptionSetName] = 'apuk_assessorfeetype'
		AND asrfeetype.[EntityName] = 'apuk_assessorrole'
--WHERE apuk_assessorroleid = '00000000-0000-0000-0000-000000000000'
