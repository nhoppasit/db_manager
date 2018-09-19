--USE [DB_TPM2018]
use kasetfms
GO
/****** Object:  StoredProcedure [dbo].[Sp_CommonPreparing_Save]    Script Date: 9/18/2018 7:04:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[Sp_ScheduledWeedElimination_Save] --�Ӥѭ ��ͧ����¹���ʨҡ���ҧ TB_ACTIVITY_TYPE.ID
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
	 * ��Ҥ����
	 *-------------------------------------------------*/
	declare @active_row int; EXEC	@active_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'new'
	declare @deleting_row int; EXEC	@deleting_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'DELETING'
	declare @deleted_row int; EXEC	@deleted_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'deleted'
	DECLARE @ActivityType int = 9; --���ʨҡ���ҧ TB_ACTIVITY_TYPE.ID
	declare @ActivityName nvarchar(100); SELECT @ActivityName=A.ACTIVITY_TYPE_TH FROM TB_ACTIVITY_TYPE A WHERE A.ID=@ActivityType;

	-- ===================================================================================
	-- STATE-1: VALIDATION
	-- ===================================================================================
	set @SpState = 1;
	
	/*-------------------------------------------------
	 * �� NULL
	 *-------------------------------------------------*/
	-- User id
	IF @UserID is NULL
	begin
		set @RowCount = 0;
		set @MessageResult = 'User �Դ��Ҵ! User �������ö�� Null ��';
		return -2;
	end	
	IF @UserID<=0
	begin
		set @RowCount = 0;
		set @MessageResult = 'User �Դ��Ҵ! User ��ͧ�������Ţ�ӹǹ�Ѻ ����ҡ���� 0';
		return -2;
	end	

	-- ===================================================================================
	-- STATE-2: ��Ǩ��ȷҧ��úѹ�֡ �����������ö���������� � / �����䢡��蹡ѹ
	--      1. id = null --> ����¹����/insert ���ҧ��������͹�
	--      2. �� id --> update ������ + �Դ���������¹�����ҹ��/active
	-- ===================================================================================
	set @SpState=2;

	-- ===================================================================================
	-- STATE-3: �ѹ�֡ (����óմ�ҹ��)
	-- ===================================================================================
	set @SpState=3;
	if @Id is null or @Id=0 /* ��������ʢ����� ���ŧ������������ ���ҧ��������͹�*/
	begin
		
		begin try

			-- CHECK PLANTATION id
			IF @Pid is NULL
			begin
				set @RowCount = 0;
				set @MessageResult = 'Plantation �Դ��Ҵ! Plantation �������ö�� Null ��';
				return -2;
			end			
			IF @Pid<=0
			begin
				set @RowCount = 0;
				set @MessageResult = 'Plantation �Դ��Ҵ! Plantation ��ͧ�������Ţ�ӹǹ�Ѻ ����ҡ���� 0';
				return -2;
			end			
			-- ��Ǩ�Ţ�ç��û�١��͹
			DECLARE @cnt int = 0;	
			select @cnt = COUNT(T.PID) from TB_PLANTATION T where t.PID=@Pid
			if @cnt<=0
			begin
				set @RowCount = 0;
				set @MessageResult = 'Plantation �Դ��Ҵ! ��辺 Plantation 㹰ҹ������';
				return -2;
			end

			-- DO INSERT
			print '���ѧ��������¹����...'

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
			
			-- ���� Plantation LOG
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
			IF @RowCount>0 -- �ѹ�֡
			BEGIN
				print '�ѹ�֡����'
				set @MessageResult = '���������šԨ����������ҧ�ҹ ��������';
				return 0;
			END
			ELSE -- ����Դ���â��
			BEGIN
				print '�����ѹ�֡'
				set @MessageResult = '����ա�����������šԨ����������ҧ�ҹ';
				return -1;
			END
		end try
		begin catch
			set @RowCount = 0;
			set @MessageResult = ERROR_MESSAGE();
			return -2;
		end catch
		
	END
	else -- �����ʢ����� �������¹�ŧ������ ��� ��ʶҹ�����ҹ (1)
	begin
		
		begin try

			print '���ѧ������¹����Ѻ����ҹ �������¹�����ŵ��������Ѻ��...'
			
			-- ��䢨ش��� 1
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

			-- ��䢨ش��� 2
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
			IF @RowCount>0 -- �ѹ�֡����
			BEGIN
				PRINT '��䢢���������';
				set @MessageResult = '��䢢����šԨ����������ҧ�ҹ ���º��������';
				return 0
			END
			ELSE -- ����Դ���â��
			BEGIN
				PRINT '�������䢢�����';
				set @MessageResult = '����ա����䢢����šԨ����������ҧ�ҹ ���ͧ�ҡ����բ����ŵ��������ҧ�֧�Ԩ���� (ID)';
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
