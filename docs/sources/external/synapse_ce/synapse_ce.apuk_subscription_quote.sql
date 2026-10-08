CREATE TABLE [synapse_ce].[apuk_subscription_quote](
	[Id] [uniqueidentifier] NOT NULL,
	[SinkCreatedOn] [datetime] NULL,
	[SinkModifiedOn] [datetime] NULL,
	[apuk_subscriptionid] [uniqueidentifier] NULL,
	[versionnumber] [bigint] NULL,
	[quoteid] [uniqueidentifier] NULL,
	[apuk_subscription_quoteid] [uniqueidentifier] NULL
) ON [PRIMARY]
