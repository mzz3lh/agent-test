CREATE VIEW CE.vwContact_Candidate
AS
SELECT * FROM CE.vwContact -- was going to use [synapse_ce].[tblContact_BI] as in other vwContact_XXXX views but this view was still quite efficient
WHERE [Rics_MemberGrade] = 200000000
