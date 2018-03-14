
-------------------------------------------------------------------------------
--
--  This script is provided by DISA to assist administrators in ensuring SQL Server
--  deployments comply with STIG requirements.  As an administrator employing 
--  this script, you are responsible for:
--  -  understanding its purpose and how it works;
--  -  determining its suitability for your situation;
--  -  verifying that it works as intended;
--  -  ensuring that there are no legal or contractual obstacles to your using it 
--         (for example, if the database is acquired as part of an application 
--         package, the vendor may restrict your right to modify the database).
--
--  DISA cannot accept responsibility for adverse outcomes resulting from the 
--  use of this script.
--
--  Microsoft Corporation was not involved in the development of this script.
--
-------------------------------------------------------------------------------
--
--	File name: Track.sql
--	Tools for tracking changes to objects in a SQL Server database
--		(tables, procedures, functions, triggers, etc.).


--	BEFORE USING THIS FILE:
--		- Please read the following notes.
--		- Make the substitutions discussed below.
--
--
--	WHAT THIS SCRIPT DOES:
--		- Creates the following:
--			- TABLE STIG.database_object_tracker
--			- TABLE STIG.database_object_change_report
--			- VIEW STIG.database_object_change_report_current
--			- TABLE-VALUED FUNCTION STIG.database_object_change_report_as_of(date)
--			- PROCEDURE STIG.database_object_snapshot
--			- PROCEDURE STIG.database_object_changes
--			- PROCEDURE STIG.database_object_snapshot_purge
--			- JOB STIG_database_object_tracking and its component steps and schedule.
--
--
--	WHAT THE SET OF TOOLS CREATED BY THIS SCRIPT DOES:
--
--		- Monitors for changes to database objects.  Does this by taking a periodic snapshot
--			of the sys.all_objects table, and comparing each snapshot to the prior one.
--
--		- Records detected changes in the STIG.database_object_change_report table.
--
--		- Lets you view the changes from the latest run, 
--			via the STIG.database_object_change_report_current view.

--		- Lets you view the changes from any run you choose,
--			via the table-valued function STIG.database_object_change_report_as_of(date-time).
--			This displays the results of the latest run that occurred at or before the specified date and time.
--			Please note that if, for example, there were runs at 2020-02-01 23:59:59 and 2020-02-02 00:00:01,
--			specifying '2020-02-02' would get you the one from 2020-02-01 23:59:59.
--
--		- Tells you the type of change that was detected.

--		    In the case of the following messages, exactly one report row is produced:
--			- 'No changes'
--					Probably the most common message.  The latest list of objects is the same as the prior one.
--			- 'There is only one snapshot in the tracker table - nothing to compare against.'
--					Normally, this message will be produced only by the first run of the job
--					(or the first run after the tracker table has been emptied).
--			- 'There are no snapshots in the tracker table.'
--					This will appear only if the tracker table is empty and the job steps are run out of sequence.
--
--			When the following messages appear, there will be a row for each detected change:
--			- 'Renamed'
--					The object ID is the same as before, but the object name has changed.
--			- 'Changed schema'
--					The object ID is the same as before, but the schema name has changed. 
--					This indicates that the object has been transferred between schemas.
--			- 'Renamed and changed schema'
--					Both of the preceding actions have been detected.
--			- 'Dropped'
--					An object in the prior list is not in the latest list.
--			- 'Created'
--					An object in the latest list is not in the prior list.
--			- 'Altered'
--					An object is in both the prior and the latest lists.  Its type, creation date
--					and object ID have not changed, but its modification date has changed.
--					When there is a row reporting Altered, there can be a second row for the same 
--					object, reporting Renamed and/or Changed Schema.
--			- 'Replaced (dropped and created)'
--					An object is in both the prior and the latest lists.  Its type has not changed.
--					Its creation date and object ID have changed.
--			- 'Replaced - object type changed'
--					An object is in both the prior and the latest lists.  Its type has changed.
--					This could happen, for example, if a table called SomeData was dropped and
--					a function named SomeData was created.
--
--		- Lets you specify the frequency of snapshots; the default is twice per 24 hours.
--
--		- Cleans up after itself.  Some snapshots are redundant; the job deletes them unless 
--			you override this.  It also deletes snapshots and report data older than a specified 
--			retention date.  You control this; the default is 180 days ago, as of each run.
--
--
--	What this does NOT do:
--
--		- It does not tell you anything about objects that were created and then dropped 
--			between two successive runs.  The more frequently you run it, the more likely it
--			is to detect short-lived objects.  If you suspect that such a short-lived object
--			has been created and dropped, you can mine the audit logs for a record of it.
--
--		- It does not, on its own, produce a nicely-formatted report; it just records 
--			the data for such a report in the STIG.database_object_change_report table, and
--			the point-in-time snapshots of sys.all_objects in STIG.database_object_tracker.
--
--		- It does not present the rows of these tables in any guaranteed order.
--			Augment it with your own ORDER BY clauses to suit your needs.
--
--		- It does not, on its own, transmit a notification of its findings to anyone.
--			You will need to add your own logic to do this.
--
--		- It does not create the directory where the log file will reside, or grant permissions on it.
--			To log to a file, create the folder to hold the log, and grant read and write access on 
--			the folder to the account running the SQL Server service.
--
--
--	SECURITY considerations:
--
--		- Keep the tables, view, procedures and job that are defined here restricted to those
--			administrative accounts that need them.  If an adversary were to gain access to them,
--			he/she could modify the code and/or the data, to evade detection.
--
--
--	SUBSTITUTIONS
--	This script is intended to be customized before use.  Make the following changes:
--
--		-  <database name> - change to the the name of the database to be monitored, 
--			in all six locations where it occurs.
--
--		- The word "STIG" is suggested as the name of the schema to hold STIG-related utilities.
--			"STIG_" is also used as a prefix in the names of the job and job steps.
--			If your circumstances require a different schema be used, change "STIG" to the preferred name
--			throughout the document.
--
--		- If the chosen schema already exists, comment out the line that currently reads "CREATE SCHEMA STIG;"	 
--
--		- This tool tracks objects only in the database where it is deployed.
--			To track multiple databases, run this script in each one.
--			You need a separate job defined to deal with each database.
--			However, jobs are a server-level feature.  Therefore, it will be necessary to provide distinct 
--			names for the job, job steps and schedule pertaining to each database.
--			One way to do this is to change "STIG_" to a character string of your choosing, throughout this file.
--
--		- <job category> - change to the desired value in all three locations where it occurs.  
--			You can use an existing category or specify a new one.
--			You can review existing categories by querying the table msdb.dbo.syscategories.
--
--		- <owner login name> - specify the server account owning the job.  (One location.)
--
--		- <log path and file name> - the location in the file system where you want the job's 
--			progress log to be stored.  Change this in each of the five places it occurs.
--			You must create the folder for the job to work in this respect; however, if the file does not already 
--			exist, the job will create it, and if the file does exist, the job will append the latest log to it.
--			If the folder does not exist, or if the SQL Server Agent service account does not have read/write 
--			permissions on it, the job will not fail, but the log file will not be produced.
--			However, the log (for the most recent run only) is also stored in the msdb.dbo.sysjobstepslogs table.
--
--		- Adjust the job schedule to suit.  If you are familiar with how to script job definitions, you can edit this
--			script; or you can make the changes in the GUI dialogs in SQL Server Management Studio, Object Explorer.  
--			(Expand  SQL Server Agent >> Jobs.  Double-click the name of the job, to open the Properties dialog.
--			Select Schedules.  Edit the schedule.)
--
--		- Adjust the snapshot retention to suit, in Step 4 of the job, where it invokes the Purge Procedure:
--			"EXECUTE STIG.database_object_snapshot_purge @retention = default"	
--				@Retention can be:
--					- An integer (enclosed in single quotes).  Items more than that many days old will be purged.
--					- A date, in single quotes (with optional time of day).  Items earlier will be purged.
--					- "Null" or "default", without quotes, or a blank string in single quotes.
--						The default value, 180 days, will be used.
--					- 'All'.  No purge will take place.
--			Note:  for maintainability, we recommend you make this change only in the job step definition,
--				and not in the code of STIG.database_object_snapshot_purge.
--
--		- If you need to restrict the objects being monitored, such as by schema or by object type,
--			un-comment and customize the WHERE clause in the procedure STIG.database_object_snapshot.


USE <database name>;
GO

CREATE SCHEMA STIG;
GO



BEGIN TRY DROP TABLE STIG.database_object_tracker END TRY BEGIN CATCH END CATCH;
GO

CREATE TABLE STIG.database_object_tracker
	(
	[row_id]		bigint		IDENTITY PRIMARY KEY,
	[snapshot_date]	datetime	NOT NULL,
	[schema_name]	sysname		NOT NULL,
	[object_name]	sysname		NOT NULL,
	[schema_id]		int			NOT NULL,
	[object_id]		int			NOT NULL,
	[object_type]	varchar(2)	NOT NULL,
	[type_desc]		sysname		NOT NULL,
	[create_date]	datetime	NOT NULL,
	[modify_date]	datetime	NOT NULL
	)
;
GO
CREATE UNIQUE INDEX database_object_tracker_IX1
	ON	STIG.database_object_tracker
		(
		[snapshot_date],
		[schema_name],
		[object_name],
		[row_id]
		)
;
GO
CREATE UNIQUE INDEX database_object_tracker_IX2
	ON	STIG.database_object_tracker
		(
		[schema_name],
		[object_name],
		[snapshot_date],
		[row_id]
		)
;
GO


BEGIN TRY DROP TABLE STIG.database_object_change_report END TRY BEGIN CATCH END CATCH;
GO
CREATE TABLE STIG.database_object_change_report
	(
	[comparison_date]		datetime	NOT NULL,
	[latest_snapshot_date]	datetime	NOT NULL,
	[prior_snapshot_date]	datetime	NOT NULL,
	[action]				nvarchar(80)NOT NULL,
	[latest_schema_name]	sysname		NOT NULL,
	[prior_schema_name]		sysname		NOT NULL,
	[latest_object_name]	sysname		NOT NULL,
	[prior_object_name]		sysname		NOT NULL,
	[latest_object_id]		int			NULL,
	[prior_object_id]		int			NULL,
	[latest_object_type]	varchar(2)	NULL,
	[prior_object_type]		varchar(2)	NULL,
	[latest_type_desc]		sysname		NULL,
	[prior_type_desc]		sysname		NULL,
	[latest_create_date]	datetime	NULL,
	[prior_create_date]		datetime	NULL,
	[latest_modify_date]	datetime	NULL,
	[prior_modify_date]		datetime	NULL,
	[report_row_id]			bigint		IDENTITY
	)
;
GO
CREATE INDEX database_object_change_report_IX1
	ON	STIG.database_object_change_report
		(
		[comparison_date],
		[latest_schema_name],
		[latest_object_name],
		[report_row_id]
		)
;
GO
CREATE INDEX database_object_change_report_IX2
	ON	STIG.database_object_change_report
		(
		[latest_schema_name],
		[latest_object_name],
		[comparison_date],
		[report_row_id]
		)
;
GO



BEGIN TRY DROP VIEW STIG.database_object_change_report_current END TRY BEGIN CATCH END CATCH;
GO
CREATE VIEW STIG.database_object_change_report_current
WITH ENCRYPTION
AS
	SELECT *
	FROM STIG.database_object_change_report
	WHERE comparison_date = 
		(SELECT max(comparison_date) FROM STIG.database_object_change_report)
;
GO



BEGIN TRY DROP FUNCTION STIG.database_object_change_report_as_of END TRY BEGIN CATCH END CATCH;
GO
CREATE FUNCTION STIG.database_object_change_report_as_of(@date datetime)
	RETURNS @T TABLE
		(
		[comparison_date]		datetime	NOT NULL,
		[latest_snapshot_date]	datetime	NOT NULL,
		[prior_snapshot_date]	datetime	NOT NULL,
		[action]				nvarchar(80)NOT NULL,
		[latest_schema_name]	sysname		NOT NULL,
		[prior_schema_name]		sysname		NOT NULL,
		[latest_object_name]	sysname		NOT NULL,
		[prior_object_name]		sysname		NOT NULL,
		[latest_object_id]		int			NULL,
		[prior_object_id]		int			NULL,
		[latest_object_type]	varchar(2)	NULL,
		[prior_object_type]		varchar(2)	NULL,
		[latest_type_desc]		sysname		NULL,
		[prior_type_desc]		sysname		NULL,
		[latest_create_date]	datetime	NULL,
		[prior_create_date]		datetime	NULL,
		[latest_modify_date]	datetime	NULL,
		[prior_modify_date]		datetime	NULL,
		[report_row_id]			bigint		NOT NULL
		)
WITH ENCRYPTION
AS
BEGIN;
	DECLARE @comparison_date datetime =
		(SELECT max([comparison_date]) FROM STIG.database_object_change_report WHERE [comparison_date] <= @date);
	INSERT INTO @T
	SELECT
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date],
		[report_row_id]
	FROM
		STIG.database_object_change_report
	WHERE
		[comparison_date] = @comparison_date
	;
ExitFunction:
	RETURN;
END;
GO



BEGIN TRY DROP PROCEDURE STIG.database_object_snapshot END TRY BEGIN CATCH END CATCH;
GO

CREATE PROCEDURE STIG.database_object_snapshot
WITH ENCRYPTION
AS BEGIN;
	DECLARE	@now datetime = current_timestamp;
	DECLARE @row_count int;
	PRINT 'INSERT INTO STIG.database_object_tracker:'
	INSERT INTO STIG.database_object_tracker
		(
		[snapshot_date],
		[schema_name],
		[object_name],
		[schema_id],
		[object_id],
		[object_type],
		[type_desc],
		[create_date],
		[modify_date]
		)
	SELECT
		@now,
		coalesce(schema_name([schema_id]), ''),
		coalesce([name], ''),
		[schema_id],
		[object_id],
		[type],
		[type_desc],
		[create_date],
		[modify_date]
	FROM
		sys.all_objects
--	WHERE
--		Add any desired filtering code here.
	;
	SET @row_count = @@ROWCOUNT;
	PRINT cast(@row_count as nvarchar(40)) + ' rows';
END;
GO


BEGIN TRY DROP PROCEDURE STIG.database_object_changes END TRY BEGIN CATCH END CATCH;
GO

CREATE PROCEDURE STIG.database_object_changes
					@erase_redundant_snapshot	bit = 1
WITH ENCRYPTION
AS BEGIN;
	DECLARE @LatestSnapshot datetime = (SELECT max([snapshot_date]) FROM STIG.database_object_tracker);
	DECLARE @PriorSnapshot  datetime = (SELECT max([snapshot_date]) FROM STIG.database_object_tracker WHERE [snapshot_date] < @LatestSnapshot);
	DECLARE @PriorSnapshot2 datetime = (SELECT max([snapshot_date]) FROM STIG.database_object_tracker WHERE [snapshot_date] < @PriorSnapshot);
	DECLARE	@now datetime = current_timestamp;
	DECLARE @no_change_this_run bit = 0;
	DECLARE @row_count int = 0;
	
	PRINT 'INSERT INTO STIG.database_object_change_report:'
	IF @Latestsnapshot IS NULL
	BEGIN
		INSERT INTO STIG.database_object_change_report
			(
			[comparison_date],
			[latest_snapshot_date],
			[prior_snapshot_date],
			[action],
			[latest_schema_name],
			[prior_schema_name],
			[latest_object_name],
			[prior_object_name]
			)
		VALUES
			(
			@now,
			'9999-12-31',
			'9999-12-31',
			'There are no snapshots in the tracker table.',
			'',
			'',
			'',
			''
			)
		;
		PRINT '1 row';
		GOTO ExitProcedure;
	END;

	IF @PriorSnapshot IS NULL
	BEGIN
		INSERT INTO STIG.database_object_change_report
			(
			[comparison_date],
			[latest_snapshot_date],
			[prior_snapshot_date],
			[action],
			[latest_schema_name],
			[prior_schema_name],
			[latest_object_name],
			[prior_object_name]
			)
		VALUES
			(
			@now,
			@LatestSnapshot,
			'9999-12-31',
			'There is only one snapshot in the tracker table - nothing to compare against.',
			'',
			'',
			'',
			''
			)
		;
		PRINT '1 row';
		GOTO ExitProcedure;
	END;

	BEGIN TRY DROP TABLE #Latest END TRY BEGIN CATCH END CATCH;
	BEGIN TRY DROP TABLE #Prior  END TRY BEGIN CATCH END CATCH;

	SELECT * INTO #Latest FROM STIG.database_object_tracker WHERE [snapshot_date] = @LatestSnapshot;
	SELECT * INTO #Prior  FROM STIG.database_object_tracker WHERE [snapshot_date] = @PriorSnapshot;


	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Renamed and changed schema',
		coalesce(#Latest.[schema_name], ''),
		coalesce(#Prior. [schema_name], ''),
		coalesce(#Latest.[object_name], ''),
		coalesce(#Prior. [object_name], ''),
		#Latest.[object_id],
		#Prior. [object_id],
		#Latest.[object_type],
		#Prior. [object_type],
		#Latest.[type_desc],
		#Prior. [type_desc],
		#Latest.[create_date],
		#Prior. [create_date],
		#Latest.[modify_date],
		#Prior. [modify_date]
	FROM
		#Prior
		LEFT OUTER JOIN #Latest
			ON	#Latest.[object_id]	  =  #Prior.[object_id]
	WHERE
		#Latest.[schema_name] <> #Prior.[schema_name]
	AND #Latest.[object_name] <> #Prior.[object_name]
	;
	SET @row_count += @@ROWCOUNT;


	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Renamed',
		coalesce(#Latest.[schema_name], ''),
		coalesce(#Prior. [schema_name], ''),
		coalesce(#Latest.[object_name], ''),
		coalesce(#Prior. [object_name], ''),
		#Latest.[object_id],
		#Prior. [object_id],
		#Latest.[object_type],
		#Prior. [object_type],
		#Latest.[type_desc],
		#Prior. [type_desc],
		#Latest.[create_date],
		#Prior. [create_date],
		#Latest.[modify_date],
		#Prior. [modify_date]
	FROM
		#Prior
		LEFT OUTER JOIN #Latest
			ON	#Latest.[object_id]	  =  #Prior.[object_id]
	WHERE
		#Latest.[schema_name] =  #Prior.[schema_name]
	AND #Latest.[object_name] <> #Prior.[object_name]
	;
	SET @row_count += @@ROWCOUNT;


	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Changed schema',
		coalesce(#Latest.[schema_name], ''),
		coalesce(#Prior. [schema_name], ''),
		coalesce(#Latest.[object_name], ''),
		coalesce(#Prior. [object_name], ''),
		#Latest.[object_id],
		#Prior. [object_id],
		#Latest.[object_type],
		#Prior. [object_type],
		#Latest.[type_desc],
		#Prior. [type_desc],
		#Latest.[create_date],
		#Prior. [create_date],
		#Latest.[modify_date],
		#Prior. [modify_date]
	FROM
		#Prior
		LEFT OUTER JOIN #Latest
			ON	#Latest.[object_id]	  =  #Prior.[object_id]
	WHERE
		#Latest.[schema_name] <> #Prior.[schema_name]
	AND #Latest.[object_name] =  #Prior.[object_name]
	;
	SET @row_count += @@ROWCOUNT;


	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Dropped',
		'',
		coalesce(#Prior. [schema_name], ''),
		'',
		coalesce(#Prior. [object_name], ''),
		NULL,
		#Prior.[object_id],
		NULL,
		#Prior.[object_type],
		NULL,
		#Prior.[type_desc],
		NULL,
		#Prior.[create_date],
		NULL,
		#Prior.[modify_date]
	FROM
		#Prior
		LEFT OUTER JOIN #Latest
			ON	#Latest.[schema_name] = #Prior.[schema_name]
			AND #Latest.[object_name] = #Prior.[object_name]
	WHERE
		#Latest.[snapshot_date] IS NULL
	AND	NOT EXISTS
			(
			SELECT 1 
			FROM STIG.database_object_change_report R
			WHERE
				R.[comparison_date] = @now
			AND	R.[latest_snapshot_date] = @LatestSnapshot
			AND	R.[prior_snapshot_date] = @PriorSnapshot
			AND	R.[prior_object_id] = #Prior.[object_id]
			AND R.[action] IN ('Renamed and changed schema', 'Renamed', 'Changed schema')
			)
	;
	SET @row_count += @@ROWCOUNT;


	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Created',
		coalesce(#Latest.[schema_name], ''),
		'',
		coalesce(#Latest.[object_name], ''),
		'',
		#Latest.[object_id],
		NULL,
		#Latest.[object_type],
		NULL,
		#Latest.[type_desc],
		NULL,
		#Latest.[create_date],
		NULL,
		#Latest.[modify_date],
		NULL
	FROM
		#Prior
		RIGHT OUTER JOIN #Latest
			ON	#Latest.[schema_name] = #Prior.[schema_name]
			AND #Latest.[object_name] = #Prior.[object_name]
	WHERE
		#Prior.[snapshot_date] IS NULL
	AND	NOT EXISTS
			(
			SELECT 1 
			FROM STIG.database_object_change_report R
			WHERE
				R.[comparison_date] = @now
			AND	R.[latest_snapshot_date] = @LatestSnapshot
			AND	R.[prior_snapshot_date] = @PriorSnapshot
			AND	R.[latest_object_id] = #Latest.[object_id]
			AND R.[action] IN ('Renamed and changed schema', 'Renamed', 'Changed schema')
			)
	;
	SET @row_count += @@ROWCOUNT;


	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Altered',
		coalesce(#Latest.[schema_name], ''),
		coalesce(#Prior. [schema_name], ''),
		coalesce(#Latest.[object_name], ''),
		coalesce(#Prior. [object_name], ''),
		#Latest.[object_id],
		#Prior. [object_id],
		#Latest.[object_type],
		#Prior. [object_type],
		#Latest.[type_desc],
		#Prior. [type_desc],
		#Latest.[create_date],
		#Prior. [create_date],
		#Latest.[modify_date],
		#Prior. [modify_date]
	FROM
		#Prior
		INNER JOIN #Latest
			ON	#Latest.[schema_name] = #Prior.[schema_name]
			AND #Latest.[object_name] = #Prior.[object_name]
	WHERE
		#Latest.[object_id]	  =  #Prior.[object_id]
	AND	#Latest.[create_date] =  #Prior.[create_date]
	AND #Latest.[modify_date] <> #Prior.[modify_date]
	UNION
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Altered',
		coalesce(#Latest.[schema_name], ''),
		coalesce(#Prior. [schema_name], ''),
		coalesce(#Latest.[object_name], ''),
		coalesce(#Prior. [object_name], ''),
		#Latest.[object_id],
		#Prior. [object_id],
		#Latest.[object_type],
		#Prior. [object_type],
		#Latest.[type_desc],
		#Prior. [type_desc],
		#Latest.[create_date],
		#Prior. [create_date],
		#Latest.[modify_date],
		#Prior. [modify_date]
	FROM
		#Prior
		INNER JOIN #Latest
			ON	#Latest.[object_id] = #Prior.[object_id]
	WHERE
		#Latest.[object_id]	  =  #Prior.[object_id]
	AND	#Latest.[create_date] =  #Prior.[create_date]
	AND #Latest.[modify_date] <> #Prior.[modify_date]
	;
	SET @row_count += @@ROWCOUNT;
	

	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Replaced (dropped and created)',
		coalesce(#Latest.[schema_name], ''),
		coalesce(#Prior. [schema_name], ''),
		coalesce(#Latest.[object_name], ''),
		coalesce(#Prior. [object_name], ''),
		#Latest.[object_id],
		#Prior. [object_id],
		#Latest.[object_type],
		#Prior. [object_type],
		#Latest.[type_desc],
		#Prior. [type_desc],
		#Latest.[create_date],
		#Prior. [create_date],
		#Latest.[modify_date],
		#Prior. [modify_date]
	FROM
		#Prior
		INNER JOIN #Latest
			ON	#Latest.[schema_name] = #Prior.[schema_name]
			AND #Latest.[object_name] = #Prior.[object_name]
	WHERE
		(
			#Latest.[create_date] <> #Prior.[create_date]
		OR	#Latest.[object_id]   <> #Prior.[object_id]
		)
	AND	#Latest.[object_type] = #Prior.[object_type]
	;
	SET @row_count += @@ROWCOUNT;
	

	INSERT INTO STIG.database_object_change_report
		(
		[comparison_date],
		[latest_snapshot_date],
		[prior_snapshot_date],
		[action],
		[latest_schema_name],
		[prior_schema_name],
		[latest_object_name],
		[prior_object_name],
		[latest_object_id],
		[prior_object_id],
		[latest_object_type],
		[prior_object_type],
		[latest_type_desc],
		[prior_type_desc],
		[latest_create_date],
		[prior_create_date],
		[latest_modify_date],
		[prior_modify_date]
		)
	SELECT
		@now,
		@LatestSnapshot,
		@PriorSnapshot,
		'Replaced - object type changed',
		coalesce(#Latest.[schema_name], ''),
		coalesce(#Prior. [schema_name], ''),
		coalesce(#Latest.[object_name], ''),
		coalesce(#Prior. [object_name], ''),
		#Latest.[object_id],
		#Prior. [object_id],
		#Latest.[object_type],
		#Prior. [object_type],
		#Latest.[type_desc],
		#Prior. [type_desc],
		#Latest.[create_date],
		#Prior. [create_date],
		#Latest.[modify_date],
		#Prior. [modify_date]
	FROM
		#Prior
		LEFT OUTER JOIN #Latest
			ON	#Latest.[schema_name] = #Prior.[schema_name]
			AND #Latest.[object_name] = #Prior.[object_name]
	WHERE
		#Latest.[object_type] <> #Prior.[object_type]
	;
	SET @row_count += @@ROWCOUNT;
	
	PRINT cast(@row_count as nvarchar(40)) + ' rows';

	BEGIN TRY DROP TABLE #Latest END TRY BEGIN CATCH END CATCH;
	BEGIN TRY DROP TABLE #Prior  END TRY BEGIN CATCH END CATCH;

	IF 0 = 
		(
		SELECT count(*) FROM STIG.database_object_change_report
		WHERE [comparison_date] = @now
		)
		BEGIN;
			INSERT INTO STIG.database_object_change_report
				(
				[comparison_date],
				[latest_snapshot_date],
				[prior_snapshot_date],
				[action],
				[latest_schema_name],
				[prior_schema_name],
				[latest_object_name],
				[prior_object_name]
				)
			VALUES
				(
				@now,
				@LatestSnapshot,
				@PriorSnapshot,
				'No changes',
				'',
				'',
				'',
				''
				)
			;
			PRINT '1 row';
			SET @no_change_this_run = 1;
		END
	;

	--	Cleanup.
	--	If this run and the previous run both report no changes,
	--	then we do not need to keep the prior snapshot:  the snapshot 
	--	before that has the same contents.
	
	IF	@erase_redundant_snapshot = 1
	AND @no_change_this_run = 1
	AND	@PriorSnapshot2 IS NOT NULL
	BEGIN;
		DECLARE @previous_comparison_date datetime 
			= (SELECT max(comparison_date) FROM STIG.database_object_change_report WHERE comparison_date < @now);
		IF  1 = (SELECT count(*) FROM STIG.database_object_change_report WHERE comparison_date = @previous_comparison_date)
		AND	'No changes' = (SELECT TOP 1 [action] FROM STIG.database_object_change_report WHERE comparison_date = @previous_comparison_date)
		BEGIN;
			PRINT 'DELETE redundant STIG.database_object_tracker entries:';
			DELETE STIG.database_object_tracker WHERE snapshot_date = @PriorSnapshot;
			SET @row_count = @@ROWCOUNT;
			PRINT cast(@row_count as nvarchar(40)) + ' rows';
		END;
	END
	;

ExitProcedure:
END;
;
GO



BEGIN TRY DROP PROCEDURE STIG.database_object_snapshot_purge END TRY BEGIN CATCH END CATCH;
GO

CREATE PROCEDURE STIG.database_object_snapshot_purge 
	@retention varchar(30) = '180'
	--	@Retention can be:
	--		- An integer (enclosed in single quotes).  Items more than that many days old will be purged.
	--		- A date, in single quotes (with optional time of day).  Items earlier will be purged.
	--		- "Null" or "default", without quotes, or a blank string in single quotes.
	--			The default value, 180 days, will be used.
	--		- 'All'.  No purge will take place.
WITH ENCRYPTION
AS BEGIN;
	DECLARE @row_count int = 0;
	IF @retention IS NULL
	OR @retention = ''
		SET @retention = '180';
	IF @retention = 'All'
	BEGIN;
		PRINT 'A @retention value of "All" has been specified.';
		PRINT 'No rows have been purged.'
		GOTO ExitProcedure;
	END;
	DECLARE @cutoff_date datetime;
	IF IsDate(@retention) = 1
		SET @cutoff_date = cast(@retention as datetime);
	ELSE IF IsNumeric(@retention) = 1
		SET @cutoff_date = dateadd(day, (0 - cast(@retention as int)), current_timestamp);
	ELSE BEGIN;
		PRINT 'Invalid value for @retention: ' + @retention;
		PRINT 'Must be a date  or date-time (items earlier will be purged)';
		PRINT 'or an integer (items more than that many days old will be purged).';
		GOTO ExitProcedure;
	END;
	PRINT 'Purge cutoff date: ' +  + convert(varchar(40), @cutoff_date, 121);
	PRINT 'STIG.database_object_tracker:';
	DELETE STIG.database_object_tracker WHERE snapshot_date < @cutoff_date;
	SET @row_count = @@ROWCOUNT;
	PRINT cast(@row_count as nvarchar(40)) + ' rows';
	PRINT 'STIG.database_object_change_report:';
	DELETE STIG.database_object_change_report WHERE latest_snapshot_date < @cutoff_date
		OR (comparison_date < @cutoff_date AND latest_snapshot_date = '9999-12-31');
	SET @row_count = @@ROWCOUNT;
	PRINT cast(@row_count as nvarchar(40)) + ' rows';
ExitProcedure:
END;
GO



DECLARE @job_id uniqueidentifier = (SELECT job_id from msdb.dbo.sysjobs WHERE [name] = N'STIG_database_object_tracking');
IF @job_id IS NOT NULL
	EXEC msdb.dbo.sp_delete_job @job_id = @job_id, @delete_unused_schedule = 1;
GO

BEGIN TRANSACTION;
DECLARE @ReturnCode INT;
SELECT @ReturnCode = 0;

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'<job category>' AND category_class=1)
BEGIN;
	EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'<job category>';
	IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;
END;

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'STIG_database_object_tracking', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Job to detect changes in database objects (tables, procedures, etc.).', 
		@category_name=N'<job category>', 
		@owner_login_name=N'<owner login name>', @job_id = @jobId OUTPUT;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'STIG_database_object_tracking_start', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0,
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'PRINT '''';
PRINT '''';
PRINT ''=============================='';
PRINT ''=============================='';
PRINT '''';
PRINT convert(varchar(40), current_timestamp, 121)
	+ ''STIG_database_object_tracking_job starting'';
PRINT '''';', 
		@database_name=N'<database name>', 
		@output_file_name=N'<log path and file name>', 
		@flags=14;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'STIG_database_object_snapshot', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE STIG.database_object_snapshot;', 
		@database_name=N'<database name>', 
		@output_file_name=N'<log path and file name>',
		@flags=14;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'STIG_database_object_changes', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE STIG.database_object_changes
@erase_redundant_snapshot = 1
;', 
		@database_name=N'<database name>', 
		@output_file_name=N'<log path and file name>', 
		@flags=14;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'STIG_database_object_snapshot_purge', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE STIG.database_object_snapshot_purge
@retention = default
;', 
		@database_name=N'<database name>', 
		@output_file_name=N'<log path and file name>', 
		@flags=14;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'STIG_database_object_tracking_end', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'PRINT '''';
PRINT ''=============================='';
PRINT ''****************************************'';
PRINT '''';
PRINT convert(varchar(40), current_timestamp, 121)
	+ ''STIG_database_object_tracking_job endiing'';
PRINT '''';', 
		@database_name=N'<database name>', 
		@output_file_name=N'<log path and file name>', 
		@flags=14;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

DECLARE @schedule_uid uniqueidentifier = newid();
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'STIG_database_object_tracking_twice_daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=12, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160715, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=235959, 
		@schedule_uid = @schedule_uid;
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)';
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback;

COMMIT TRANSACTION;
GOTO EndSave;
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION;
EndSave:
GO


