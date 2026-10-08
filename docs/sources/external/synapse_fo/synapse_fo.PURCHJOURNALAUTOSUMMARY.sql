CREATE TABLE [synapse_fo].[PURCHJOURNALAUTOSUMMARY](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[AUTOSUMMARY] [int] NULL,
	[DOCUMENTSTATUS] [int] NOT NULL,
	[MODULETYPE] [int] NOT NULL,
	[PURCHID] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VENDACCOUNT] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
