CREATE TABLE [synapse_fo].[CUSTWRITEOFFFINANCIALREASONSSETUP](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[COMPANY] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REASON] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ISDEFAULT] [int] NULL,
	[WRITEOFFLEDGERDIMENSION] [bigint] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
