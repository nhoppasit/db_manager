--USE [DB_TPM2018]
use kasetfms
GO
/****** Object:  StoredProcedure [dbo].[Sp_CommonPreparing_Save]    Script Date: 9/18/2018 7:04:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Sp_ScheduledWeedElimination_Save] --สำคัญ ต้องเปลี่ยนรหัสจากตาราง TB_ACTIVITY_TYPE.ID
	@Pid int,
	@Id bigint,
	@Detail nvarchar(1000), 
	@ActivityDate datetime,
	@WorkArea decimal(9,4),
	@AmountRate decimal(9,2),
	@AdvanceAmount decimal(9,2),
	@TotalAmount decimal(9,2),
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
	DECLARE @ActivityType int = 9; --รหัสจากตาราง TB_ACTIVITY_TYPE.ID
	declare @ActivityName nvarchar(100); SELECT @ActivityName=A.ACTIVITY_TYPE_TH FROM TB_ACTIVITY_TYPE A WHERE A.ID=@ActivityType;

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

	-- ===================================================================================
	-- STATE-2: ตรวจทิศทางการบันทึก การเพิ่มสามารถทำได้เรื่อย ๆ / การแก้ไขก็เช่นกัน
	--      1. id = null --> ระเบียนใหม่/insert อย่างไม่มืเงื่อนไข
	--      2. มี id --> update ข้อมูล + เปิดให้เป็นระเบียนที่ใช้งานได้/active
	-- ===================================================================================
	set @SpState=2;

	-- ===================================================================================
	-- STATE-3: บันทึก (ตามกรณีด้านบน)
	-- ===================================================================================
	set @SpState=3;
	if @Id is null or @Id=0 /* ไม่มีรหัสข้อมูล ให้ลงข้อมูลใหม่ได้ อย่างไม่มีเงื่อนไข*/
	begin
		
		begin try

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
			-- ตรวจเลขโครงการปลูกก่อน
			DECLARE @cnt int = 0;	
			select @cnt = COUNT(T.PID) from TB_PLANTATION T where t.PID=@Pid
			if @cnt<=0
			begin
				set @RowCount = 0;
				set @MessageResult = 'Plantation ผิดพลาด! ไม่พบ Plantation ในฐานข้อมูล';
				return -2;
			end

			-- DO INSERT
			print 'กำลังเพิ่มระเบียนใหม่...'

			INSERT INTO TB_SCHEDULED_WEED_ELIMINATION(
				PID,
				DETAIL,
				ACTIVITY_DATE,
				WORK_AREA,
				AMOUNT_RATE,
				ADVANCE_AMOUNT,
				TOTAL_AMOUNT,
				STATUS_ID,
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY
			) VALUES (
				@Pid,
				@Detail,
				@ActivityDate,
				@WorkArea,
				@AmountRate,
				@AdvanceAmount,
				@TotalAmount,
				@active_row,
				getdate(),
				@UserID,
				getdate(),
				@UserID
			)
			
			set @RowCount = @@ROWCOUNT;
			
			-- เพิ่ม Plantation LOG
			DECLARE @LastActivityId bigint = 0;
			SELECT @LastActivityId = SCOPE_IDENTITY();						
			INSERT INTO TB_PLANTATION_LOG
			(
				PID,
				LOG_NAME,
				LOG_DESC,
				ACTIVITY_DATE,
				ACTIVITY_TYPE_ID,
				ACTIVITY_ID,
				STATUS_ID,
				CREATED_DATE,
				CREATED_BY,
				MODIFIED_DATE,
				MODIFIED_BY			
			) 
			VALUES 
			(
				@Pid,
				@ActivityName,
				@Detail,
				@ActivityDate,
				@ActivityType,
				@LastActivityId,
				@active_row,
				GETDATE(),
				@UserID,
				GETDATE(),
				@UserID
			)
			
			set @RowCount = @RowCount + @@ROWCOUNT;

			-- RETURN
			IF @RowCount>0 -- บันทึก
			BEGIN
				print 'บันทึกแล้ว'
				set @MessageResult = 'เพิ่มข้อมูลกิจกรรมตามตารางงาน เสร็จแล้ว';
				return 0;
			END
			ELSE -- ไม่เกิดอะไรขึ้น
			BEGIN
				print 'ไม่ได้บันทึก'
				set @MessageResult = 'ไม่มีการเพิ่มข้อมูลกิจกรรมตามตารางงาน';
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
		
		begin try

			print 'กำลังแก้ระเบียนให้กลับมาใช้งาน และเปลี่ยนข้อมูลตามที่ได้รับมา...'
			
			-- แก้ไขจุดที่ 1
			update TB_SCHEDULED_WEED_ELIMINATION
			set 
				DETAIL = @Detail,
				ACTIVITY_DATE = @ActivityDate,
				WORK_AREA = @WorkArea,
				AMOUNT_RATE = @AmountRate,
				ADVANCE_AMOUNT = @AdvanceAmount,
				TOTAL_AMOUNT = @TotalAmount,
				STATUS_ID = @active_row,
				MODIFIED_DATE = GETDATE(),
				MODIFIED_BY = @UserID
			where ID=@Id;

			set @RowCount=@@ROWCOUNT;

			-- แก้ไขจุดที่ 2
			UPDATE TB_PLANTATION_LOG
			SET
				LOG_DESC = @Detail,
				ACTIVITY_DATE = @ActivityDate,
				STATUS_ID = @active_row,
				MODIFIED_DATE = GETDATE(),
				MODIFIED_BY =  @UserID
			WHERE ACTIVITY_ID = @Id AND ACTIVITY_TYPE_ID = @ActivityType
						
			set @RowCount= @RowCount + @@ROWCOUNT;

			-- RETURN
			IF @RowCount>0 -- บันทึกแล้ว
			BEGIN
				PRINT 'แก้ไขข้อมูลแล้ว';
				set @MessageResult = 'แก้ไขข้อมูลกิจกรรมตามตารางงาน เรียบร้อยแล้ว';
				return 0
			END
			ELSE -- ไม่เกิดอะไรขึ้น
			BEGIN
				PRINT 'ไม่ได้แก้ไขข้อมูล';
				set @MessageResult = 'ไม่มีการแก้ไขข้อมูลกิจกรรมตามตารางงาน เนื่องจากไม่มีข้อมูลตามรหัสอ้างถึงกิจกรรม (ID)';
				return -1
			END

		end try
		begin catch
			set @RowCount = 0;
			set @MessageResult = ERROR_MESSAGE();
			return -2;
		end catch

	end

	-- safety
	return -99;

/* END */
END
