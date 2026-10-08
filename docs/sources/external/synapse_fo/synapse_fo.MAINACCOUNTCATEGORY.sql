CREATE TABLE [synapse_fo].[MAINACCOUNTCATEGORY](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ACCOUNTCATEGORY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ACCOUNTCATEGORYREF] [int] NULL,
	[ACCOUNTCATEGORYDISPLAYORDER] [int] NULL,
	[ACCOUNTTYPE] [int] NULL,
	[CLOSED] [int] NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
