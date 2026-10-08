CREATE   VIEW [synapse_ce].[vwapuk_memberbenefitactivation]
AS
SELECT 
	mem.[apuk_memberbenefitactivationid],
	mem.[apuk_name],
	mem.[createdon],
	mem.[createdby],
	mem.[modifiedon],
	mem.[modifiedby],
	mem.[ownerid],
	mem.[owningteam],
	mem.[owninguser],
	mem.[apuk_ricsrecordid],
	mem.[owningbusinessunit],
	mem.[apuk_suspendedby],
	mem.[createdonbehalfby],
	mem.[modifiedonbehalfby],
	mem.[apuk_suspensionreason],
	mem.[apuk_campaignyear],
	mem.[statecode],
	mem.[statuscode]
FROM synapse_ce.apuk_memberbenefitactivation mem
