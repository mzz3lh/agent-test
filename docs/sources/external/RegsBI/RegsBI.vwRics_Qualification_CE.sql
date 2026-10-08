CREATE   VIEW [RegsBI].[vwRics_Qualification_CE]
AS 
SELECT 
	[Rics_QualificationId],
	[Rics_ContactId],
	[Created_On],
	[createdby],
	[CreatedByName],
	[Modified_On],
	[modifiedby],
	[ModifiedByName],
	[OrganizationId],
	[Rics_Comments],
	[Rics_StartDate],
	[Rics_EndDate],
	[Rics_Name],
	[Rics_Result],
	[statecode],
	[StateCode_Description],
	[statuscode],
	[StatusCode_Description],
	[Rics_CourseId], --apuk_ricsaccreditedcourse
	[Rics_CourseIdName], --apuk_ricsaccreditedcourseName
	[Rics_OtherCourse],
	[Rics_OtherDeliveryMethod],
	[Rics_OtherInstitution],
	[Rics_OtherQualification]
FROM [synapse_ce].[vwrics_qualification]
