/****** Object:  View [dbo].[vwRics_Industrysector]    Script Date: 06/07/2021 11:06:27 ******/
CREATE   VIEW [synapse_ce].[vwRics_Industrysector]
AS
SELECT
	ind.[apuk_industrysectorid] AS [Rics_industrysectorId],
	ind.[apuk_name] AS [Rics_name],
	ind.[createdon] AS [Created_On],
	ind.[CreatedBy],
	usrcreatedby.[fullname] AS [CreatedByName],
	ind.[modifiedon] AS [Modified_On],
	ind.[modifiedby] AS [ModifiedBy],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	--ind.[OwnerId],
	ind.[Statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	ind.[Statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.apuk_industrysector ind
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON ind.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'apuk_industrysector'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON ind.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'apuk_industrysector'
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON ind.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON ind.[modifiedby] = usrmodifiedby.[systemuserid]
