CREATE TABLE [CE].[tblFAMCharteredDesignationExclusions](
	[CDKey] [varchar](80) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Status] [nvarchar](350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Route] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Election Date] [date] NULL,
	[End Date] [date] NULL,
	[Contact No] [nvarchar](100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ContactId] [uniqueidentifier] NULL,
	[CharteredDesignationID] [uniqueidentifier] NULL,
	[apuk_credentialrecordid] [uniqueidentifier] NULL
) ON [PRIMARY]
