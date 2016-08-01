SELECT
	UPPER(name) AS [DBNAME],
	recovery_model_desc AS [RecoveryModel],
	PageDetection = (CASE Page_verify_option_desc
		WHEN 'CHECKSUM' THEN 'CHECKSUM'
		ELSE page_verify_option_desc + ': Warning: Microsoft recommends to use Checksum'
	END),
	AutoShrink = (CASE is_auto_shrink_on
		WHEN 0 THEN 'OFF'
		ELSE 'ON: Warning---AutoShrink cause severe performance issue, if not application requirement, please turn it OFF'
	END),
	DBOWNER = (CASE owner_sid
		WHEN SUSER_SID('sa') THEN 'SA'
		ELSE SUSER_SNAME(owner_sid) + ': It is recommended to change the dbowner to SA'
	END),
	'SQL' + SUBSTRING(@@version, 22, 4) AS SQLVersion,
	CompatibilityLevel = (CASE
		WHEN compatibility_level = 110 THEN 'SQL2012'
		WHEN compatibility_level = 100 THEN 'SQL2008'
		WHEN compatibility_level = 90 THEN 'SQL2005'
		WHEN compatibility_level = 80 THEN 'SQL2000'
	END),
	AutoUpdateStats = (CASE is_auto_update_stats_on
		WHEN 0 THEN 'OFF'
		ELSE 'ON: Its recommended to turn it off and schedule a weekly\daily job'
	END),
	Log_reuse_wait_desc AS [WhyLogCanNotBeReUsed]
FROM sys.databases
GO