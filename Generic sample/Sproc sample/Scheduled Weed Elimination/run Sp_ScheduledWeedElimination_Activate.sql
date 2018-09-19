USE [DB_TPM2018]
GO

DECLARE	@return_value int,
		@RowCount int,
		@MessageResult nvarchar(200)

EXEC	@return_value = [dbo].[Sp_ScheduledWeedElimination_Activate]
		@Id = 3,
		@UserID = 3,
		@RowCount = @RowCount OUTPUT,
		@MessageResult = @MessageResult OUTPUT

SELECT	@RowCount as N'@RowCount',
		@MessageResult as N'@MessageResult'

SELECT	'Return Value' = @return_value
select * from TB_SCHEDULED_WEED_ELIMINATION
select * from TB_PLANTATION_LOG order by LOG_ID desc

GO
