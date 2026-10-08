CREATE   VIEW [sharedo].[vwAccountAddresses]
AS
SELECT 
	acc.accountid
	,acc.address1_addresstypecode
	,optaddr1typecode.LocalizedLabel as address1_addresstypecodename
	,acc.address1_city
	,acc.address1_country
	,acc.address1_county
	,acc.address1_fax
	,acc.address1_freighttermscode
	,acc.address1_latitude
	,acc.address1_line1
	,acc.address1_line2
	,acc.address1_line3
	,acc.address1_longitude
	,acc.address1_name
	,acc.address1_postalcode
	,acc.address1_postofficebox
	,acc.address1_shippingmethodcode
	,optaddr1shipmethodcode.LocalizedLabel as address1_shippingmethodcodename
	,acc.address1_stateorprovince
	,acc.address1_telephone1
	,acc.address1_telephone2
	,acc.address1_telephone3
	,acc.address2_addresstypecode
	,optaddr2typecode.LocalizedLabel as address2_addresstypecodename
	,acc.address2_city
	,acc.address2_country
	,acc.address2_county
	,acc.address2_fax
	,acc.address2_freighttermscode
	,acc.address2_latitude
	,acc.address2_line1
	,acc.address2_line2
	,acc.address2_line3
	,acc.address2_longitude
	,acc.address2_name
	,acc.address2_postalcode
	,acc.address2_postofficebox
	,acc.address2_shippingmethodcode
	,optaddr2shipmethodcode.LocalizedLabel as address2_shippingmethodcodename
	,acc.address2_stateorprovince
	,acc.address2_telephone1
	,acc.address2_telephone2
	,acc.address2_telephone3
	
	,acc.emailaddress1
	,acc.emailaddress2
	,acc.emailaddress3
FROM synapse_ce.account acc
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr1typecode
		ON acc.address1_addresstypecode = optaddr1typecode.[Option]
		AND optaddr1typecode.[OptionSetName] = 'address1_addresstypecode'
		AND optaddr1typecode.[EntityName] = 'account'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr2typecode
		ON acc.address2_addresstypecode = optaddr2typecode.[Option]
		AND optaddr2typecode.[OptionSetName] = 'address2_addresstypecode'
		AND optaddr2typecode.[EntityName] = 'account'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr1shipmethodcode
		ON acc.address1_shippingmethodcode = optaddr1shipmethodcode.[Option]
		AND optaddr1shipmethodcode.[OptionSetName] = 'address1_shippingmethodcode'
		AND optaddr1shipmethodcode.[EntityName] = 'account'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr2shipmethodcode
		ON acc.address2_shippingmethodcode = optaddr2shipmethodcode.[Option]
		AND optaddr2shipmethodcode.[OptionSetName] = 'address2_shippingmethodcode'
		AND optaddr2shipmethodcode.[EntityName] = 'account'

WHERE AccountID IN (SELECT AccountID FROM sharedo.StagingContactAndAccount
				WHERE AccountID IS NOT NULL)
