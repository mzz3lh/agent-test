CREATE   VIEW [synapse_ce].[vwapuk_drstype]
As
SELECT 
	drs.apuk_drstypeid, 
	drs.apuk_name, 
	drs.createdon, 
	drs.rics_drsgroup, 
	dg.rics_name AS rics_drsgroupName,
	drs.apuk_typecode, 
	drs.statuscode, 
	stStatuscode.LocalizedLabel AS statuscode_description,
	drs.statecode, 
	stStatecode.[LocalizedLabel] AS statecode_description,
	drs.overriddencreatedon, 
	drs.modifiedon, 
	drs.modifiedonbehalfby, 
	drs.modifiedby, 
	usrmodifiedby.[fullname] AS [modifiedbyName],
	drs.createdonbehalfby, 
	drs.createdby, 
	usrCreatedby.[fullname] AS createdbyName,
	drs.apuk_associatedproduct,
	prd.[name] AS apuk_associatedproductName
FROM synapse_ce.apuk_drstype drs
	LEFT JOIN synapse_ce.product prd
		ON drs.apuk_associatedproduct = prd.productid
	LEFT JOIN synapse_ce.systemuser usrCreatedby
		ON drs.[createdby] = usrCreatedby.[systemuserid]
	LEFT JOIN synapse_ce.systemuser usrmodifiedby
		ON drs.[modifiedby] = usrmodifiedby.[systemuserid]
	LEFT JOIN synapse_ce.StateMetadata stStatecode
		ON drs.statecode = stStatecode.[State]
		AND stStatecode.EntityName = 'apuk_drstype'
	LEFT JOIN synapse_ce.StatusMetadata stStatuscode
		ON drs.statuscode = stStatuscode.[Status]
		AND stStatuscode.EntityName = 'apuk_drstype'
	LEFT JOIN synapse_ce.vwrics_drsgroup dg
		ON drs.rics_drsgroup = dg.rics_drsgroupid
