CREATE TABLE [synapse_fo].[SHAREDCATEGORY](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[CATEGORYID] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CATEGORYNAME] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
