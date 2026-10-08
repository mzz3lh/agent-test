CREATE TABLE [synapse_fo].[TAXTABLE](
	[recid] [bigint] NOT NULL,
	[SinkCreatedOn] [datetime] NULL,
	[SinkModifiedOn] [datetime] NULL,
	[taxcode] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[printcode] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[taxcurrencycode] [nvarchar](12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[taxaccountgroup] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[taxname] [nvarchar](120) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[taxperiod] [nvarchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[dataareaid] [nvarchar](16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
