CREATE   VIEW [AdobeCampaign].[vwCampaignDeliveryStats]
AS
SELECT 
	[File_Id],
	[CampaignId],
	[DeliveryId],
	[Campaign_Label],
	[Delivery_Label],
	[Processed_Or_Sent],
	[Delivered],
	[Recipients_Opened],
	[Total_Open_Count],
	[Unique_Clicks],
	[Total_Clicks],
	[Bounces_Errors],
	[Delivery_Rate]
FROM [AdobeCampaign].[tblCampaignDeliveryStats]
WHERE CampaignId IN ('CMP81', 'CMP86', 'CMP51', 'CMP141', 'CMP241', 'CMP394')
	OR DeliveryId IN ('DM00000','DM00000','DM00000','DM00000', 'DM00000', 'DM00000')
