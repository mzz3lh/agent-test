CREATE   VIEW [FAS].[vwAccountToSkill]
AS
SELECT source.Id, 
	source.SinkCreatedOn, 
	source.SinkModifiedOn,
	source.accountid,
	skill.apuk_skillId,
	skill.apuk_name
FROM synapse_ce.apuk_account_apuk_skill as Source
  INNER JOIN synapse_ce.apuk_skill as skill 
	on skill.apuk_skillid = source.apuk_skillid
