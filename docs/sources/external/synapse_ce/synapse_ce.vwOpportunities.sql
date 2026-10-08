CREATE   VIEW [synapse_ce].[vwOpportunities]
AS
SELECT 
	opp.[opportunityid] AS [Opportunity_Key],
	opp.[name] AS [Topic],
	opp.[CustomerId],
	ISNULL(cnt.[fullname], acc.[Name]) AS [Customer Name],
	--NULL AS [Company_Name],
	opp.[estimatedvalue] AS [Est_Revenue],
	opp.statuscode,
	oppstatus.[LocalizedLabel] AS [StatusCode_Description],
	opp.[apuk_productgroupid] AS [ProductGroupId],
	opp.[apuk_productgroupidname] AS [Product Group],
	--opp.[apuk_salesstage] AS [SalesCycleStage],
	salescyclestage.[LocalizedLabel] AS [SalesCycleStage],
	opp.statecode,
	oppstate.[LocalizedLabel] AS [StateCode_Description],
	opp.[campaignid] AS [Campaign],
	opp.[schedulefollowup_qualify] AS [Schedule_Followup_Qualify],
	--opp.[salesstage] AS [Sales_Stage],
	salesstage.[LocalizedLabel] AS [Sales_Stage],
	opp.[isrevenuesystemcalculated] AS [IsRevenue_SystemCalculated],
	oppratingcode.[LocalizedLabel] AS [Opportunity_Rating],
	opp.[closeprobability] AS [Close_Probability],
	opp.[stepname] AS [Step_Name],
	opp.[OwnerId],
	ownid.[fullname] AS [Opportunity_Owner],
	opp.[originatingleadidname] AS [Originating_Lead],
	oppsource.[LocalizedLabel] AS [Opportunity_Source],
	--NULL AS [Opportunity_Originator],
	--NULL AS [Opportunity_Number],
	opp.[discountpercentage] AS [Discount_Percentage],
	opp.[modifiedon] AS [Modified_On],
	modonbehalf.[fullname] AS [Modified_By_Onbehalf],
	opp.[modifiedby] AS [Modified_By],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	opp.[apuk_marketingsourceid] AS [MarketingSourceId], -- Need to link to marketing source to get surrogate key
	opp.[resolvefeedback] AS [Resolve_Feedback],
	opp.[apuk_expectedrevenue_base] AS [Exp_Revenue_Base],
	opp.[apuk_expectedrevenue] AS [Exp_Revenue],
	opp.[exchangerate] AS [Exchange_Rate],
	opp.[evaluatefit] AS [Evaluate_Fit],
	--NULL AS [Est_Quantity],
	opp.[estimatedvalue] AS [Est_Value],
	opp.[estimatedclosedate] AS [Est_Close_Date],
	opp.[developproposal] AS [Develop_Proposal],
	opp.[Description],
	opp.[transactioncurrencyidname] AS [Opp_Transaction_Currency],
	opp.[createdon] AS [Created_On],
	createdonbehalf.[fullname] AS [Created_On_Behalf],
	opp.[createdby] AS [Created_By],
	usrcreatedby.[fullname] AS [CreatedByName],
	opp.[parentcontactidname] AS [Parent_Contact],
	opp.[confirminterest] AS [Confirm_Interest],
	opp.[completeinternalreview] AS [Complete_Internal_Review],
	commacc.[RICS_Name] AS [Commercial_Account],
	opp.[actualvalue_base] AS [Act_Value_Base],
	opp.[actualvalue] AS [Act_Value],
	opp.[actualclosedate] AS [Act_Close_Date],
	opp.[parentaccountidname] AS [Parent_Account],
	commacc.[OwnerId] AS [Commercial_Owner],
	owninguser.[territoryidname] AS [Territory], --OwningUser to systemuser
	owninguser.[fullname] AS [OwningUser],
	commacc.[RICS_Account_Status] AS [RICS_Grading], 
	opp.[apuk_source] AS [ricsv1_OpportunitySource],
	oppsource.[LocalizedLabel] [OpportunitySource_Description],
	DATEDIFF(d, opp.[createdon], opp.[actualclosedate]) AS [Close_Period],
	opp.apuk_productsubscriptionid
from [synapse_ce].[opportunity] opp
	LEFT JOIN [synapse_ce].[account] acc
		ON opp.[customerid] = acc.[accountid]
	LEFT JOIN [synapse_ce].[contact] cnt
		ON opp.[customerid] = cnt.[contactid]

	LEFT JOIN synapse_ce.vwCommercialAccount commacc
		ON opp.[apuk_commercialaccountid] = commacc.[Commercial_Account_Key] --commacc.[apuk_commercialaccountid]
	LEFT JOIN [synapse_ce].[StatusMetadata] oppstatus
		ON opp.[statuscode] = oppstatus.[Status]
			AND oppstatus.[EntityName] = 'opportunity'
	LEFT JOIN [synapse_ce].[apuk_productgroup] pg
		ON opp.[apuk_productgroupid] = pg.[apuk_productgroupid]
	LEFT JOIN [synapse_ce].[StateMetadata] oppstate
		ON opp.[statecode] = oppstate.[State]
			AND oppstate.[EntityName] = 'opportunity'
	LEFT JOIN [synapse_ce].[OptionSetMetadata] oppratingcode
		ON opp.[opportunityratingcode] = oppratingcode.[Option]
			AND oppratingcode.[EntityName] = 'opportunity'
			AND oppratingcode.[OptionSetName] = 'opportunityratingcode'
	LEFT JOIN [synapse_ce].[OptionSetMetadata] oppsource
		ON opp.[apuk_source] = oppsource.[Option]
			AND oppsource.[EntityName] = 'opportunity'
			AND oppsource.[OptionSetName] = 'apuk_source'
	LEFT JOIN [synapse_ce].[systemuser] owninguser
		ON opp.[owninguser] = owninguser.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON opp.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON opp.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON opp.[ownerid] = ownid.[systemuserid]
	LEFT JOIN [synapse_ce].[systemuser] createdonbehalf
		ON opp.[createdonbehalfby] = createdonbehalf.[systemuserid]
	LEFT JOIN [synapse_ce].[systemuser] modonbehalf
		ON opp.[modifiedonbehalfby] = modonbehalf.[systemuserid]

	LEFT JOIN synapse_ce.GlobalOptionSetMetadata salescyclestage
		ON opp.[apuk_salesstage] = salescyclestage.[Option]
			AND salescyclestage.[OptionSetName] = 'apuk_salesstage'
			AND salescyclestage.[EntityName] = 'opportunity'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata salesstage
		ON opp.[salesstage] = salesstage.[Option]
			AND salesstage.[OptionSetName] = 'salesstage'
			AND salesstage.[EntityName] = 'opportunity'
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = opp.[customerid]
		)
--WHERE opp.opportunityid = '00000000-0000-0000-0000-000000000000'
