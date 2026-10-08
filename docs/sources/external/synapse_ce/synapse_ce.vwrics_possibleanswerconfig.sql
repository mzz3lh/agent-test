CREATE   VIEW [synapse_ce].[vwrics_possibleanswerconfig]
AS
SELECT 
	pans.[rics_possibleanswerconfigid],
	pans.[rics_name],
	pans.[rics_possibleanswer],
	pans.[rics_question],
	pans.[rics_order],
	pans.[createdon],
	pans.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	pans.[createdonbehalfby],
	usrcreatedonbehalfby.[fullname] AS [CreatedOnbehalfByName],
	pans.[modifiedon],
	pans.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	pans.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[fullname] AS [ModifiedOnbehalfByName],
	pans.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	pans.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	pans.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]

FROM synapse_ce.rics_possibleanswerconfig pans
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON pans.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON pans.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON pans.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrcreatedonbehalfby
		ON pans.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedonbehalfby
		ON pans.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON pans.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'rics_possibleanswerconfig'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON pans.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'rics_possibleanswerconfig'
