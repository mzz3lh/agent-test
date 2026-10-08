CREATE    VIEW [CE].[vwConcessionGroup]
AS

WITH cteGroups AS
(
	SELECT tab.ConcessionTypeName, tab.ConcessionGroup
	FROM (VALUES
	('Australian Institute of Building Surveyors (AIBS)', 'Dual Concessions'),
	('Australian Institute of Quantity Surveyors', 'Dual Concessions'),
	('Australian Property Institute', 'Dual Concessions'),
	('Exceptional Hardship', 'Dual Concessions'),
	('Fellow RICS Fellow CICES', 'Dual Concessions'),
	('Hong Kong Institute of Housing', 'Dual Concessions'),
	('Hong Kong Institute of Surveyors', 'Dual Concessions'),
	('Hypzert', 'Dual Concessions'),
	('India SBE Graduate', 'Dual Concessions'),
	('Institute of Surveyors of Australia', 'Dual Concessions'),
	('Institute of Surveyors of Malaysia', 'Dual Concessions'),
	('Level 1 / Level 2 Building Surveyors (Australia)', 'Dual Concessions'),
	('Member RICS Member CICES', 'Dual Concessions'),
	('New Zealand Institute of Quantity Surveyors', 'Dual Concessions'),
	('New Zealand Institute of Surveyors', 'Dual Concessions'),
	('New Zealand Real Estate Agents Authority', 'Dual Concessions'),
	('Property Institute of New Zealand', 'Dual Concessions'),
	('RICS Fellow CICES Member', 'Dual Concessions'),
	('RICS Member CICES Fellow', 'Dual Concessions'),
	('SCSI 20% Outside of Eire only', 'Dual Concessions'),
	('SCSI 50% Dual Member in Eire only', 'Dual Concessions'),
	('Singapore Institute of Surveyors & Valuers', 'Dual Concessions'),
	('South African Council for the Property Valuers Profession', 'Dual Concessions'),
	('South African Council for the Quantity Surveying Profession', 'Dual Concessions'),
	('The Hong Kong Institution of Engineering Surveyors', 'Dual Concessions'),
	('Valuers Registration Board of New Zealand', 'Dual Concessions'),
	('Brazil Professional Fee Discount', 'Dual Concessions'),
	('Academic', 'Other'),
	('Family Raising', 'Other'),
	('Ill Health', 'Other'),
	('Maternity or Adoption', 'Other'),
	('Non-Practising (50%)', 'Other'),
	('Ukraine Professional', 'Other'),
	('Unemployed', 'Other'),
	('Unemployed (COVID-19)', 'Other'),
	('Working Part Time', 'Other'),
	('Working Part Time (COVID-19)', 'Other'),
	('Apprenticeship', 'Other - Contractual'),
	('Associate First Year', 'Other - Contractual'),
	('Eminent', 'Other - Contractual'),
	('Life Member', 'Other - Contractual'),
	('Member by Invitation', 'Other - Contractual'),
	('Past President', 'Other - Contractual'),
	('Sandwich Student', 'Other - Contractual'),
	('Staff Member', 'Other - Contractual'),
	('PWR1', 'Retired Concessions'),
	('PWR2', 'Retired Concessions'),
	('PWR3', 'Retired Concessions'),
	('Retired', 'Retired Concessions'),
	('Retired (Freelist)', 'Retired Concessions'),
	('Retired Special Rate', 'Retired Concessions')
	) tab (ConcessionTypeName, ConcessionGroup)
)
SELECT 
	 CONCT.[apuk_concessiontypeid]
	,ccg.[ConcessionGroup]
	,CONCT.statecode
	,CONCT.apuk_name
	FROM synapse_ce.apuk_concessiontype CONCT
	LEFT JOIN cteGroups ccg
		ON ccg.ConcessionTypeName = CONCT.apuk_name
