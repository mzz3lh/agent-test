CREATE VIEW [dbo].[vwrics_otherprofessionalbody]
AS

SELECT 
	oth.[Rics_otherprofessionalbodyId],
	oth.[Rics_Code],
	oth.[Rics_name],
	oth.[Created_On],
	oth.[CreatedBy],
	oth.[CreatedByName],
	oth.[Modified_On],
	oth.[ModifiedBy],
	oth.[ModifiedByName],
	oth.[OwnerId],
	oth.[OwnerIdName],
	oth.[OwningUser],
	oth.[statecode],
	oth.[StateCode_Description],
	oth.[statuscode],
	oth.[StatusCode_Description]
FROM [Ext].[PBI02_CRM_vwrics_otherprofessionalbody] oth
