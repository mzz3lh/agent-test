CREATE TABLE [synapse_fo].[VENDINFOZAKAT_SA](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[FILENUMBER] [nvarchar](15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ISSUBCONTRACTOR] [int] NULL,
	[REGISTRATIONNUM] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SERVICETYPE] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VENDACCOUNT] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
