USE [kasetfms]
--use [DB_TPM2018]
GO
/****** Object:  StoredProcedure [dbo].[Sp_ScheduledActivityRFID_SaveATag]    Script Date: 8/28/2018 11:26:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[Sp_ScheduledActivityRFID_SaveATag] 
	@ActivityTypeId int,
	@ActivityId bigint,
	@Pid int,
	@No int,
	@Epc nvarchar(32),	
	@Tid nvarchar(32),	 
	@UserID int,
	@RowCount int output,
	@MessageResult nvarchar(200) output
AS
BEGIN

	-- ===================================================================================
	-- DECLARATION
	-- ===================================================================================
	DECLARE @SpState int = 0;

	/*-------------------------------------------------
	 * ค่าคงที่
	 *-------------------------------------------------*/
	declare @active_row int; EXEC	@active_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'new'
	declare @deleting_row int; EXEC	@deleting_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'DELETING'
	declare @deleted_row int; EXEC	@deleted_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'deleted'

	-- ===================================================================================
	-- STATE-1: VALIDATION
	-- ===================================================================================
	set @SpState = 1;
	
	/*-------------------------------------------------
	 * เช็ค NULL
	 *-------------------------------------------------*/
	-- User id
	IF @UserID is NULL
	begin
		set @RowCount = 0;
		set @MessageResult = 'User ผิดพลาด! User ไม่สามารถเป็น Null ได้';
		return -2;
	end	
	IF @UserID<=0
	begin
		set @RowCount = 0;
		set @MessageResult = 'User ผิดพลาด! User ต้องเป็นรหัสเลขจำนวนนับ ที่มากกว่า 0';
		return -2;
	end	
	-- CHECK PLANTATION id
	IF @Pid is NULL
	begin
		set @RowCount = 0;
		set @MessageResult = 'Plantation ผิดพลาด! Plantation ไม่สามารถเป็น Null ได้';
		return -2;
	end			
	IF @Pid<=0
	begin
		set @RowCount = 0;
		set @MessageResult = 'Plantation ผิดพลาด! Plantation ต้องเป็นรหัสเลขจำนวนนับ ที่มากกว่า 0';
		return -2;
	end			
	-- ตรวจเลขโครงการปลูกก่อน ต้องมีในระบบ
	DECLARE @cnt int = 0;	
	select @cnt = COUNT(T.PID) from TB_PLANTATION T where t.PID=@Pid
	if @cnt<=0
	begin
		set @RowCount = 0;
		set @MessageResult = 'Plantation ผิดพลาด! ไม่พบ Plantation ในฐานข้อมูล';
		return -2;
	end	

	-- ===================================================================================
	-- STATE-2: ตรวจทิศทางการบันทึก การเพิ่มสามารถทำได้เรื่อย ๆ / การแก้ไขก็เช่นกัน
	--      1. tid+pid ไม่พบในตาราง --> ระเบียนใหม่/insert อย่างไม่มืเงื่อนไข
	--      2. มี tid+pid แล้ว --> update ข้อมูล + เปิดให้เป็นระเบียนที่ใช้งานได้/active
	-- ===================================================================================
	set @SpState=2;
	select @cnt = COUNT(T.EPC) from TB_SCHEDULED_ACTIVITY_RFID T WHERE T.PID=@Pid AND T.EPC = @Epc AND T.ACTIVITY_TYPE_ID=@ActivityTypeId AND T.ACTIVITY_ID=@ActivityId

	if @cnt<=0 /* ไม่มีรหัสข้อมูล ให้ลงข้อมูลใหม่ได้ อย่างไม่มีเงื่อนไข*/
	begin
		
		begin try
			
			-- DO INSERT
			print 'กำลังเพิ่มระเบียนใหม่...'

			INSERT INTO TB_SCHEDULED_ACTIVITY_RFID
			(
				ACTIVITY_TYPE_ID,
				ACTIVITY_ID,
				PID,
				TAG_ORDER_NO,
				EPC,
				TID,
				STATUS_ID,
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY
			) 
			VALUES 
			(
				@ActivityTypeId,
				@ActivityId,
				@Pid,
				@No,
				@Epc,
				@Tid,
				@active_row,
				getdate(),
				@UserID,
				getdate(),
				@UserID
			)
			
			set @RowCount = @@ROWCOUNT;
			
			-- RETURN
			IF @RowCount>0 -- บันทึก
			BEGIN
				print 'บันทึกแล้ว'
				set @MessageResult = 'เพิ่มข้อมูลกิจกรรมตามตารางงาน-รายการ RFID เสร็จแล้ว (Pid = ' + RTRIM(CAST(@Pid AS nvarchar(4))) + ', ' + RTRIM(CAST(@No AS nvarchar(4))) + ', ' + RTRIM(CAST(@Epc AS nvarchar(32))) + ', ' + RTRIM(CAST(@Tid AS nvarchar(32))) + ')';
				return 0;
			END
			ELSE -- ไม่เกิดอะไรขึ้น
			BEGIN
				print 'ไม่ได้บันทึก'
				set @MessageResult = 'ไม่มีการเพิ่มข้อมูลกิจกรรมฯการปลูก-รายการ RFID (Pid = '+ RTRIM(CAST(@Pid AS nvarchar(4))) + ', ' + RTRIM(CAST(@No AS nvarchar(4))) + ', ' + RTRIM(CAST(@Epc AS nvarchar(32))) + ', ' + RTRIM(CAST(@Tid AS nvarchar(32))) + ')';
				return -1;
			END
		end try
		begin catch
			set @RowCount = 0;
			set @MessageResult = ERROR_MESSAGE();
			return -2;
		end catch
		
	END
	else -- มีรหัสข้อมูล ให้เปลี่ยนแปลงข้อมูล และ แก้สถานะเป็นใช้งาน (1)
	begin

		PRINT 'ไม่ได้บันทึกหรือแก้ไขข้อมูล';
		set @RowCount = 0;
		set @MessageResult = 'มีข้อมูลแล้ว ไม่มีการบันทึกหรือแก้ไขข้อมูลกิจกรรมตามตารางงาน-รายการ RFID (Pid = ' + RTRIM(CAST(@Pid AS nvarchar(4))) + ', ' + RTRIM(CAST(@No AS nvarchar(4))) + ', ' + RTRIM(CAST(@Epc AS nvarchar(32))) + ', ' + RTRIM(CAST(@Tid AS nvarchar(32))) + ')';
		return -1

	end

	-- safety
	return -99;

/* END */
END
