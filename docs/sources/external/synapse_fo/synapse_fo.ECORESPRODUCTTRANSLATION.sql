CREATE TABLE [synapse_fo].[ECORESPRODUCTTRANSLATION](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[DESCRIPTION] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LANGUAGEID] [nvarchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NAME] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PRODUCT] [bigint] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
