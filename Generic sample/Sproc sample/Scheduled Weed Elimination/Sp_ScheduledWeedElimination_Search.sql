--USE [DB_TPM2018]
use kasetfms
GO
/****** Object:  StoredProcedure [dbo].[Sp_CommonPreparing_Search]    Script Date: 9/18/2018 6:49:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[Sp_ScheduledWeedElimination_Search] 
	@PlantationID int,
	@Id bigint,
	@RowCount int output,
	@MessageResult nvarchar(200) OUTPUT
AS
BEGIN	
	
	declare @act_status int;		EXEC	@act_status = [dbo].[Sp_ROW_STATUS] @Keyword = 'OK'
	
	-- ===================================================================================
	-- STATE-1: VALIDATION
	-- ===================================================================================	
	/*-------------------------------------------------
	 * เช็ค NULL
	 *-------------------------------------------------*/
	-- Plantation id
	IF @PlantationID is NULL
	begin
		set @RowCount=0;
		set @MessageResult = 'Plantation ผิดพลาด! Plantation ไม่สามารถเป็น NULL ได้';
		return -2;
	end
	IF @PlantationID<=0
	begin
		set @RowCount=0;
		set @MessageResult = 'Plantation ผิดพลาด! Plantation ต้องเป็นรหัสเลขจำนวนนับ ที่มากกว่า 0';
		return -2;
	end

	-- ===================================================================================
	-- STATE-2: ค้นหา
	-- ===================================================================================
	PRINT 'กำลังค้นหา...'

	BEGIN TRY

		IF @Id IS NULL OR @Id<=0
		BEGIN
			SELECT T1.* from TB_SCHEDULED_WEED_ELIMINATION T1			
			WHERE T1.PID = @PlantationID	
			AND T1.STATUS_ID = @act_status
			ORDER BY T1.ACTIVITY_DATE DESC
		END
		ELSE
		BEGIN
			SELECT T1.* from TB_SCHEDULED_WEED_ELIMINATION T1			
			WHERE T1.PID = @PlantationID	
			AND T1.ID = @Id
			AND T1.STATUS_ID = @act_status
			ORDER BY T1.ACTIVITY_DATE DESC
		END
			
		SET @RowCount = @@ROWCOUNT;
			
		print 'Select เสร็จแล้ว'
		IF @RowCount>0 -- พบข้อมูล
		BEGIN
			SET @MessageResult = 'พบข้อมูลกิจกรรมตามตารางงาน';
			return 0
		END
		ELSE -- ไม่พบข้อมูล
		BEGIN
			SET @MessageResult = 'ไม่พบข้อมูลกิจกรรมตามตารางงาน';
			return -1
		END

	END TRY
	BEGIN CATCH
		print 'ERROR'
		SET @RowCount = 0;
		SET @MessageResult = ERROR_MESSAGE();
		return -2
	END CATCH

	-- safety
	return -99

-- จบ
END
