CREATE TABLE [CE].[tblCandidateEngagementCPDSummary](
	[Contact ID] [uniqueidentifier] NULL,
	[Contact No] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[TotalHrs] [decimal](38, 2) NULL,
	[ExpectedTotalHrs] [numeric](21, 2) NULL,
	[FormalHrs] [decimal](38, 2) NULL,
	[ExpectedFormalHrs] [numeric](21, 2) NULL,
	[InformalHrs] [decimal](38, 2) NULL,
	[ProRata] [numeric](10, 2) NULL,
	[PctFormal] [decimal](10, 2) NULL,
	[ExpectedPctFormalHrs] [numeric](36, 13) NULL,
	[ScorePF] [int] NULL,
	[StatusPF] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ScoreTH] [int] NULL,
	[StatusTH] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DiaryDays] [decimal](38, 1) NOT NULL,
	[ScoreDD] [int] NULL,
	[StatusDD] [varchar](5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
