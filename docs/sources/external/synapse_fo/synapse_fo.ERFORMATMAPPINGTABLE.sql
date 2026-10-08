CREATE TABLE [synapse_fo].[ERFORMATMAPPINGTABLE](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[BASE] [bigint] NULL,
	[FORMAT] [bigint] NULL,
	[GUID] [uniqueidentifier] NULL,
	[NAME] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PUBLICOBJECTREFERENCES] [bigint] NULL,
	[ISDEFAULT] [int] NULL,
	[SOLUTION] [bigint] NULL,
	[PRIORBASE] [bigint] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
