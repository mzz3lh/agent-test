/****** Object:  View [dbo].[vwProductGroup]    Script Date: 06/07/2021 11:06:27 ******/
/*
CREATE OR ALTER VIEW [dbo].[vwProductGroup]
AS
SELECT 
	pg.[apuk_productgroupid] AS [RICS_ProductGroupId],
	pg.[apuk_name] AS [ProductGroup],
	pg.[statecode] AS [State_Code],
	stStatecode.[LocalizedLabel] AS [StateCode_Description],
	pg.[createdon] AS [Created_On],
	pg.[createdby] AS [Created_By],
	usrcreatedby.[fullname] AS [CreatedByName],
	pg.[modifiedon] AS [Modified_On],
	pg.[modifiedby] AS [Modified_By],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	pg.[apuk_type] AS [Ricsv2_Type],
	ricstype.[LocalizedLabel] AS [Ricsv2_Type_Description]
FROM [synapse_ce].[apuk_productgroup] pg
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON pg.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON pg.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.OptionSetMetadata ricstype
		ON pg.[apuk_type] = ricstype.[Option]
			AND ricstype.[EntityName] = 'apuk_productgroup'
			AND ricstype.[OptionSetName] = 'apuk_type'
	LEFT JOIN synapse_ce.StateMetadata stStatecode
		ON pg.[statecode] = stStatecode.[State]
			AND stStatecode.[EntityName] = 'apuk_productgroup'
