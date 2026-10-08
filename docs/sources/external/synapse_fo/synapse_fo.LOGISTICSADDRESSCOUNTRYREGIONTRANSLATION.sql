CREATE TABLE [synapse_fo].[LOGISTICSADDRESSCOUNTRYREGIONTRANSLATION](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[COUNTRYREGIONID] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LANGUAGEID] [nvarchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LONGNAME] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SHORTNAME] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
