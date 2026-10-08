CREATE TABLE [CE].[tblCandidateCompetency](
	[CandidateCompetencyID] [uniqueidentifier] NULL,
	[EnrolmentID] [uniqueidentifier] NULL,
	[CompetencyID] [uniqueidentifier] NULL,
	[CompetencyName] [nvarchar](128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StateCode] [int] NULL,
	[StateCodeDescription] [nvarchar](350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[StatusCode] [int] NULL,
	[StatusCodeDescription] [nvarchar](350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CompetencyLevel] [int] NULL,
	[LevelDescription] [nvarchar](350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CompetencyStatus] [int] NULL,
	[CompetencyStatusDescription] [varchar](11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[createdon] [datetime] NULL,
	[modifiedon] [datetime] NULL,
	[Selected] [varchar](3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
