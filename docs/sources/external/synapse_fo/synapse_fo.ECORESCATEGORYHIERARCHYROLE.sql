CREATE TABLE [synapse_fo].[ECORESCATEGORYHIERARCHYROLE](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[CATEGORYHIERARCHY] [bigint] NULL,
	[NAMEDCATEGORYHIERARCHYROLE] [int] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
