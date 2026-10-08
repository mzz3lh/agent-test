CREATE   VIEW [CE].[vwConcessionType] AS

	SELECT 
	 CONCT.[Id]
	,CONCT.[statecode]
	,CONCT.[statuscode]
	,CONCT.[apuk_perpetualnonperpetual]
	,CONCT.[apuk_cpdexemption]
	,CONCT.[apuk_nottargetedforcpd]
	,CONCT.[apuk_dualmembership]
	,CONCT.[apuk_exceptionalhardship]
	,CONCT.[apuk_requiresenddate]
	,CONCT.[createdonbehalfby]
	,CONCT.[createdonbehalfby_entitytype]
	,CONCT.[apuk_productid]
	,CONCT.[apuk_productid_entitytype]
	,CONCT.[modifiedby]
	,CONCT.[modifiedby_entitytype]
	,CONCT.[createdby]
	,CONCT.[createdby_entitytype]
	,CONCT.[organizationid]
	,CONCT.[organizationid_entitytype]
	,CONCT.[modifiedonbehalfby]
	,CONCT.[modifiedonbehalfby_entitytype]
	,CONCT.[createdonbehalfbyyominame]
	,CONCT.[organizationidname]
	,CONCT.[apuk_discount]
	,CONCT.[importsequencenumber]
	,CONCT.[apuk_name]
	,CONCT.[utcconversiontimezonecode]
	,CONCT.[createdbyyominame]
	,CONCT.[modifiedbyname]
	,CONCT.[versionnumber]
	,CONCT.[modifiedbyyominame]
	,CONCT.[timezoneruleversionnumber]
	,CONCT.[apuk_concessiontypeid]
	,CONCT.[apuk_productidname]
	,CONCT.[modifiedon]
	,CONCT.[modifiedonbehalfbyyominame]
	,CONCT.[createdbyname]
	,CONCT.[createdon]
	,CONCT.[createdonbehalfbyname]
	,CONCT.[modifiedonbehalfbyname]
	,CONCT.[overriddencreatedon]
	,REPLACE(PRD.Product_Number, 'rcs', '') AS Product_Number
	,CASE WHEN apuk_dualmembership IS NULL OR apuk_dualmembership = 0 THEN Product_Name ELSE 'Dual Concession' END AS 'Product Name (Dual Conc Roll Up)'
	FROM [synapse_ce].[apuk_concessiontype] CONCT
	LEFT JOIN CE.vwProduct PRD
		ON CONCT.apuk_productid = PRD.ProductId
	WHERE CONCT.apuk_productid IS NOT NULL
		AND ID <> '00000000-0000-0000-0000-000000000000' --Temp Fix until CONAIBS is resolved
		AND ID <> '00000000-0000-0000-0000-000000000000'--Temp Fix until CONISA is resolved
