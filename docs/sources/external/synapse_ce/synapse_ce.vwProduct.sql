CREATE   VIEW [synapse_ce].[vwProduct]
AS
SELECT 
	prd.[ProductId],
	prd.[Name] AS [Product_Name],
	ISNULL(prd.[apuk_productgroupid], '00000000-0000-0000-0000-000000000000') AS [Rics_ProductGroupId],
	ISNULL(prd.[apuk_productgroup], 'Unknown') AS  [RICS_ProductGroup_Name],
	prd.[productnumber] AS [Product_Number],
	prd.[createdon] AS [Created_On],
	prd.[createdby] AS [Created_By],
	usrcreatedby.[fullname] AS [CreatedByName],
	prd.[modifiedon] AS [Modified_On],
	prd.[modifiedby] AS [Modified_By],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	prd.[validfromdate] AS [Valid_From],
	prd.[validtodate] AS [Valid_To],
	prd.[statecode] AS [State_Code],
	statecode.[LocalizedLabel] AS [StateCode_Description],
	prd.[statuscode],
	statuscode.[LocalizedLabel] AS [StatusCode_Description],
	prd.[producttypecode] AS [ProductType_Code],
	prdtypecode.[LocalizedLabel] AS [ProductTypeCode_Description],
	prd.[parentproductid] AS [ParentProductId],
	prdparent.[Name] AS [ParentProductIdName]
FROM [synapse_ce].[product] prd
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON prd.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON prd.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata statecode
		ON prd.[statecode] = statecode.[State]
			AND statecode.[EntityName] = 'product'
	LEFT JOIN synapse_ce.StatusMetadata statuscode
		ON prd.[statuscode] = statuscode.[Status]
			AND statuscode.[EntityName] = 'product'
	LEFT JOIN synapse_ce.OptionSetMetadata prdtypecode
		ON prd.[producttypecode] = prdtypecode.[Option]
			AND prdtypecode.[EntityName] = 'product'
			AND prdtypecode.[OptionSetName] = 'producttypecode'
	LEFT JOIN synapse_ce.product prdparent
		ON prd.[parentproductid] = prdparent.[productid]


UNION

	SELECT
		'00000000-0000-0000-0000-000000000000' AS ProductId,
		'Unknown' AS Product_Name,
		'00000000-0000-0000-0000-000000000000' AS Rics_ProductGroupId,
		'Unknown' AS Rics_ProductGroup_Name,
		'rcsKNKNOWN' AS Product_Number,
		'1900-01-01' AS Created_On,
		'00000000-0000-0000-0000-000000000000' AS Created_By,
		'BI User' AS CreatedByName,
		'1900-01-01' AS Modified_On,
		'00000000-0000-0000-0000-000000000000' AS ModifiedBy,
		'BI User' AS ModifiedByName,
		NULL AS Valid_From,
		NULL AS Valid_To,
		0 AS StateCode,
		'Active' AS StateCode_Description,
		1 AS StatusCode,
		'Active' AS StatusCode_Description,
		1 AS ProductType_Code,
		'Sales Inventory' AS ProductTypeCode_Description,
		NULL AS ParentProductId,
		NULL AS ParentProductIdName
