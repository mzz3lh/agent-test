CREATE TABLE [synapse_fo].[EXCHANGERATETYPE](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NAME] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CALENDARID] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
