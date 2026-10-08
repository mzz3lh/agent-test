CREATE TABLE [synapse_fo].[SubBillDeferralScheduleTableImport](
	[$FileName] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[_SysRowId] [bigint] NULL,
	[LSN] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[RECID] [bigint] NOT NULL,
	[SubBillDeferralScheduleNumber] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CustAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[VendAccount] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ItemId] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SubBillDeferralOriginalTransactionRef] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SubBillBillingScheduleNumber] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DataAreaId] [nvarchar](4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECVERSION] [int] NULL
) ON [PRIMARY]
