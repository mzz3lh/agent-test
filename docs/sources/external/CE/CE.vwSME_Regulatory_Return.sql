CREATE VIEW CE.vwSME_Regulatory_Return AS

	SELECT 
	 RR.apuk_regulatoryreturnid
	,RR.apuk_regulatedfirmid
	,RR.apuk_regulationtype
	,RR.apuk_regulationtype_Description
	,RR.apuk_returntype
	,RRT.apuk_returntype_grouped
	,RR.apuk_returntypeName
	,RR.apuk_regulatedschemeid
	,CAST(RR.apuk_submitteddate AS DATE) AS apuk_submitteddate
	FROM synapse_ce.vwRegulatoryReturn RR
	LEFT JOIN synapse_ce.vwapuk_regulatoryreturntype RRT
		ON RRT.Id = apuk_returntype
	WHERE 1=1 
	AND RR.StatusCode = 1 --Active
	AND apuk_returnstatus = 200000009 --Payment Complete
	AND apuk_regulatedschemeid IS NOT NULL
	AND apuk_submitteddate IS NOT NULL
