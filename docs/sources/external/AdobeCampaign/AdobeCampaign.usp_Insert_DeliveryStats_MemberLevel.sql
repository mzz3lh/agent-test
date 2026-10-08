CREATE PROCEDURE [AdobeCampaign].[usp_Insert_DeliveryStats_MemberLevel]
AS
BEGIN
	
	DELETE FROM [AdobeCampaign].[tblCampaignDeliveryStats_MemberLevel]
	WHERE [FILE_ID] = (SELECT DISTINCT [File_ID] FROM [Work].[tblCampaignDeliveryStats_MemberLevel_Adobe])

	INSERT INTO [AdobeCampaign].[tblCampaignDeliveryStats_MemberLevel]
	(
		[File_Id],
		[Campaign_Label],
		[Campaign_ID],
		[Delivery_Label],
		[Delivery_ID],
		[DeliveryStats_Date],
		[First_Name],
		[Last_Name],
		[Member_Number],
		[Status],
		[Reason_Failure_Msg],
		[OpenOrClick],
		[Label],
		[Date_OpenOrClick]
	)
	SELECT
		[File_Id],
		[Campaign_Label],
		[Campaign_ID],
		[Delivery_Label],
		[Delivery_ID],
		[Date],
		[First_Name],
		[Last_Name],
		RIGHT('0000000' + [Member_Number], 7) AS [Member_Number],
		[Status],
		[Reason_Failure_Msg],
		[OpenOrClick],
		[Label],
		CASE WHEN YEAR([Date_OpenOrClick]) = 1753 THEN '1900-01-01' ELSE [Date_OpenOrClick] END
	FROM [Work].[tblCampaignDeliveryStats_MemberLevel_Adobe]

END
