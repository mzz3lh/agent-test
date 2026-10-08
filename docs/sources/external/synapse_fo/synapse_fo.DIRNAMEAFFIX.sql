CREATE TABLE [synapse_fo].[DIRNAMEAFFIX](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[AFFIX] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[AFFIXTYPE] [int] NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
