CREATE VIEW [AdobeCampaign].[vwCampaignDeliveryReportEventData]
AS
SELECT
	[File_Id],
	[Email],
	[Label],
	[Event_Date],
	[Reason],
	[Status],
	[Event_Type],
	[First_Name],
	[Last_Name]
FROM [AdobeCampaign].[tblCampaignDeliveryReportEventData]
