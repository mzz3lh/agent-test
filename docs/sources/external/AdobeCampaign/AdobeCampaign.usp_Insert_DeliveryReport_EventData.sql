CREATE PROCEDURE [AdobeCampaign].[usp_Insert_DeliveryReport_EventData]
AS
BEGIN
	
	DELETE FROM [AdobeCampaign].[tblCampaignDeliveryReportEventData]
	WHERE [FILE_ID] = (SELECT DISTINCT [File_ID] FROM [Work].[tblCampaignDeliveryReportEventData_Adobe])

	INSERT INTO [AdobeCampaign].[tblCampaignDeliveryReportEventData]
	(
		[File_Id],
		[Email],
		[Label],
		[Event_Date],
		[Reason],
		[Status],
		[Event_Type],
		[First_Name],
		[Last_Name]
	)
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
	FROM [Work].[tblCampaignDeliveryReportEventData_Adobe]

END
