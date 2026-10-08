CREATE VIEW dbo.vwRics_SurveyRequest
AS
SELECT        rics_surveyrequestid, rics_name, rics_surveyresponse, createdon, createdby, CreatedByName, modifiedon, modifiedby, ModifiedByName, ownerid, OwnerIdName, statecode, StateCode_Description, statuscode, 
                         StatusCode_Description
FROM            CE.tblRics_SurveyRequest
