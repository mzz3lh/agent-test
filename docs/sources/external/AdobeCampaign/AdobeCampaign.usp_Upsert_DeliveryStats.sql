CREATE PROCEDURE [AdobeCampaign].[usp_Upsert_DeliveryStats]
AS
BEGIN
	
	MERGE [AdobeCampaign].[tblCampaignDeliveryStats] tgt
		USING [Work].[tblCampaignDeliveryStats_Adobe] src
			ON tgt.[CampaignId] = src.[CampaignId]
				AND tgt.[DeliveryId] = src.[DeliveryId]
	WHEN MATCHED THEN UPDATE SET
		tgt.[Campaign_Label] = src.[Campaign_Label],
		tgt.[Delivery_Label] = src.[Delivery_Label],
		tgt.[Processed_Or_Sent] = src.[Processed_Or_Sent],
		tgt.[Delivered] = src.[Delivered],
		tgt.[Recipients_Opened] = src.[Recipients_Opened],
		tgt.[Total_Open_Count] = src.[Total_Open_Count],
		tgt.[Unique_Clicks] = src.[Unique_Clicks],
		tgt.[Total_Clicks] = src.[Total_Clicks],
		tgt.[Bounces_Errors] = src.[Bounces_Errors],
		tgt.[Delivery_Rate] = src.[Delivery_Rate],
		tgt.[Campaign_Date] = src.[Campaign_Date]
	WHEN NOT MATCHED BY TARGET THEN INSERT
	(
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
		[Delivery_Rate],
		[Campaign_Date]
	)
	VALUES
	(
		src.[File_Id],
		src.[CampaignId],
		src.[DeliveryId],
		src.[Campaign_Label],
		src.[Delivery_Label],
		src.[Processed_Or_Sent],
		src.[Delivered],
		src.[Recipients_Opened],
		src.[Total_Open_Count],
		src.[Unique_Clicks],
		src.[Total_Clicks],
		src.[Bounces_Errors],
		src.[Delivery_Rate],
		src.[Campaign_Date]
	);

END
