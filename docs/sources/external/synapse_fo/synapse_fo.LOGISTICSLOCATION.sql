CREATE TABLE [synapse_fo].[LOGISTICSLOCATION](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DUNSNUMBERRECID] [bigint] NULL,
	[ISPOSTALADDRESS] [int] NULL,
	[LOCATIONID] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARENTLOCATION] [bigint] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATEDDATETIME] [datetime] NULL
) ON [PRIMARY]
