using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using DB_Management.Generic;

namespace Tpm2018API
{
    /// <summary>
    /// Summary description for ScheduledWeedElimination
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    // To allow this Web Service to be called from script, using ASP.NET AJAX, uncomment the following line. 
    // [System.Web.Script.Services.ScriptService]
    public class ScheduledWeedElimination : System.Web.Services.WebService
    {
        [WebMethod(Description = "Search scheduled weed elimination activity by plantation ID.")]
        public ResultModelType Search(int PlantationId, long Id)
        {
            try
            {
                using (GenericManagement db = new GenericManagement())
                {
                    ResultModelType result = new ResultModelType();
                    //create PROCEDURE[dbo].[Sp_ScheduledWeedElimination_Search]
                    //    @PlantationID int,
                    //    @Id bigint,
                    //    @RowCount int output,
                    //    @MessageResult nvarchar(200) OUTPUT
                    string SprocName = "Sp_ScheduledWeedElimination_Search";
                    Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                    {
                        { "@PlantationID", new ParameterStructure("@PlantationID", System.Data.SqlDbType.Int, PlantationId) },
                        { "@Id", new ParameterStructure("@Id", System.Data.SqlDbType.BigInt, Id) }
                    };
                    Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                    {
                        { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                        { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 200) }
                    };
                    result.DataSetResult = db.ExecuteToDataSet(SprocName, Inputs, out int returnValue, ref Output);
                    int rowCount = Convert.ToInt32(Output["@RowCount"].dbValue);
                    result.Code = returnValue;
                    result.RowCount = rowCount;
                    result.Message = Output["@MessageResult"].dbValue.ToString();
                    result.Flag = returnValue == 0 && rowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex) { return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, }; }
        }

        [WebMethod(Description = "Save a scheduled weed elimination activity. This is more than one record per plantation.")]
        public ResultModelType Save(int PlantationId, long Id, string Detail, DateTime ActivityDate, decimal WorkArea, decimal AmountRate, decimal AdvanceAmount, decimal TotalAmount, int UserId)
        {
            try
            {
                using (GenericManagement db = new GenericManagement())
                {
                    ResultModelType result = new ResultModelType();
                    //create PROCEDURE[dbo].[Sp_ScheduledWeedElimination_Save] --สำคัญ ต้องเปลี่ยนรหัสจากตาราง TB_ACTIVITY_TYPE.ID
                    //    @Pid int,
                    //    @Id bigint,
                    //    @Detail nvarchar(1000), 
                    //    @ActivityDate datetime,
                    //    @WorkArea decimal (9,4),
                    //    @AmountRate decimal (9,2),
                    //    @AdvanceAmount decimal (9,2),
                    //    @TotalAmount decimal (9,2),
                    //    @UserID int,
                    //    @RowCount int output,
                    //    @MessageResult nvarchar(200) output
                    string SprocName = "Sp_ScheduledWeedElimination_Save";
                    Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                    {
                        { "@Pid", new ParameterStructure("@Pid", System.Data.SqlDbType.Int, PlantationId) },
                        { "@Id", new ParameterStructure("@Id", System.Data.SqlDbType.BigInt, Id) },
                        { "@Detail", new ParameterStructure("@Detail", System.Data.SqlDbType.NVarChar, Detail) },
                        { "@ActivityDate", new ParameterStructure("@ActivityDate", System.Data.SqlDbType.DateTime, ActivityDate) },
                        { "@WorkArea", new ParameterStructure("@WorkArea", System.Data.SqlDbType.Decimal, WorkArea) },
                        { "@AmountRate", new ParameterStructure("@AmountRate", System.Data.SqlDbType.Decimal, AmountRate) },
                        { "@AdvanceAmount", new ParameterStructure("@AdvanceAmount", System.Data.SqlDbType.Decimal, AdvanceAmount) },
                        { "@TotalAmount", new ParameterStructure("@TotalAmount", System.Data.SqlDbType.Decimal, TotalAmount) },
                        { "@UserId", new ParameterStructure("@UserId", System.Data.SqlDbType.Int, UserId) }
                    };
                    Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                    {
                        { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                        { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 200) }
                    };
                    db.ExecuteNonQuery(SprocName, Inputs, out int returnValue, ref Output);
                    int rowCount = Convert.ToInt32(Output["@RowCount"].dbValue);
                    result.Code = returnValue;
                    result.RowCount = rowCount;
                    result.Message = Output["@MessageResult"].dbValue.ToString();
                    result.Flag = returnValue == 0 && rowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex)
            {
                return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, };
            }
        }

        [WebMethod(Description = "Activate a scheduled weed elimination activity")]
        public ResultModelType Activate(long Id, int UserId)
        {
            try
            {
                using (GenericManagement db = new GenericManagement())
                {
                    ResultModelType result = new ResultModelType();
                    //create PROCEDURE[dbo].[Sp_ScheduledWeedElimination_Activate]
                    //    @Id bigint,
                    //    @UserID int,
                    //    @RowCount int output,
                    //    @MessageResult nvarchar(200) output
                    string SprocName = "Sp_ScheduledWeedElimination_Activate";
                    Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                    {
                        { "@Id", new ParameterStructure("@Id", System.Data.SqlDbType.BigInt, Id) },
                        { "@UserId", new ParameterStructure("@UserId", System.Data.SqlDbType.Int, UserId) }
                    };
                    Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                    {
                        { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                        { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 200) }
                    };
                    db.ExecuteNonQuery(SprocName, Inputs, out int returnValue, ref Output);
                    int rowCount = Convert.ToInt32(Output["@RowCount"].dbValue);
                    result.Code = returnValue;
                    result.RowCount = rowCount;
                    result.Message = Output["@MessageResult"].dbValue.ToString();
                    result.Flag = returnValue == 0 && rowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex)
            {
                return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, };
            }
        }

        [WebMethod(Description = "Deactivate a scheduled weed elimination activity")]
        public ResultModelType Deactivate(long Id, int UserId)
        {
            try
            {
                using (GenericManagement db = new GenericManagement())
                {
                    ResultModelType result = new ResultModelType();
                    //create PROCEDURE[dbo].[Sp_ScheduledWeedElimination_Deactivate]
                    //    @Id bigint,
                    //    @UserID int,
                    //    @RowCount int output,
                    //    @MessageResult nvarchar(200) output
                    string SprocName = "Sp_ScheduledWeedElimination_Deactivate";
                    Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                    {
                        { "@Id", new ParameterStructure("@Id", System.Data.SqlDbType.BigInt, Id) },
                        { "@UserId", new ParameterStructure("@UserId", System.Data.SqlDbType.Int, UserId) }
                    };
                    Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                    {
                        { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                        { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 200) }
                    };
                    db.ExecuteNonQuery(SprocName, Inputs, out int returnValue, ref Output);
                    int rowCount = Convert.ToInt32(Output["@RowCount"].dbValue);
                    result.Code = returnValue;
                    result.RowCount = rowCount;
                    result.Message = Output["@MessageResult"].dbValue.ToString();
                    result.Flag = returnValue == 0 && rowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex)
            {
                return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, };
            }
        }

        [WebMethod(Description = "Delete a scheduled weed elimination activity")]
        public ResultModelType Delete(long Id, int UserId)
        {
            try
            {
                using (GenericManagement db = new GenericManagement())
                {
                    ResultModelType result = new ResultModelType();
                    //alter PROCEDURE[dbo].[Sp_ScheduledWeedElimination_Delete]
                    //    @Id bigint,
                    //    @UserID int,
                    //    @RowCount int output,
                    //    @MessageResult nvarchar(200) output
                    string SprocName = "Sp_ScheduledWeedElimination_Delete";
                    Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                    {
                        { "@Id", new ParameterStructure("@Id", System.Data.SqlDbType.BigInt, Id) },
                        { "@UserId", new ParameterStructure("@UserId", System.Data.SqlDbType.Int, UserId) }
                    };
                    Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                    {
                        { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                        { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 200) }
                    };
                    db.ExecuteNonQuery(SprocName, Inputs, out int returnValue, ref Output);
                    int rowCount = Convert.ToInt32(Output["@RowCount"].dbValue);
                    result.Code = returnValue;
                    result.RowCount = rowCount;
                    result.Message = Output["@MessageResult"].dbValue.ToString();
                    result.Flag = returnValue == 0 && rowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex)
            {
                return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, };
            }
        }

        int ActivityTypeId = 9;

        [WebMethod(Description = "Search activity RFID by plantation ID and activity ID.")]
        public ResultModelType RfidSearch(int PlantationId, long ActivityId)
        {
            try
            {
                using (GenericManagement db = new GenericManagement())
                {
                    ResultModelType result = new ResultModelType();
                    //ALTER PROCEDURE[dbo].[Sp_ScheduledActivityRFID_Search]
                    //    @PlantationID int,
                    //    @ActivityTypeId int,
                    //    @ActivityId bigint,
                    //    @RowCount int output,
                    //    @MessageResult nvarchar(200) OUTPUT
                    string SprocName = "Sp_ScheduledActivityRFID_Search";
                    Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                    {
                        { "@PlantationID", new ParameterStructure("@PlantationID", System.Data.SqlDbType.Int, PlantationId) },
                        { "@ActivityTypeId", new ParameterStructure("@ActivityTypeId", System.Data.SqlDbType.Int, ActivityTypeId) },
                        { "@ActivityId", new ParameterStructure("@ActivityId", System.Data.SqlDbType.BigInt, ActivityId) }
                    };
                    Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                    {
                        { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                        { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 200) }
                    };
                    result.DataSetResult = db.ExecuteToDataSet(SprocName, Inputs, out int returnValue, ref Output);
                    int rowCount = Convert.ToInt32(Output["@RowCount"].dbValue);
                    result.Code = returnValue;
                    result.RowCount = rowCount;
                    result.Message = Output["@MessageResult"].dbValue.ToString();
                    result.Flag = returnValue == 0 && rowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex) { return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, }; }
        }

        [WebMethod(Description = "Delete weed elimination RFIDs by plantation ID and activity ID.")]
        public ResultModelType RfidDeleteAll(int PlantationId, long ActivityId)
        {
            try
            {
                using (GenericManagement db = new GenericManagement())
                {
                    //ALTER PROCEDURE[dbo].[Sp_ScheduledActivityRFID_DeleteAll]
                    //    @PlantationID int,
                    //    @ActivityTypeId int,
                    //    @ActivityId bigint,
                    //    @RowCount int output,
                    //    @MessageResult nvarchar(200) OUTPUT
                    ResultModelType result = new ResultModelType();
                    string SprocName = "Sp_ScheduledActivityRFID_DeleteAll";
                    Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                    {
                        { "@PlantationID", new ParameterStructure("@PlantationID", System.Data.SqlDbType.Int, PlantationId) },
                        { "@ActivityTypeId", new ParameterStructure("@ActivityTypeId", System.Data.SqlDbType.Int, ActivityTypeId) },
                        { "@ActivityId", new ParameterStructure("@ActivityId", System.Data.SqlDbType.BigInt, ActivityId) }
                    };
                    Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                    {
                        { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                        { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 100) }
                    };
                    result.DataSetResult = db.ExecuteToDataSet(SprocName, Inputs, out int returnValue, ref Output);
                    int rowCount = Convert.ToInt32(Output["@RowCount"].dbValue);
                    result.Code = returnValue;
                    result.RowCount = rowCount;
                    result.Message = Output["@MessageResult"].dbValue.ToString();
                    result.Flag = returnValue == 0 && rowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex) { return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, }; }
        }
        
        [WebMethod(Description = "Save weed elimination RFIDs. This preparing RFID can has only many more records per activity.")]
        public ResultModelType RfidSave(int PlantationId, long ActivityId, int[] No, string[] EPC, string[] TID, int UserId)
        {
            try
            {
                if (No.Length != EPC.Length) return new ResultModelType() { Code = -3, Message = "Asmx service error! Length of EPC array miss match with No array", };
                if (No.Length != TID.Length) return new ResultModelType() { Code = -3, Message = "Asmx service error! Length of TID array miss match with No array", };
                if (EPC.Length != TID.Length) return new ResultModelType() { Code = -3, Message = "Asmx service error! Length of EPC array miss match with TID array", };

                //alter PROCEDURE[dbo].[Sp_ScheduledActivityRFID_SaveATag]
                //    @ActivityTypeId int,
                //    @ActivityId bigint,
                //    @Pid int,
                //    @No int,
                //    @Epc nvarchar(32),	
                //    @Tid nvarchar(32),	 
                //    @UserID int,
                //    @RowCount int output,
                //    @MessageResult nvarchar(200) output

                using (GenericManagement db = new GenericManagement())
                {
                    ResultModelType result = new ResultModelType();
                    List<SaveStructure> argInOuts = new List<SaveStructure>();
                    for (int tagIdx = 0; tagIdx < EPC.Length; tagIdx++)
                    {
                        Dictionary<string, ParameterStructure> Inputs = new Dictionary<string, ParameterStructure>()
                        {
                                { "@ActivityTypeId", new ParameterStructure("@ActivityTypeId", System.Data.SqlDbType.Int, ActivityTypeId)},
                                { "@ActivityId", new ParameterStructure("@ActivityId", System.Data.SqlDbType.BigInt, ActivityId)},
                                { "@Pid", new ParameterStructure("@Pid", System.Data.SqlDbType.Int, PlantationId)},

                                { "@No", new ParameterStructure("@No", System.Data.SqlDbType.Int, No[tagIdx]) },
                                { "@Epc", new ParameterStructure("@Epc", System.Data.SqlDbType.NVarChar, EPC[tagIdx]) },
                                { "@Tid", new ParameterStructure("@Tid", System.Data.SqlDbType.NVarChar, TID[tagIdx]) },

                                { "@UserID", new ParameterStructure("@UserID", System.Data.SqlDbType.Int, UserId) }
                            };

                        Dictionary<string, ParameterStructure> Output = new Dictionary<string, ParameterStructure>()
                        {
                            { "@RowCount", new ParameterStructure("@RowCount", System.Data.SqlDbType.Int)},
                            { "@MessageResult", new ParameterStructure("@MessageResult", System.Data.SqlDbType.NVarChar, null, 200) }
                        };
                        argInOuts.Add(new SaveStructure { Inputs = Inputs, Output = Output, ReturnValue = -99 });
                    }

                    db.ExecuteNonQuery("Sp_ScheduledActivityRFID_SaveATag", ref argInOuts);

                    result.RowCount = 0;
                    result.DataObjects = new object[2];
                    result.DataTexts = new string[argInOuts.Count];
                    int[] Codes = new int[argInOuts.Count];
                    int[] RowCounts = new int[argInOuts.Count];
                    for (int i = 0; i < argInOuts.Count; i++)
                    {
                        Codes[i] = argInOuts[i].ReturnValue;
                        RowCounts[i] = Convert.ToInt32(argInOuts[i].Output["@RowCount"].dbValue);
                        result.RowCount += RowCounts[i];
                        result.DataTexts[i] = argInOuts[i].Output["@MessageResult"].dbValue.ToString();
                    }
                    result.DataObjects[0] = Codes;
                    result.DataObjects[1] = RowCounts;
                    result.Code = 0;
                    result.Message = "ข้อความสรุปอยู่ใน DataTexts, Code อยู่ใน DataObjects[0], และ RowCount แค่ละ Save อยู่ที่ DataObjects[1]";
                    result.Flag = result.Code == 0 && result.RowCount > 0 ? true : false;
                    return result;
                }
            }
            catch (Exception ex)
            {
                return new ResultModelType() { Code = -3, Message = "Asmx service error! " + Environment.NewLine + ex.Message, };
            }
        }

    }
}
