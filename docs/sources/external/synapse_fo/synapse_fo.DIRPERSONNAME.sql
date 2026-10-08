CREATE TABLE [synapse_fo].[DIRPERSONNAME](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[FIRSTNAME] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LASTNAMEPREFIX] [nvarchar](25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LASTNAME] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MIDDLENAME] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PERSON] [bigint] NULL,
	[VALIDFROM] [datetime] NULL,
	[VALIDTO] [datetime] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
