CREATE TABLE [synapse_fo].[PURCHLINEFOREIGNTRADECATEGORY](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ISDELETED] [int] NULL,
	[ISMODIFIED] [int] NULL,
	[NGPCODESTABLE_FR] [bigint] NULL,
	[PURCHLINEDATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PURCHLINEINVENTTRANSID] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[UNITWEIGHT] [numeric](32, 12) NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[CREATEDDATETIME] [datetime] NULL
) ON [PRIMARY]
