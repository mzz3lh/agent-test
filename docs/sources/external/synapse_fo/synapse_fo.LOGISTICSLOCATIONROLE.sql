CREATE TABLE [synapse_fo].[LOGISTICSLOCATIONROLE](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ISCONTACTINFO] [int] NULL,
	[ISPOSTALADDRESS] [int] NULL,
	[NAME] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TYPE] [int] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[DISABLEADDOREDITINEMPLOYEESELFSERVICE] [int] NULL
) ON [PRIMARY]
