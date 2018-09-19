USE [DB_TPM2018]
GO

DECLARE	@return_value int,
		@RowCount int,
		@MessageResult nvarchar(200)

EXEC	@return_value = [dbo].[Sp_ScheduledWeedElimination_Search]
		@PlantationID = 1,
		@Id = 0,
		@RowCount = @RowCount OUTPUT,
		@MessageResult = @MessageResult OUTPUT

SELECT	@RowCount as N'@RowCount',
		@MessageResult as N'@MessageResult'

SELECT	'Return Value' = @return_value

GO
