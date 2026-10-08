CREATE   VIEW [synapse_ce].[vwInternationalPayments] 
AS

SELECT	iPay.[apuk_internationalpaymentsid] AS [rics_internationalpaymentsid]
		,iPay.[apuk_name] AS [rics_name]

		,iPay.[createdon]
		,iPay.[createdby]
		,usrcreatedby.[fullname] AS [CreatedByName]

		,iPay.[createdonbehalfby]
		,usrCrBehalf.[fullname] AS [createdonbehalfbyname]
		
		,iPay.[modifiedon]
		,iPay.[modifiedby]
		,usrmodifiedby.[fullname] AS [ModifiedByName]
		,iPay.[modifiedonbehalfby]
		,usrModBehalf.[fullname] AS [modifiedonbehalfbyname]
		
		,iPay.[apuk_paymenttype] AS [rics_paymenttype]
		,payType.[LocalizedLabel] AS [rics_paymenttype_Description]

		,iPay.[apuk_processedbyslteam] AS [rics_processedbyslteam]

		,iPay.[transactioncurrencyid]
		,cur.[currencyname] AS  [TransactionCurrencyIdName]

		,iPay.[apuk_contactid] AS [rics_contactid]

		,iPay.[apuk_localgroupid] AS [Rics_LocalGroupId]

		,iPay.[organizationid]
		,iPay.[organizationid_entitytype]
		,iPay.[organizationidname]

		,iPay.[apuk_quote] AS [rics_quote_id]

		,iPay.[apuk_ukincomeamount_base] AS [rics_ukincomeamount_base]
		,iPay.[apuk_localincomeamount_base] AS [rics_localincomeamount_base] 
		,iPay.[apuk_paymentamount_base] AS [rics_paymentamount_base]
		,iPay.[apuk_localincomeamount] AS [rics_localincomeamount]
		,iPay.[apuk_ukincomeamount] AS [rics_ukincomeamount]
		,iPay.[apuk_paymentamount] AS [rics_paymentamount]
		,iPay.[apuk_paymentdate] AS [rics_paymentdate]

		,iPay.[importsequencenumber]
		,iPay.[apuk_dateprocessed] AS [rics_dateprocessed]
		,iPay.[timezoneruleversionnumber]
		,iPay.[apuk_membercurrency] AS [rics_membercurrency_name]
		,iPay.[exchangerate]
		,iPay.[apuk_localgroup] AS [rics_localgroup]
		,iPay.[apuk_paymentreference] AS [rics_paymentreference]
		,iPay.[apuk_membernumber] AS [rics_membernumber]
		,iPay.[apuk_country] AS [rics_country_name]
		,iPay.[overriddencreatedon]
		,iPay.[utcconversiontimezonecode]

		,iPay.[statecode]
		,stStateCode.[LocalizedLabel] AS [StateCode_Description]
		,iPay.[statuscode]
		,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
  FROM [synapse_ce].[apuk_internationalpayments] iPay
		LEFT JOIN synapse_ce.systemuser usrcreatedby
			ON iPay.[createdby] = usrcreatedby.[systemuserid]
		LEFT JOIN synapse_ce.systemuser usrmodifiedby
			ON iPay.[modifiedby] = usrmodifiedby.[systemuserid]
		LEFT JOIN synapse_ce.systemuser usrCrBehalf
			ON iPay.[createdonbehalfby] = usrCrBehalf.[systemuserid]
		LEFT JOIN synapse_ce.systemuser usrModBehalf
			ON iPay.[modifiedonbehalfby] = usrModBehalf.[systemuserid]

		LEFT JOIN synapse_ce.OptionSetMetadata payType
			ON iPay.[apuk_paymenttype] = payType.[Option]
				AND payType.[EntityName] = 'apuk_internationalpayments'
				AND payType.[OptionSetName] = 'apuk_paymenttype'

		LEFT JOIN synapse_ce.transactioncurrency cur
			ON iPay.[transactioncurrencyid] = cur.[transactioncurrencyid]

		LEFT JOIN synapse_ce.StateMetadata stStateCode
			ON iPay.[statecode] = stStateCode.[State]
				AND stStateCode.[EntityName] = 'apuk_internationalpayments'
		LEFT JOIN synapse_ce.StatusMetadata stStatusCode
			ON iPay.[statuscode] = stStatusCode.[Status]
				AND stStatusCode.[EntityName] = 'apuk_internationalpayments'
		WHERE NOT EXISTS (
			SELECT contactid
			FROM CE.tblContact_Test_Records TST
			WHERE TST.contactid = iPay.[apuk_contactid]
		)
