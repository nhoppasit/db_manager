--USE [DB_TPM2018]
use kasetfms
GO
/****** Object:  StoredProcedure [dbo].[Sp_CommonPreparing_Activate]    Script Date: 9/18/2018 7:24:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Sp_ScheduledWeedElimination_Activate]
	@Id bigint,
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

	-- !! สำคัญ
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
	-- Id
	IF @Id is NULL
	begin
		set @RowCount = 0;
		set @MessageResult = 'รหัสกิจกรรมตามตารางงาน-กำจัดวัชพืช ผิดพลาด! รหัสกิจกรรมตามตารางงาน-กำจัดวัชพืช ไม่สามารถเป็น Null ได้';
		return -2;
	end	
	IF @Id<=0
	begin
		set @RowCount = 0;
		set @MessageResult = 'รหัสกิจกรรมตามตารางงาน-กำจัดวัชพืช ผิดพลาด! รหัสกิจกรรมตามตารางงาน-กำจัดวัชพืช ต้องเป็นรหัสเลขจำนวนนับ ที่มากกว่า 0';
		return -2;
	end	

	-- ===================================================================================
	-- STATE-2: เปลี่ยนสถานะเป็น 20 . เตรียมลบ
	-- ===================================================================================
	set @SpState=2;
	
	begin try

		print 'กำลังแก้ระเบียนให้หยุดใช้งาน...'
			
		-- แก้ไขจุดที่ 1
		update TB_SCHEDULED_WEED_ELIMINATION
		set 
			STATUS_ID = @active_row,
			MODIFIED_DATE = GETDATE(),
			MODIFIED_BY = @UserID
		where ID=@Id;

		set @RowCount=@@ROWCOUNT;

		-- แก้ไขจุดที่ 2
		UPDATE TB_PLANTATION_LOG
		SET
			STATUS_ID = @active_row,
			MODIFIED_DATE = GETDATE(),
			MODIFIED_BY =  @UserID
		WHERE ACTIVITY_ID = @Id AND ACTIVITY_TYPE_ID = @ActivityType
						
		set @RowCount= @RowCount + @@ROWCOUNT;

		-- RETURN
		IF @RowCount>0 -- บันทึกแล้ว
		BEGIN
			PRINT 'แก้ไขข้อมูลแล้ว';
			set @MessageResult = 'เปิดใช้งานข้อมูลกิจกรรมการตามตารางงาน-กำจัดวัชพืช เรียบร้อยแล้ว';
			return 0
		END
		ELSE -- ไม่เกิดอะไรขึ้น
		BEGIN
			PRINT 'ไม่ได้แก้ไขข้อมูล';
			set @MessageResult = 'ไม่มีการแก้ไขข้อมูลกิจกรรมการตามตารางงาน-กำจัดวัชพืช เนื่องจากไม่มีข้อมูลตามรหัสอ้างถึงกิจกรรม (ID)';
			return -1
		END

	end try
	begin catch
		set @RowCount = 0;
		set @MessageResult = ERROR_MESSAGE();
		return -2;
	end catch

	-- safety
	return -99;

/* END */
END
