CREATE VIEW CE.vwSME_Regulated_Schemes AS

	SELECT
	 RGS.apuk_regulatedschemeid AS 'Scheme ID'
	,RGS.apuk_regulatedschemenumber AS 'Scheme No.'
	,RGS.apuk_regulatedschemetypeidName AS 'Scheme Type'
	,RGS.apuk_licensedfirmid AS 'Account ID'
	,RGS.StateCode_Description AS 'State'
	,RGS.StatusCode_Description AS 'Status'
 	FROM [synapse_ce].[vwRegulatedScheme] RGS
	WHERE RGS.apuk_schemeenddate IS NULL
	AND apuk_licensedfirmid IS NOT NULL
	AND RGS.statecode = 0 --Active
	AND RGS.apuk_regulatedschemetypeid = '00000000-0000-0000-0000-000000000000' --Regulated by RICS
	AND RGS.statuscode IN (
	 200000006 -- 'Licence Approved'
	,200000007 -- 'Licence Approved with Conditions'
	,200000005 -- 'Deregistration in Progress'
	,200000004 -- 'Deregistration Deferred'
	,200000011 -- 'Deregistration Requested'
	)
