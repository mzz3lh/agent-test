CREATE VIEW [DQ].[vwDataMap]
AS 

/*=============================================
	Author:			srini.akula
	Create date:	05.01.2022
	Description:	Returns data map
					
===============================================================================*/

	SELECT 
	 [DataMapId]
	,[L1] AS 'Domain'
	,[L2] AS 'Sub-Domain'
	,[L1_L2_Lookup]
	,[DataOwner] AS 'Data Owner'
	,[DataSteward] AS 'Data Steward'
	,[DOInitials] AS 'Data Owner Initials'
	FROM [DQ].[DataMap]
