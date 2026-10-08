CREATE    PROCEDURE [Audit_Log].[usp_Insert_VENDBANKACCOUNT_Audit_FO]
AS
BEGIN

	-- Insert new accounts into the audit
		INSERT INTO [Audit_Log].[VENDBANKACCOUNT_FO]
	(
		[SinkCreatedOn],
		[SinkModifiedOn],
		[bankaccounttype],
		[bankcodetype],
		[lvdefaultbank],
		[transtype_jp],
		[reviewed],
		[bankinformationorigin],
		[workflowstate],
		[versioningstate],
		[sks_eft_acctstatus],
		[sks_eft_prenotestatus],
		[workflowtype],
		[sysdatastatecode],
		[accountid],
		[accountnum],
		[activedate],
		[bankaccountnamekana_jp],
		[bankcin],
		[bankconstantsymbol],
		[bankcontractaccount],
		[bankgroupid],
		[bankiban],
		[cellularphone],
		[contactperson],
		[corraccount_w],
		[correspbank_ee],
		[currencycode],
		[dirdunsnumber],
		[email],
		[exchrate],
		[exchrateref],
		[expirydate],
		[foreignaccount_ru],
		[foreignbank_ru],
		[foreignswift_ru],
		[intermaccount_ee],
		[intermbank_ee],
		[intermbankaccountid],
		[location],
		[logisticslocation],
		[msgtobank],
		[name],
		[pager],
		[phone],
		[phonelocal],
		[registrationnum],
		[sms],
		[specificsymbol],
		[swiftno],
		[telefax],
		[telex],
		[url],
		[vendaccount],
		[vendduns4number],
		[vendpaymenttextcode],
		[ficreditorid_dk],
		[correspondentbankaccount_lt],
		[correspondentbankaddress_lt],
		[correspondentbankname_lt],
		[correspondentbankswift_lt],
		[intermediatebankaccount_lt],
		[intermediatebankaddress_lt],
		[intermediatebankname_lt],
		[intermediatebankswift_lt],
		[comments],
		[qriban_ch],
		[specparameters_ch],
		[modifieddatetime],
		[modifiedby],
		[modifiedtransactionid],
		[createddatetime],
		[createdby],
		[createdtransactionid],
		[dataareaid],
		[recversion],
		[partition],
		[sysrowversion],
		[recid],
		[tableid],
		[versionnumber],
		[createdon],
		[modifiedon],
		[IsDelete],
		[PartitionId],
		[Audit_Date]
	)
	SELECT 
		src.[SinkCreatedOn],
		src.[SinkModifiedOn],
		src.[bankaccounttype],
		src.[bankcodetype],
		src.[lvdefaultbank],
		src.[transtype_jp],
		src.[reviewed],
		src.[bankinformationorigin],
		src.[workflowstate],
		src.[versioningstate],
		src.[sks_eft_acctstatus],
		src.[sks_eft_prenotestatus],
		src.[workflowtype],
		src.[sysdatastatecode],
		src.[accountid],
		src.[accountnum],
		src.[activedate],
		src.[bankaccountnamekana_jp],
		src.[bankcin],
		src.[bankconstantsymbol],
		src.[bankcontractaccount],
		src.[bankgroupid],
		src.[bankiban],
		src.[cellularphone],
		src.[contactperson],
		src.[corraccount_w],
		src.[correspbank_ee],
		src.[currencycode],
		src.[dirdunsnumber],
		src.[email],
		src.[exchrate],
		src.[exchrateref],
		src.[expirydate],
		src.[foreignaccount_ru],
		src.[foreignbank_ru],
		src.[foreignswift_ru],
		src.[intermaccount_ee],
		src.[intermbank_ee],
		src.[intermbankaccountid],
		src.[location],
		src.[logisticslocation],
		src.[msgtobank],
		src.[name],
		src.[pager],
		src.[phone],
		src.[phonelocal],
		src.[registrationnum],
		src.[sms],
		src.[specificsymbol],
		src.[swiftno],
		src.[telefax],
		src.[telex],
		src.[url],
		src.[vendaccount],
		src.[vendduns4number],
		src.[vendpaymenttextcode],
		src.[ficreditorid_dk],
		src.[correspondentbankaccount_lt],
		src.[correspondentbankaddress_lt],
		src.[correspondentbankname_lt],
		src.[correspondentbankswift_lt],
		src.[intermediatebankaccount_lt],
		src.[intermediatebankaddress_lt],
		src.[intermediatebankname_lt],
		src.[intermediatebankswift_lt],
		src.[comments],
		src.[qriban_ch],
		src.[specparameters_ch],
		src.[modifieddatetime],
		src.[modifiedby],
		src.[modifiedtransactionid],
		src.[createddatetime],
		src.[createdby],
		src.[createdtransactionid],
		src.[dataareaid],
		src.[recversion],
		src.[partition],
		src.[sysrowversion],
		src.[recid],
		src.[tableid],
		src.[versionnumber],
		src.[createdon],
		src.[modifiedon],
		src.[IsDelete],
		src.[PartitionId],
		getdate() AS [Audit_Date]
	FROM [staging_fo].[VENDBANKACCOUNT] src
		LEFT JOIN [synapse_fo].[VENDBANKACCOUNT] tgt
			ON tgt.[recid] = src.[recid]
	WHERE tgt.[recid] IS NULL


	-- Insert the changes
	INSERT INTO [Audit_Log].[VENDBANKACCOUNT_FO]
	(
		[SinkCreatedOn],
		[SinkModifiedOn],
		[bankaccounttype],
		[bankcodetype],
		[lvdefaultbank],
		[transtype_jp],
		[reviewed],
		[bankinformationorigin],
		[workflowstate],
		[versioningstate],
		[sks_eft_acctstatus],
		[sks_eft_prenotestatus],
		[workflowtype],
		[sysdatastatecode],
		[accountid],
		[accountnum],
		[activedate],
		[bankaccountnamekana_jp],
		[bankcin],
		[bankconstantsymbol],
		[bankcontractaccount],
		[bankgroupid],
		[bankiban],
		[cellularphone],
		[contactperson],
		[corraccount_w],
		[correspbank_ee],
		[currencycode],
		[dirdunsnumber],
		[email],
		[exchrate],
		[exchrateref],
		[expirydate],
		[foreignaccount_ru],
		[foreignbank_ru],
		[foreignswift_ru],
		[intermaccount_ee],
		[intermbank_ee],
		[intermbankaccountid],
		[location],
		[logisticslocation],
		[msgtobank],
		[name],
		[pager],
		[phone],
		[phonelocal],
		[registrationnum],
		[sms],
		[specificsymbol],
		[swiftno],
		[telefax],
		[telex],
		[url],
		[vendaccount],
		[vendduns4number],
		[vendpaymenttextcode],
		[ficreditorid_dk],
		[correspondentbankaccount_lt],
		[correspondentbankaddress_lt],
		[correspondentbankname_lt],
		[correspondentbankswift_lt],
		[intermediatebankaccount_lt],
		[intermediatebankaddress_lt],
		[intermediatebankname_lt],
		[intermediatebankswift_lt],
		[comments],
		[qriban_ch],
		[specparameters_ch],
		[modifieddatetime],
		[modifiedby],
		[modifiedtransactionid],
		[createddatetime],
		[createdby],
		[createdtransactionid],
		[dataareaid],
		[recversion],
		[partition],
		[sysrowversion],
		[recid],
		[tableid],
		[versionnumber],
		[createdon],
		[modifiedon],
		[IsDelete],
		[PartitionId],
		[Audit_Date]
	)
	SELECT 
		src.[SinkCreatedOn],
		src.[SinkModifiedOn],
		src.[bankaccounttype],
		src.[bankcodetype],
		src.[lvdefaultbank],
		src.[transtype_jp],
		src.[reviewed],
		src.[bankinformationorigin],
		src.[workflowstate],
		src.[versioningstate],
		src.[sks_eft_acctstatus],
		src.[sks_eft_prenotestatus],
		src.[workflowtype],
		src.[sysdatastatecode],
		src.[accountid],
		src.[accountnum],
		src.[activedate],
		src.[bankaccountnamekana_jp],
		src.[bankcin],
		src.[bankconstantsymbol],
		src.[bankcontractaccount],
		src.[bankgroupid],
		src.[bankiban],
		src.[cellularphone],
		src.[contactperson],
		src.[corraccount_w],
		src.[correspbank_ee],
		src.[currencycode],
		src.[dirdunsnumber],
		src.[email],
		src.[exchrate],
		src.[exchrateref],
		src.[expirydate],
		src.[foreignaccount_ru],
		src.[foreignbank_ru],
		src.[foreignswift_ru],
		src.[intermaccount_ee],
		src.[intermbank_ee],
		src.[intermbankaccountid],
		src.[location],
		src.[logisticslocation],
		src.[msgtobank],
		src.[name],
		src.[pager],
		src.[phone],
		src.[phonelocal],
		src.[registrationnum],
		src.[sms],
		src.[specificsymbol],
		src.[swiftno],
		src.[telefax],
		src.[telex],
		src.[url],
		src.[vendaccount],
		src.[vendduns4number],
		src.[vendpaymenttextcode],
		src.[ficreditorid_dk],
		src.[correspondentbankaccount_lt],
		src.[correspondentbankaddress_lt],
		src.[correspondentbankname_lt],
		src.[correspondentbankswift_lt],
		src.[intermediatebankaccount_lt],
		src.[intermediatebankaddress_lt],
		src.[intermediatebankname_lt],
		src.[intermediatebankswift_lt],
		src.[comments],
		src.[qriban_ch],
		src.[specparameters_ch],
		src.[modifieddatetime],
		src.[modifiedby],
		src.[modifiedtransactionid],
		src.[createddatetime],
		src.[createdby],
		src.[createdtransactionid],
		src.[dataareaid],
		src.[recversion],
		src.[partition],
		src.[sysrowversion],
		src.[recid],
		src.[tableid],
		src.[versionnumber],
		src.[createdon],
		src.[modifiedon],
		src.[IsDelete],
		src.[PartitionId],
		getdate() AS [Audit_Date]
	FROM [staging_fo].[VENDBANKACCOUNT] src
		INNER JOIN [synapse_fo].[VENDBANKACCOUNT] tgt
			ON tgt.[recid] = src.[recid]
	
	WHERE 
	(
		(ISNULL(tgt.[bankaccounttype], '') <> ISNULL(src.[bankaccounttype], 0)) OR 
		(ISNULL(tgt.[bankcodetype], '') <> ISNULL(src.[bankcodetype], 0)) OR 
		(ISNULL(tgt.[lvdefaultbank], '') <> ISNULL(src.[lvdefaultbank], 0)) OR 
		(ISNULL(tgt.[transtype_jp], '') <> ISNULL(src.[transtype_jp], 0)) OR 
		(ISNULL(tgt.[reviewed], '') <> ISNULL(src.[reviewed], 0)) OR 
		(ISNULL(tgt.[bankinformationorigin], '') <> ISNULL(src.[bankinformationorigin], 0)) OR 
		(ISNULL(tgt.[workflowstate], '') <> ISNULL(src.[workflowstate], 0)) OR 
		(ISNULL(tgt.[versioningstate], '') <> ISNULL(src.[versioningstate], 0)) OR 
		(ISNULL(tgt.[sks_eft_acctstatus], '') <> ISNULL(src.[sks_eft_acctstatus], 0)) OR 
		(ISNULL(tgt.[sks_eft_prenotestatus], '') <> ISNULL(src.[sks_eft_prenotestatus], 0)) OR 
		(ISNULL(tgt.[workflowtype], '') <> ISNULL(src.[workflowtype], 0)) OR 
		(ISNULL(tgt.[sysdatastatecode], '') <> ISNULL(src.[sysdatastatecode], 0)) OR 
		(ISNULL(tgt.[accountid], '') <> ISNULL(src.[accountid], '')) OR 
		(ISNULL(tgt.[accountnum], '') <> ISNULL(src.[accountnum], '')) OR 
		(ISNULL(tgt.[activedate], '1900-01-01') <> ISNULL(src.[activedate], '1900-01-01')) OR
		(ISNULL(tgt.[bankaccountnamekana_jp], '') <> ISNULL(src.[bankaccountnamekana_jp], '')) OR 
		(ISNULL(tgt.[bankcin], '') <> ISNULL(src.[bankcin], '')) OR 
		(ISNULL(tgt.[bankconstantsymbol], '') <> ISNULL(src.[bankconstantsymbol], 0)) OR 
		(ISNULL(tgt.[bankcontractaccount], '') <> ISNULL(src.[bankcontractaccount], '')) OR 
		(ISNULL(tgt.[bankgroupid], '') <> ISNULL(src.[bankgroupid], '')) OR 
		(ISNULL(tgt.[bankiban], '') <> ISNULL(src.[bankiban], '')) OR 
		(ISNULL(tgt.[cellularphone], '') <> ISNULL(src.[cellularphone], '')) OR 
		(ISNULL(tgt.[contactperson], '') <> ISNULL(src.[contactperson], '')) OR 
		(ISNULL(tgt.[corraccount_w], '') <> ISNULL(src.[corraccount_w], '')) OR 
		(ISNULL(tgt.[correspbank_ee], '') <> ISNULL(src.[correspbank_ee], '')) OR 
		(ISNULL(tgt.[currencycode], '') <> ISNULL(src.[currencycode], '')) OR 
		(ISNULL(tgt.[dirdunsnumber], '') <> ISNULL(src.[dirdunsnumber], 0)) OR 
		(ISNULL(tgt.[email], '') <> ISNULL(src.[email], '')) OR 
		(ISNULL(tgt.[exchrate], 0) <> ISNULL(src.[exchrate], 0)) OR 
		(ISNULL(tgt.[exchrateref], '') <> ISNULL(src.[exchrateref], '')) OR 
		(ISNULL(tgt.[expirydate], '1900-01-01') <> ISNULL(src.[expirydate], '1900-01-01')) OR
		(ISNULL(tgt.[foreignaccount_ru], '') <> ISNULL(src.[foreignaccount_ru], '')) OR 
		(ISNULL(tgt.[foreignbank_ru], '') <> ISNULL(src.[foreignbank_ru], '')) OR 
		(ISNULL(tgt.[foreignswift_ru], '') <> ISNULL(src.[foreignswift_ru], '')) OR 
		(ISNULL(tgt.[intermaccount_ee], '') <> ISNULL(src.[intermaccount_ee], '')) OR 
		(ISNULL(tgt.[intermbank_ee], '') <> ISNULL(src.[intermbank_ee], '')) OR 
		(ISNULL(tgt.[intermbankaccountid], '') <> ISNULL(src.[intermbankaccountid], '')) OR 
		(ISNULL(tgt.[location], '') <> ISNULL(src.[location], 0)) OR 
		(ISNULL(tgt.[logisticslocation], '') <> ISNULL(src.[logisticslocation], 0)) OR 
		(ISNULL(tgt.[msgtobank], '') <> ISNULL(src.[msgtobank], '')) OR 
		(ISNULL(tgt.[name], '') <> ISNULL(src.[name], '')) OR 
		(ISNULL(tgt.[pager], '') <> ISNULL(src.[pager], '')) OR 
		(ISNULL(tgt.[phone], '') <> ISNULL(src.[phone], '')) OR 
		(ISNULL(tgt.[phonelocal], '') <> ISNULL(src.[phonelocal], '')) OR 
		(ISNULL(tgt.[registrationnum], '') <> ISNULL(src.[registrationnum], '')) OR 
		(ISNULL(tgt.[sms], '') <> ISNULL(src.[sms], '')) OR 
		(ISNULL(tgt.[specificsymbol], '') <> ISNULL(src.[specificsymbol], '')) OR 
		(ISNULL(tgt.[swiftno], '') <> ISNULL(src.[swiftno], '')) OR 
		(ISNULL(tgt.[telefax], '') <> ISNULL(src.[telefax], '')) OR 
		(ISNULL(tgt.[telex], '') <> ISNULL(src.[telex], '')) OR 
		(ISNULL(tgt.[url], '') <> ISNULL(src.[url], '')) OR 
		(ISNULL(tgt.[vendaccount], '') <> ISNULL(src.[vendaccount], '')) OR 
		(ISNULL(tgt.[vendduns4number], '') <> ISNULL(src.[vendduns4number], '')) OR 
		(ISNULL(tgt.[vendpaymenttextcode], '') <> ISNULL(src.[vendpaymenttextcode], '')) OR 
		(ISNULL(tgt.[ficreditorid_dk], '') <> ISNULL(src.[ficreditorid_dk], '')) OR 
		(ISNULL(tgt.[correspondentbankaccount_lt], '') <> ISNULL(src.[correspondentbankaccount_lt], '')) OR 
		(ISNULL(tgt.[correspondentbankaddress_lt], '') <> ISNULL(src.[correspondentbankaddress_lt], '')) OR 
		(ISNULL(tgt.[correspondentbankname_lt], '') <> ISNULL(src.[correspondentbankname_lt], '')) OR 
		(ISNULL(tgt.[correspondentbankswift_lt], '') <> ISNULL(src.[correspondentbankswift_lt], '')) OR 
		(ISNULL(tgt.[intermediatebankaccount_lt], '') <> ISNULL(src.[intermediatebankaccount_lt], '')) OR 
		(ISNULL(tgt.[intermediatebankaddress_lt], '') <> ISNULL(src.[intermediatebankaddress_lt], '')) OR 
		(ISNULL(tgt.[intermediatebankname_lt], '') <> ISNULL(src.[intermediatebankname_lt], '')) OR 
		(ISNULL(tgt.[intermediatebankswift_lt], '') <> ISNULL(src.[intermediatebankswift_lt], '')) OR 
		(ISNULL(tgt.[comments], '') <> ISNULL(src.[comments], '')) OR 
		(ISNULL(tgt.[qriban_ch], '') <> ISNULL(src.[qriban_ch], '')) OR 
		(ISNULL(tgt.[specparameters_ch], '') <> ISNULL(src.[specparameters_ch], '')) OR 
		(ISNULL(tgt.[modifieddatetime], '1900-01-01') <> ISNULL(src.[modifieddatetime], '1900-01-01')) OR
		(ISNULL(tgt.[modifiedby], '') <> ISNULL(src.[modifiedby], '')) OR 
		(ISNULL(tgt.[modifiedtransactionid], '') <> ISNULL(src.[modifiedtransactionid], 0)) OR 
		(ISNULL(tgt.[createddatetime], '1900-01-01') <> ISNULL(src.[createddatetime], '1900-01-01')) OR
		(ISNULL(tgt.[createdby], '') <> ISNULL(src.[createdby], '')) OR 
		(ISNULL(tgt.[createdtransactionid], '') <> ISNULL(src.[createdtransactionid], 0)) OR 
		(ISNULL(tgt.[dataareaid], '') <> ISNULL(src.[dataareaid], ''))
	)
END
