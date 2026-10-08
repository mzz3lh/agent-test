CREATE TABLE [synapse_ce].[apuk_charge_caseinvestigation](
	[Id] [uniqueidentifier] NOT NULL,
	[SinkCreatedOn] [datetime] NULL,
	[SinkModifiedOn] [datetime] NULL,
	[versionnumber] [bigint] NULL,
	[apuk_charge_caseinvestigationid] [uniqueidentifier] NOT NULL,
	[apuk_caseinvestigationid] [uniqueidentifier] NOT NULL,
	[apuk_chargeid] [uniqueidentifier] NOT NULL
) ON [PRIMARY]
