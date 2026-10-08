CREATE TABLE [synapse_fo].[FISCALCALENDARPERIOD](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ENDDATE] [datetime] NULL,
	[FISCALCALENDAR] [bigint] NULL,
	[FISCALCALENDARYEAR] [bigint] NULL,
	[MONTH] [int] NULL,
	[NAME] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[QUARTER] [int] NULL,
	[SHORTNAME] [nvarchar](8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[STARTDATE] [datetime] NULL,
	[TYPE] [int] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
