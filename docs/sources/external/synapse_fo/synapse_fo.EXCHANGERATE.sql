CREATE TABLE [synapse_fo].[EXCHANGERATE](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[EXCHANGERATE] [numeric](32, 16) NULL,
	[EXCHANGERATECURRENCYPAIR] [bigint] NULL,
	[VALIDFROM] [datetime] NULL,
	[VALIDTO] [datetime] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATEDDATETIME] [datetime] NULL,
	[CREATEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
