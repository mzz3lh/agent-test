CREATE TABLE [synapse_fo].[TAX1099FIELDS](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[DESCRIPTION] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TAX1099AMOUNT] [numeric](32, 6) NULL,
	[TAX1099BOX] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TAX1099FIELDNUM] [int] NULL,
	[TAX1099FORM] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TAX1099TYPE] [int] NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
