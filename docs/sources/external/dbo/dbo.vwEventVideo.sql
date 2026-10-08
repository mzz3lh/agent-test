CREATE VIEW [dbo].[vwEventVideo]
AS

SELECT
	[Subs Owner ContactNo],
	[Subs Owner],
	[Subs User],
	[Subs User ContactNo],
	[SubscriptionUserID],
	[Company Name],
	[ItemName],
	[ViewTime],
	[ItemDate],
	[ItemType],
	[EventAttended],
	[EventNotAttended],
	[VideoView],
	[Venue],
	[Topic]
FROM [Ext].[PBI02_dbo_vwEventVideo]
