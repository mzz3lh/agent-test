CREATE TABLE [CE].[tblAccount_KeyAccounts](
	[AccountId] [uniqueidentifier] NOT NULL,
	[KeyAccount] [bit] NULL,
	[KeyAccountManager] [nvarchar](150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
