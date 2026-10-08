CREATE   VIEW [sharedo].[vwContactAddresses]
AS
SELECT 
	cnt.contactid
	,cnt.address1_addresstypecode
	,optaddr1typecode.LocalizedLabel as address1_addresstypecodename
	,cnt.address1_city
	,cnt.address1_country
	,cnt.address1_county
	,cnt.address1_fax
	,cnt.address1_freighttermscode
	,cnt.address1_latitude
	,cnt.address1_line1
	,cnt.address1_line2
	,cnt.address1_line3
	,cnt.address1_longitude
	,cnt.address1_name
	,cnt.address1_postalcode
	,cnt.address1_postofficebox
	,cnt.address1_shippingmethodcode
	,optaddr1shipmethodcode.LocalizedLabel as address1_shippingmethodcodename
	,cnt.address1_stateorprovince
	,cnt.address1_telephone1
	,cnt.address1_telephone2
	,cnt.address1_telephone3
	,cnt.address2_addresstypecode
	,optaddr2typecode.LocalizedLabel as address2_addresstypecodename
	,cnt.address2_city
	,cnt.address2_country
	,cnt.address2_county
	,cnt.address2_fax
	,cnt.address2_freighttermscode
	,cnt.address2_latitude
	,cnt.address2_line1
	,cnt.address2_line2
	,cnt.address2_line3
	,cnt.address2_longitude
	,cnt.address2_name
	,cnt.address2_postalcode
	,cnt.address2_postofficebox
	,cnt.address2_shippingmethodcode
	,optaddr2shipmethodcode.LocalizedLabel as address2_shippingmethodcodename
	,cnt.address2_stateorprovince
	,cnt.address2_telephone1
	,cnt.address2_telephone2
	,cnt.address2_telephone3
	,cnt.address3_addresstypecode
	,optaddr3typecode.LocalizedLabel as address3_addresstypecodename
	,cnt.address3_city
	,cnt.address3_country
	,cnt.address3_county
	,cnt.address3_fax
	,cnt.address3_freighttermscode
	,cnt.address3_latitude
	,cnt.address3_line1
	,cnt.address3_line2
	,cnt.address3_line3
	,cnt.address3_longitude
	,cnt.address3_name
	,cnt.address3_postalcode
	,cnt.address3_postofficebox
	,cnt.address3_shippingmethodcode
	,optaddr3shipmethodcode.LocalizedLabel as address3_shippingmethodcodename
	,cnt.address3_stateorprovince
	,cnt.address3_telephone1
	,cnt.address3_telephone2
	,cnt.address3_telephone3
	,cnt.emailaddress1
	,cnt.emailaddress2
	,cnt.emailaddress3
FROM synapse_ce.contact cnt
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr1typecode
		ON cnt.address1_addresstypecode = optaddr1typecode.[Option]
		AND optaddr1typecode.[OptionSetName] = 'address1_addresstypecode'
		AND optaddr1typecode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr2typecode
		ON cnt.address2_addresstypecode = optaddr2typecode.[Option]
		AND optaddr2typecode.[OptionSetName] = 'address2_addresstypecode'
		AND optaddr2typecode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr3typecode
		ON cnt.address3_addresstypecode = optaddr3typecode.[Option]
		AND optaddr3typecode.[OptionSetName] = 'address3_addresstypecode'
		AND optaddr3typecode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr1shipmethodcode
		ON cnt.address1_shippingmethodcode = optaddr1shipmethodcode.[Option]
		AND optaddr1shipmethodcode.[OptionSetName] = 'address1_shippingmethodcode'
		AND optaddr1shipmethodcode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr2shipmethodcode
		ON cnt.address2_shippingmethodcode = optaddr2shipmethodcode.[Option]
		AND optaddr2shipmethodcode.[OptionSetName] = 'address2_shippingmethodcode'
		AND optaddr2shipmethodcode.[EntityName] = 'contact'
	LEFT JOIN synapse_ce.OptionSetMetadata optaddr3shipmethodcode
		ON cnt.address3_shippingmethodcode = optaddr3shipmethodcode.[Option]
		AND optaddr3shipmethodcode.[OptionSetName] = 'address3_shippingmethodcode'
		AND optaddr3shipmethodcode.[EntityName] = 'contact'


WHERE ContactID IN (SELECT ContactID FROM sharedo.StagingContactAndAccount
				WHERE ContactID IS NOT NULL)
