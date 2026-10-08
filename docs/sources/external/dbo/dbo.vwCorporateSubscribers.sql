CREATE VIEW [dbo].[vwCorporateSubscribers]
AS
SELECT 
	[Owner First Name],
	[Owner Last Name],
	[Company Name],
	[Owner Email Address],
	[Owner ContactID],
	[Owner ContactNo],
	[User FirstName],
	[User LastName],
	[User ContactNo],
	[Rics_TradingName],
	[Rics_OfficeNumber],
	[Rics_FirmNumber],
	[ricsv2_subscriptionid],
	[Subscription No],
	[ricsv2_subscriptionuserid],
	[ricsv1_SalesOrderId],
	[subscriptionownerId],
	[Hash],
	[VideoView],
	[SubscriptionStatus],
	[SubscriptionOwnerNo],
	[SubscriptionOwnerStartDate],
	[Subscription Package]
FROM [Ext].[PBI02_CRM_vwCorporateSubscribers]
