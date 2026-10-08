CREATE TABLE [synapse_ce].[StatusMetadata](
	[EntityName] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[State] [int] NOT NULL,
	[Status] [int] NOT NULL,
	[IsUserLocalizedLabel] [bit] NULL,
	[LocalizedLabelLanguageCode] [int] NULL,
	[LocalizedLabel] [nvarchar](350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
