CREATE TABLE [synapse_fo].[DIMENSIONHIERARCHYINTEGRATION](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ISDEFAULT] [int] NULL,
	[DISPLAYSTRING] [nvarchar](680) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DIMENSIONHIERARCHY] [bigint] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
