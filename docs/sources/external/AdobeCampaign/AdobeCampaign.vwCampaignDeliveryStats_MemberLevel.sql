CREATE VIEW [AdobeCampaign].[vwCampaignDeliveryStats_MemberLevel]
AS
SELECT 
	camp.[DeliveryStatsId],
	camp.[File_Id],
	camp.[Campaign_Label],
	camp.[Campaign_ID],
	camp.[Delivery_Label],
	camp.[Delivery_ID],
	camp.[DeliveryStats_Date],
	camp.[First_Name],
	camp.[Last_Name],
	cnt.[ContactId],
	--camp.[Member_Number],
	camp.[Status],
	camp.[Reason_Failure_Msg],
	camp.[OpenOrClick],
	camp.[Label],
	camp.[Date_OpenOrClick]
FROM [AdobeCampaign].[tblCampaignDeliveryStats_MemberLevel] camp
	LEFT JOIN [dbo].[vwContact] cnt
		ON camp.[Member_Number] = cnt.[Rics_contactno]
