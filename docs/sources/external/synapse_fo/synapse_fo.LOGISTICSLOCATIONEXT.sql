CREATE TABLE [synapse_fo].[LOGISTICSLOCATIONEXT](
	[FileName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SysRowId] [bigint] NULL,
	[LSN] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[CNPJCPFNUM_BR] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[IENUM_BR] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LOCATION] [bigint] NULL,
	[SALESCALENDARID] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TAXGROUP] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TAXGSTEPZCODE_IN] [int] NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
