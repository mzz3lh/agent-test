CREATE TABLE [synapse_fo].[CONFIRMINGPO](
	[FileName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SysRowId] [bigint] NULL,
	[LSN] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[CONFIRMINGPOID] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LANGUAGEID] [nvarchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
