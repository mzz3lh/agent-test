CREATE TABLE [synapse_fo].[DIMENSIONHIERARCHYLEVEL](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[DIMENSIONATTRIBUTE] [bigint] NULL,
	[DIMENSIONHIERARCHY] [bigint] NULL,
	[TEMPORARYDIMENSIONHIERARCHYLEVEL] [bigint] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATEDDATETIME] [datetime] NULL,
	[CREATEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
