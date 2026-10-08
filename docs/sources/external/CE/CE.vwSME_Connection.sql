CREATE VIEW [CE].[vwSME_Connection] AS

SELECT
CNN.record1id AS Reg_Return_ID,
CNN.record2id AS Survey_Response_ID
FROM synapse_ce.connection CNN
WHERE record1id_entitytype = 'apuk_regulatoryreturn'
AND record2id_entitytype = 'rics_surveyresponse'
AND statecode = '0'
