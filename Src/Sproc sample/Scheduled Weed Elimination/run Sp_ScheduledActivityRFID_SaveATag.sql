USE [DB_TPM2018]
GO

DECLARE	@return_value int,
		@RowCount int,
		@MessageResult nvarchar(200)

EXEC	@return_value = [dbo].[Sp_ScheduledActivityRFID_SaveATag]
		@ActivityTypeId = 9,
		@ActivityId = 6,
		@Pid = 1,
		@No = 1,
		@Epc = 'kkk',
		@Tid = '',
		@UserID = 3,
		@RowCount = @RowCount OUTPUT,
		@MessageResult = @MessageResult OUTPUT

SELECT	@RowCount as N'@RowCount',
		@MessageResult as N'@MessageResult'

SELECT	'Return Value' = @return_value

select * from TB_SCHEDULED_ACTIVITY_RFID

GO
