CREATE   VIEW [synapse_ce].[vwRics_Question]
AS
SELECT 
	qst.[rics_questionid],
	qst.[rics_name],
	qst.[rics_questiontext],
	qst.[rics_helptext],
	qst.[rics_questiontitle],
	qst.[rics_attachedto],
	ricsattachedto.[LocalizedLabel] AS [rics_attachedto_Description],
	qst.[rics_questiontype],
	ricsquestiontype.[LocalizedLabel] AS [rics_questiontype_Description],
	qst.[rics_requiresevidence],
	qst.[rics_requiresheadings],
	qst.[createdon],
	qst.[createdby],
	usrcreatedby.[fullname] AS [CreatedByName],
	qst.[createdonbehalfby],
	usrcreatedonbehalfby.[fullname] AS [CreatedOnbehalfByName],
	qst.[modifiedon],
	qst.[modifiedby],
	usrmodifiedby.[fullname] AS [ModifiedByName],
	qst.[modifiedonbehalfby],
	usrmodifiedonbehalfby.[fullname] AS [ModifiedOnbehalfByName],
	qst.[ownerid],
	ownid.[fullname] AS [OwnerIdName],
	qst.[rics_validfrom],
	qst.[rics_validto],
	qst.[statecode],
	stStateCode.[LocalizedLabel] AS [StateCode_Description],
	qst.[statuscode],
	stStatusCode.[LocalizedLabel] AS [StatusCode_Description]
FROM synapse_ce.rics_question qst
	LEFT JOIN synapse_ce.systemuser usrcreatedby
		ON qst.[createdby] = usrcreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON qst.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser ownid
		ON qst.[ownerid] = ownid.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrcreatedonbehalfby
		ON qst.[createdonbehalfby] = usrcreatedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedonbehalfby
		ON qst.[modifiedonbehalfby] = usrmodifiedonbehalfby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStateCode
		ON qst.[statecode] = stStateCode.[State]
			AND stStateCode.[EntityName] = 'rics_question'
	LEFT JOIN synapse_ce.StatusMetadata stStatusCode
		ON qst.[statuscode] = stStatusCode.[Status]
			AND stStatusCode.[EntityName] = 'rics_question'
	LEFT JOIN synapse_ce.OptionSetMetadata ricsattachedto
		ON qst.[rics_attachedto] = ricsattachedto.[Option]
			AND ricsattachedto.[OptionSetName] = 'rics_attachedto'
			AND ricsattachedto.[EntityName] = 'rics_question'
	LEFT JOIN synapse_ce.GlobalOptionSetMetadata ricsquestiontype
		ON qst.[rics_questiontype] = ricsquestiontype.[Option]
			AND ricsquestiontype.[OptionSetName] = 'rics_questiontype'
			AND ricsquestiontype.[EntityName] = 'rics_question'
