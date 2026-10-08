CREATE TABLE [synapse_ce].[GlobalOptionSetMetadata](
	[OptionSetName] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
	[Option] [int] NOT NULL,
	[IsUserLocalizedLabel] [bit] NULL,
	[LocalizedLabelLanguageCode] [int] NULL,
	[LocalizedLabel] [nvarchar](350) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[GlobalOptionSetName] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[EntityName] [nvarchar](64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
