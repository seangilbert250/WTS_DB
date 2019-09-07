USE WTS
GO

IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[WTS_System_Contract_Delete]')
AND OBJECTPROPERTY(id, N'IsProcedure') = 1)

DROP PROCEDURE WTS_System_Contract_Delete
GO

CREATE PROCEDURE [dbo].[WTS_System_Contract_Delete]
	@WTS_SYSTEM_CONTRACTID int, 
	@exists int output,
	@deleted int output
AS
BEGIN
	declare @WTS_SYSTEMID int;
	declare @count int = 0;

	SET @exists = 0;
	SET @deleted = 0;

	SELECT @exists = COUNT(WTS_SYSTEM_CONTRACTID)
	FROM WTS_SYSTEM_CONTRACT
	WHERE 
		WTS_SYSTEM_CONTRACTID = @WTS_SYSTEM_CONTRACTID;

	IF ISNULL(@exists,0) = 0
		RETURN;

	BEGIN TRY
		select @WTS_SYSTEMID = WTS_SYSTEMID
		from WTS_SYSTEM_CONTRACT
		where WTS_SYSTEM_CONTRACTID = @WTS_SYSTEM_CONTRACTID;

		DELETE FROM WTS_SYSTEM_CONTRACT
		WHERE
			WTS_SYSTEM_CONTRACTID = @WTS_SYSTEM_CONTRACTID;

		SET @deleted = 1;
	END TRY
	BEGIN CATCH
		SET @deleted = 0;
	END CATCH;

	select @count = count(1)
	from WTS_SYSTEM_CONTRACT
	where WTS_SYSTEMID = @WTS_SYSTEMID
	and [Primary] = 1;

	if @count = 0
		begin
			update WTS_SYSTEM_CONTRACT
			set [Primary] = 1
			where WTS_SYSTEMID = @WTS_SYSTEMID
			and CONTRACTID = (
				select CONTRACTID
				from (
					select CONTRACTID,
						row_number() over(partition by WTS_SYSTEMID order by UpdatedDate desc) as rn
					from WTS_SYSTEM_CONTRACT
					where WTS_SYSTEMID = @WTS_SYSTEMID
				) as a
				where a.rn = 1
			);
		end;
END;

