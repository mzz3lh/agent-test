CREATE TABLE [synapse_fo].[OMTeamMembershipCriterion](
	[LastProcessedChange_DateTime] [datetime] NULL,
	[DataLakeModified_DateTime] [datetime] NULL,
	[ALLOWCONTACT] [int] NULL,
	[ALLOWCONTRACTOR] [int] NULL,
	[ALLOWCUSTOMER] [int] NULL,
	[ALLOWEMPLOYEE] [int] NULL,
	[ALLOWVENDOR] [int] NULL,
	[ISSYSTEMCRITERION] [int] NULL,
	[NAME] [nvarchar](60) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[REQUIRESAXUSER] [int] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[RECVERSION] [int] NULL,
	[MODIFIEDDATETIME] [datetime] NULL,
	[MODIFIEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CREATEDDATETIME] [datetime] NULL,
	[CREATEDBY] [nvarchar](20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
