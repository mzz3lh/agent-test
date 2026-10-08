CREATE TABLE [synapse_ce].[teammembership](
	[Id] [uniqueidentifier] NOT NULL,
	[SinkCreatedOn] [datetime] NULL,
	[SinkModifiedOn] [datetime] NULL,
	[versionnumber] [bigint] NULL,
	[teammembershipid] [uniqueidentifier] NULL,
	[teamid] [uniqueidentifier] NULL,
	[systemuserid] [uniqueidentifier] NULL
) ON [PRIMARY]
