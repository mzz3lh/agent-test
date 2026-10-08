CREATE TABLE [synapse_fo].[ECORESCATEGORYTRANSLATION](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[CATEGORY] [bigint] NULL,
	[DESCRIPTION] [nvarchar](1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[FRIENDLYNAME] [nvarchar](254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LANGUAGEID] [nvarchar](7) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SEARCHTEXT] [nvarchar](254) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATEDDATETIME] [datetime] NULL,
	[CREATEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
