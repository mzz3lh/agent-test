CREATE TABLE [synapse_fo].[CUSTDEFAULTLOCATION](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ACCOUNTNUM] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTYLOCATIONROLE] [bigint] NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
