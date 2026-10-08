CREATE TABLE [CE].[cpdactivity_jsonoutput_Maybetech](
	[_RowIndex] [bigint] NULL,
	[CPDActivityId] [uniqueidentifier] NULL,
	[ActivityDescription] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[DateCompleted] [datetime] NULL,
	[ActivityType] [bigint] NULL,
	[Ethics] [bit] NULL,
	[Membergrade] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Designation] [nvarchar](50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Pathway] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OutcomeText] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Pass] [bit] NULL,
	[FailedField] [nvarchar](255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Recommendation] [nvarchar](4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[NumberOfHours] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
