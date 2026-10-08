CREATE TABLE [synapse_fo].[REASONTABLEREF](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[REASON] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REASONCOMMENT] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
