--USE [DB_TPM2018]
use kasetfms
GO
/****** Object:  StoredProcedure [dbo].[Sp_ScheduledWeedElimination_Delete]    Script Date: 9/18/2018 7:30:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
alter PROCEDURE [dbo].[Sp_ScheduledWeedElimination_Delete]
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
	 * ��Ҥ����
	 *-------------------------------------------------*/
	declare @active_row int; EXEC	@active_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'new'
	declare @deleting_row int; EXEC	@deleting_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'DELETING'
	declare @deleted_row int; EXEC	@deleted_row = [dbo].[Sp_ROW_STATUS] @Keyword = 'deleted'

	-- !! �Ӥѭ
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
	-- Id
	IF @Id is NULL
	begin
		set @RowCount = 0;
		set @MessageResult = '���ʡԨ����������ҧ�ҹ-�ӨѴ�Ѫ�ת �Դ��Ҵ! ���ʡԨ����������ҧ�ҹ-�ӨѴ�Ѫ�ת �������ö�� Null ��';
		return -2;
	end	
	IF @Id<=0
	begin
		set @RowCount = 0;
		set @MessageResult = '���ʡԨ����������ҧ�ҹ-�ӨѴ�Ѫ�ת �Դ��Ҵ! ���ʡԨ����������ҧ�ҹ-�ӨѴ�Ѫ�ת ��ͧ�������Ţ�ӹǹ�Ѻ ����ҡ���� 0';
		return -2;
	end	

	-- ===================================================================================
	-- STATE-2: ����¹ʶҹ��� 20 . �����ź
	-- ===================================================================================
	set @SpState=2;
	
	begin try

		print '���ѧ DELETE ����¹�����ش��ҹ...'
			
		-- ��䢨ش��� 1
		DELETE FROM TB_SCHEDULED_WEED_ELIMINATION
		where ID=@Id;

		set @RowCount=@@ROWCOUNT;

		-- ��䢨ش��� 2
		DELETE FROM TB_PLANTATION_LOG
		WHERE ACTIVITY_ID = @Id AND ACTIVITY_TYPE_ID = @ActivityType
						
		set @RowCount= @RowCount + @@ROWCOUNT;

		-- RETURN
		IF @RowCount>0 -- �ѹ�֡����
		BEGIN
			PRINT 'ź����������';
			set @MessageResult = 'ź�����šԨ������õ�����ҧ�ҹ-�ӨѴ�Ѫ�ת ���º��������';
			return 0
		END
		ELSE -- ����Դ���â��
		BEGIN
			PRINT '�����ź�������';
			set @MessageResult = '����ա��ź�����šԨ������õ�����ҧ�ҹ-�ӨѴ�Ѫ�ת ���ͧ�ҡ����բ����ŵ��������ҧ�֧�Ԩ���� (ID)';
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
