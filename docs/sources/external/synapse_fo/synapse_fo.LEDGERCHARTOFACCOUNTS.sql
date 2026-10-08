CREATE TABLE [synapse_fo].[LEDGERCHARTOFACCOUNTS](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[DESCRIPTION] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MAINACCOUNTFORMATMASK] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NAME] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATEDDATETIME] [datetime] NULL,
	[CREATEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
