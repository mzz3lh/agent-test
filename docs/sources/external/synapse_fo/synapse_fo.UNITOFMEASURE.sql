CREATE TABLE [synapse_fo].[UNITOFMEASURE](
	[LastProcessedChange_DateTime] [datetime] NOT NULL,
	[DataLakeModified_DateTime] [datetime] NOT NULL,
	[RECID] [bigint] NOT NULL,
	[DecimalPrecision] [int] NULL,
	[Symbol] [nvarchar](10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[SystemOfUnits] [int] NULL,
	[UnitOfMeasureClass] [int] NULL,
	[PARTITION] [bigint] NOT NULL,
	[RECVERSION] [int] NOT NULL,
	[MODIFIEDDATETIME] [datetime] NULL
) ON [PRIMARY]
