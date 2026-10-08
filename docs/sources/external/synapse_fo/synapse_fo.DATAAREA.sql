CREATE TABLE [synapse_fo].[DATAAREA](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[NAME] [nvarchar](81) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ISVIRTUAL] [int] NULL,
	[ALWAYSNATIVE] [int] NULL,
	[TIMEZONE] [int] NULL,
	[RECVERSION] [int] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[fno_id] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
