CREATE TABLE [synapse_fo].[WHSFILTERPARM](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ITEMGROUPID] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
