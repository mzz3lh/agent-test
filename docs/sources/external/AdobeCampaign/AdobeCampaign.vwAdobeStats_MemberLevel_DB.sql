CREATE   VIEW [AdobeCampaign].[vwAdobeStats_MemberLevel_DB]
AS
SELECT 
	m.[Delivery_ID],
	m.[Delivery_Label],
	m.Member_Number,
	m.OpenOrClick,
	m.Date_OpenOrClick,
	m.DeliveryStats_Date,
	ISNULL(m.[OpenOrClick], '') + ' email from ' + ISNULL(m.[Delivery_Label], '') + ' on ' + CONVERT(NVARCHAR(10), m.[Date_OpenOrClick], 103) AS [BISentence]
FROM AdobeCampaign.tblCampaignDeliveryStats_MemberLevel m
WHERE ISNUMERIC(m.member_number) = 1
