CREATE TABLE [synapse_fo].[VEND1099OIDDETAIL](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[CUSIP] [int] NULL,
	[CUSIPDETAILS] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CUSIPID] [nvarchar](9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[INVESTORTYPE] [int] NULL,
	[NOMINEEDETAILS] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VENDTABLE] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DATAAREAID] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
