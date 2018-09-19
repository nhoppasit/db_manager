--USE [DB_TPM2018]
USE [kasetfms]
GO
/****** Object:  StoredProcedure [dbo].[Sp_ScheduledActivityRFID_DeleteAll]    Script Date: 9/18/2018 9:17:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
alter PROCEDURE [dbo].[Sp_ScheduledActivityRFID_DeleteAll]  
	@PlantationID int,
	@ActivityTypeId int,
	@ActivityId bigint,
	@RowCount int output,
	@MessageResult nvarchar(200) OUTPUT
AS
BEGIN	
	
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

		DELETE from TB_SCHEDULED_ACTIVITY_RFID 
		WHERE PID = @PlantationID	
		AND ACTIVITY_TYPE_ID=@ActivityTypeId
		AND ACTIVITY_ID=@ActivityId
			
		SET @RowCount = @@ROWCOUNT;
			
		print 'Select เสร็จแล้ว'
		IF @RowCount>0 -- พบข้อมูล
		BEGIN
			SET @MessageResult = 'ลบข้อมูลกิจกรรมตามตารางงาน - รายการ RFID';
			return 0
		END
		ELSE -- ไม่พบข้อมูล
		BEGIN
			SET @MessageResult = 'ไม่พบข้อมูลกิจกรรมตามตารางงาน - รายการ RFID';
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
