CREATE TABLE [synapse_fo].[TAXGSTRELIEFCATEGORY_MY](
	[FileName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SysRowId] [bigint] NULL,
	[LSN] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[RELIEFCATEGORYID] [nvarchar](30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RELIEFITEMNUMBER] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RELIEFSCHEDULE] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[RELIEFCATEGORYENTITYKEY] [uniqueidentifier] NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
