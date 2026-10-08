CREATE   VIEW [synapse_ce].[vwDirectDebitDetail]
AS
SELECT 
	dd.[apuk_directdebitdetailid]
	,dd.[apuk_name]
	,dd.[createdon]
	,dd.[createdby]
	,usrcreatedby.[fullname] AS [CreatedByName]
	,dd.[modifiedon]
	,dd.[modifiedby]
	,usrmodifiedby.[fullname] AS [ModifiedByName]
	,dd.[statecode]
	,stStateCode.[LocalizedLabel] AS [StateCode_Description]
	,dd.[statuscode]
	,stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
	,dd.[apuk_paymentcycle]
	,paycycle.[LocalizedLabel] AS [apuk_paymentcycle_description]
	,dd.[apuk_transferredtofinops]
	,dd.[apuk_ricscompany]
	,cmp.[cdm_name] AS [apuk_ricscompany_name]
	,dd.[apuk_bankaddresscountryid]
	,cntry.[apuk_name] AS [apuk_bankaddresscountryid_Name]
	,dd.[organizationid]
	,org.[name] AS [organizationidName]
	,dd.[apuk_currencyid]
	,curr.[currencyname]
	,curr.[isocurrencycode]
	,dd.[apuk_customerid] -- contact
	,dd.[apuk_bankaddresscity]
	,dd.[apuk_bankaddresspostcode]
	,dd.[apuk_bankaddressline1]
	,dd.[apuk_bankaddressline2]
	,dd.[apuk_bankaddressline3]
	,dd.[apuk_bankaccountid]
	,dd.[apuk_iban]
	,dd.[apuk_sortcode]
	,dd.[apuk_paymenttext]
	,dd.[apuk_authorisationdate]
	,dd.[apuk_commencementdate]
	,dd.[apuk_bankname]
	,dd.[apuk_accountnumber]
	,dd.[overriddencreatedon]
	,dd.[createdonbehalfby]
	,dd.[modifiedonbehalfby]
FROM synapse_ce.apuk_directdebitdetail dd
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON dd.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON dd.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON dd.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_directdebitdetail'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON dd.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_directdebitdetail'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata paycycle
		ON dd.[apuk_paymentcycle] = paycycle.[Option]
		AND paycycle.[OptionSetName] = 'apuk_paymentcycle'
		AND paycycle.[EntityName] = 'apuk_directdebitdetail'
	LEFT JOIN synapse_ce.cdm_company cmp
		ON dd.[apuk_ricscompany] = cmp.[cdm_companyid]
	LEFT JOIN synapse_ce.apuk_country cntry
		ON dd.[apuk_bankaddresscountryid] = cntry.[apuk_countryid]
	LEFT JOIN synapse_ce.organization org
		ON dd.[organizationid] = org.[organizationid]
	LEFT JOIN synapse_ce.transactioncurrency curr
		ON dd.[apuk_currencyid] = curr.[transactioncurrencyid]
	WHERE NOT EXISTS (
		SELECT contactid
		FROM CE.tblContact_Test_Records TST
		WHERE TST.contactid = dd.[apuk_customerid]
		)
