CREATE TABLE [synapse_fo].[ECORESTRACKINGDIMENSIONGROUPITEM](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ITEMDATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ITEMID] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TRACKINGDIMENSIONGROUP] [bigint] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
