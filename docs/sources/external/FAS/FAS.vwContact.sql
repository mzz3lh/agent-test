CREATE    VIEW [FAS].[vwContact]
AS
SELECT origin.Id,
    origin.SinkCreatedOn,
	origin.SinkModifiedOn,
	origin.StateCode,
	origin.StatusCode,
	origin.fullname,
	origin.firstname + ' ' + origin.lastname AS localname,
	origin.firstname,
	origin.lastname,
	origin.apuk_contactnumber,
	origin.apuk_ricsrecordid,
	rr.apuk_ricsmembershipnumber,
	rr.SinkModifiedOn AS RicsRecord_SinkModifiedOn,
	mstatus.localizedlabel AS MembershipStatus,
	mgrade.localizedlabel AS Membergrade,
	mdesig.localizedlabel AS Designation,
	origin.apuk_localname AS PreferredName
FROM synapse_ce.contact as origin
	LEFT OUTER JOIN synapse_ce.apuk_ricsrecord rr 
		ON rr.id = origin.apuk_ricsrecordid
	LEFT OUTER JOIN synapse_ce.GlobalOptionSetMetadata as mgrade 
		ON mgrade.optionsetname ='apuk_membergrade' 
		AND mgrade.[option] = rr.apuk_membergrade
		AND mgrade.[EntityName] = 'apuk_ricsrecord'
	LEFT OUTER JOIN synapse_ce.GlobalOptionSetMetadata as mstatus 
		ON mstatus.optionsetname ='apuk_membershipstatus' 
		AND mstatus.[option] = rr.apuk_membershipstatus
		AND mstatus.[EntityName] = 'apuk_ricsrecord'
	LEFT OUTER JOIN synapse_ce.GlobalOptionSetMetadata as mdesig 
		ON mdesig.optionsetname ='apuk_designation' 
		AND mdesig.[option] = rr.apuk_designation
		AND mdesig.[EntityName] = 'apuk_ricsrecord'
	WHERE NOT EXISTS (
		SELECT ContactID
		FROM CE.tblContact_Test_Records tst
		WHERE origin.contactid = tst.contactid
		)
