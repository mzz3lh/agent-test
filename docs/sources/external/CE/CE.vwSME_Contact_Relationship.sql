CREATE VIEW [CE].[vwSME_Contact_Relationship] AS

SELECT 
 Rics_contactrelationshipId
,rics_contactid
,rics_accountid
,Rics_RelationshipType
,Rics_RelationshipType_Description
,Rics_StartDate
,Rics_EndDate
,apuk_primaryemployment
,apuk_primaryemployment_description
FROM synapse_ce.vwRics_ContactRelationship
WHERE statecode = 0 --Active
AND apuk_primaryemployment = 1 --Yes
AND Rics_EndDate IS NULL
AND rics_accountid IS NOT NULL
