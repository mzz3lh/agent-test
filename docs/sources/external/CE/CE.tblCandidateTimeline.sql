CREATE TABLE [CE].[tblCandidateTimeline](
	[EnrolmentID] [uniqueidentifier] NOT NULL,
	[ContactID] [uniqueidentifier] NULL,
	[ContactNo] [varchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Milestone] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[MilestoneDate] [date] NULL,
	[MilestoneType] [nchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
