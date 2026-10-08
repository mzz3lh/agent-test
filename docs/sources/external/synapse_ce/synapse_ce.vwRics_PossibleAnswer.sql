CREATE   VIEW [synapse_ce].[vwRics_PossibleAnswer]
AS
SELECT 
	pans.[rics_possibleanswerid],
	pans.[rics_name],
	pans.[rics_requiresvalue],
	pans.[rics_subquestion],
	pans.[rics_answertext],
	pans.[rics_score],
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
FROM synapse_ce.rics_possibleanswer pans
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
			AND stStateCode.[EntityName] = 'rics_possibleanswer'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON pans.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'rics_possibleanswer'



--SELECT * INTO tempsales FROM vwRics_Question
