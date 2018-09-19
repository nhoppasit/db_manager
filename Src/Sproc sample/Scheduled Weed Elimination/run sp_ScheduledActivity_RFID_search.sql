USE [DB_TPM2018]
GO

DECLARE	@return_value int,
		@RowCount int,
		@MessageResult nvarchar(200)

EXEC	@return_value = [dbo].[Sp_ScheduledActivityRFID_Search]
		@PlantationID = 1,
		@ActivityTypeId = 9,
		@ActivityId = 5,
		@RowCount = @RowCount OUTPUT,
		@MessageResult = @MessageResult OUTPUT

SELECT	@RowCount as N'@RowCount',
		@MessageResult as N'@MessageResult'

SELECT	'Return Value' = @return_value

GO
