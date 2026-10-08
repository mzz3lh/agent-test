CREATE   VIEW [synapse_ce].[vwCampaign]
AS
SELECT 
	camp.[msevtmgt_eventid] AS [CampaignId],
	cmp.[cdm_name] AS [cclevent_legalentityidName],
	camp.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	camp.[createdon] AS [Created_On],
	camp.[ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	camp.[modifiedon] AS [Modified_On],
	cur.[currencyname] AS  [TransactionCurrencyIdName],
	ter.[name] AS [rics_regionidName],
	cnt.[apuk_name] AS [cclevent_countryidName],
	--camp.[cclevent_originatingeventidName],
	camp.[apuk_costcentreid] AS [CostCentreId],
	NULL AS [CostCentreCode],
	--camp.[Product_Group],
	camp.[OwnerId],
	ownid.[fullname] AS [Owner],
	'Unknown' AS [Sales_Team],
	--camp.[TypeCode],
	--camp.[TypeCode_Description],
	camp.[msevtmgt_budgetallocated] AS [BudgetedCost],
	camp.[msevtmgt_budgetallocated_base] AS [BudgetedCost_Base],
	--camp.[TotalActualCost],
	--camp.[TotalActualCost_Base],
	camp.[StateCode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	camp.[StatusCode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description],
	--camp.[CodeName],
	camp.[msevtmgt_miscellaneouscosts] AS [OtherCost],
	--camp.[other] AS [OtherCost_Base],
	camp.[msevtmgt_description] AS [Description],
	camp.[msevtmgt_name] AS [Name],
	camp.[ExchangeRate],
	--camp.[Cclevent_totalprofit],
	--camp.[cclevent_totalprofit_Base],
	camp.[msevtmgt_maximumeventcapacity] AS [Cclevent_MaximumCapacity],
	camp.[msevtmgt_maximumeventcapacity] AS [MSA_MaximumEventCapacity],
	camp.[apuk_totaldelegaterevenue] AS [Cclevent_revenuetickets],
	camp.[apuk_totaldelegaterevenue_base] AS [cclevent_revenuetickets_Base],
	camp.[msevtmgt_miscellaneouscosts] AS [Ccl_OtherCosts],
	camp.[msevtmgt_miscellaneouscosts_base] AS [ccl_othercosts_Base],
	camp.[apuk_numberofcpdhours] AS [Cclevent_cpdavailable],
	--camp.[Cclevent_nonmembersattending],
	camp.[msevtmgt_eventtype] AS [MSA_EventType],
	evttype.[LocalizedLabel] AS [EventType_Description],
	camp.[msevtmgt_totalcostofeventsactivities] AS [Cclevent_totalcostofcampaign],
	camp.[msevtmgt_totalcostofeventsactivities_base] AS [cclevent_totalcostofcampaign_Base],
	camp.[msevtmgt_eventstartdate] AS [ActualStart],
	camp.[msevtmgt_eventenddate] AS [ActualEnd],
	--camp.[Ccl_TotalCount],
	camp.[msevtmgt_registrationcount] AS [MSA_RegistrationCount],
	camp.[apuk_eventcode] AS [Cclevent_eventid],
	ven.[msevtmgt_city] AS [MSA_City],
	ven.[msevtmgt_name] AS [Venue],
	camp.[apuk_availableseats] AS [Cclevent_availableseats],
	camp.[apuk_numberofcpdhours] AS [Cclevent_cpdhours],
	camp.[msevtmgt_totalrevenuefromtheevent] AS [Cclevent_totalrevenue],
	camp.[msevtmgt_totalrevenuefromtheevent_base] AS [cclevent_totalrevenue_Base],
	camp.[apuk_businessarea] AS [cclevent_businessarea],
	barea.[LocalizedLabel] AS [BusinessArea_Descritpion],
	camp.[apuk_format],
	fmt.[LocalizedLabel] AS [apuk_format_description]
FROM [synapse_ce].[msevtmgt_event] camp
	LEFT JOIN synapse_ce.cdm_company cmp
		ON camp.[apuk_company] = cmp.[cdm_companyid]
	

	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON camp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON camp.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON camp.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON camp.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'msevtmgt_event'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON camp.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'msevtmgt_event'
	LEFT JOIN synapse_ce.transactioncurrency cur
		ON camp.[transactioncurrencyid] = cur.[transactioncurrencyid]
	LEFT JOIN synapse_ce.territory ter
		ON camp.[apuk_regionallocationid] = ter.[territoryid]
	LEFT JOIN synapse_ce.apuk_country cnt
		ON camp.[apuk_countryid] = cnt.[apuk_countryid]
--	LEFT JOIN synapse_ce.apuk_costcentre cc
--		ON camp.[apuk_costcentreid] = cc.[apuk_costcentreid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata evttype
		ON camp.[msevtmgt_eventtype] = evttype.[Option]
			AND evttype.[OptionSetName] = 'msevtmgt_eventtype'
			AND evttype.[EntityName] = 'msevtmgt_event'
	LEFT JOIN synapse_ce.msevtmgt_venue ven
		ON camp.[msevtmgt_primaryvenue] = ven.[msevtmgt_venueid]
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata barea
		ON camp.[apuk_businessarea] = barea.[Option]
			AND barea.[OptionSetName] = 'apuk_businessarea'
			AND barea.[EntityName] = 'msevtmgt_event'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata fmt
		ON camp.apuk_format = fmt.[Option]
			AND fmt.[OptionSetName] = 'apuk_format'
			AND fmt.[EntityName] = 'msevtmgt_event'
