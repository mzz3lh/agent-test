CREATE TABLE [synapse_fo].[EXCHANGERATECURRENCYPAIR](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[EXCHANGERATEDISPLAYFACTOR] [int] NULL,
	[EXCHANGERATETYPE] [bigint] NULL,
	[FROMCURRENCYCODE] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TOCURRENCYCODE] [nvarchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL
) ON [PRIMARY]
