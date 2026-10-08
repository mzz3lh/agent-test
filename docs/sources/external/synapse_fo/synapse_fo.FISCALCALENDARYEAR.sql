CREATE TABLE [synapse_fo].[FISCALCALENDARYEAR](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ENDDATE] [datetime] NULL,
	[FISCALCALENDAR] [bigint] NULL,
	[NAME] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[STARTDATE] [datetime] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
