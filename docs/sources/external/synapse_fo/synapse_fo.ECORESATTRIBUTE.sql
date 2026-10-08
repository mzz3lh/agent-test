CREATE TABLE [synapse_fo].[ECORESATTRIBUTE](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ATTRIBUTEMODIFIER] [int] NULL,
	[ATTRIBUTETYPE] [bigint] NULL,
	[NAME] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[ENGCHGATTRIBUTEMAX] [numeric](32, 6) NULL,
	[ENGCHGATTRIBUTEMIN] [numeric](32, 6) NULL,
	[ENGCHGATTRIBUTEMULTIPLE] [numeric](32, 6) NULL,
	[ENGCHGATTRIBUTETOLERANCEACTION] [int] NULL
) ON [PRIMARY]
