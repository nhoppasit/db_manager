using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Data.SqlClient;

namespace DB_Management.Generic
{
    public class GenericManagement : IDbCommand, IDisposable
    {
        public DataSet ExecuteToDataSet(string sprocName, Dictionary<string, ParameterStructure> inputs, out int returnValue, ref Dictionary<string, ParameterStructure> output)
        {
            try
            {
                returnValue = -99;
                DataSet ds = new DataSet();

                // -------------------------------------------
                // Store procedure
                // -------------------------------------------
                DbCallback.SetCommandStoredProcedure(sprocName); // all parameters cleared

                // -------------------------------------------
                // input parameters
                // -------------------------------------------
                if (inputs != null)
                {
                    foreach (KeyValuePair<string, ParameterStructure> param in inputs)
                    {
                        DbCallback.AddInputParameter(param.Value.Name, param.Value.sqlDbType, param.Value.dbValue);
                    }
                }

                // -------------------------------------------
                // output parameters
                // -------------------------------------------
                if (output != null)
                {
                    foreach (KeyValuePair<string, ParameterStructure> param in output)
                    {
                        if (param.Value.Size <= 0) DbCallback.AddOutputParameter(param.Value.Name, param.Value.sqlDbType);
                        else DbCallback.AddOutputParameter(param.Value.Name, param.Value.sqlDbType, param.Value.Size);
                    }
                }

                // -------------------------------------------
                // Set return
                // -------------------------------------------
                DbCallback.SetReturnValue();

                // -------------------------------------------
                // Execute
                // -------------------------------------------
                ds = DbCallback.ExecuteToDataSet();

                // -------------------------------------------
                // Get output parameters
                // -------------------------------------------
                if (output != null)
                {
                    foreach (KeyValuePair<string, ParameterStructure> param in output)
                    {
                        param.Value.dbValue = DbCallback.OutputParameterToObject(param.Value.Name);
                    }
                }

                // -------------------------------------------
                // Return value
                // -------------------------------------------
                returnValue = DbCallback.GetReturnValue();

                // -------------------------------------------
                // Return DataSet
                // -------------------------------------------
                if (ds != null) return ds;

                // -------------------------------------------
                // safety
                // -------------------------------------------
                return null;
            }
            catch (Exception ex)
            {
                DbCallback.CloseConnection();
                throw ex;
            }
        }

        public void ExecuteNonQuery(string sprocName, Dictionary<string, ParameterStructure> inputs, out int returnValue, ref Dictionary<string, ParameterStructure> output)
        {
            try
            {
                // ------------------------------------------------
                // Initialize return value
                // ------------------------------------------------
                returnValue = -99;
                //rowCount = 0;
                //message = "";

                // ------------------------------------------------
                // Stroe procedure name
                // ------------------------------------------------
                DbCallback.SetCommandStoredProcedure(sprocName);

                // ------------------------------------------------
                // Input parameters
                // ------------------------------------------------
                if (inputs != null)
                {
                    foreach (KeyValuePair<string, ParameterStructure> e in inputs)
                    {
                        DbCallback.AddInputParameter(e.Value.Name, e.Value.sqlDbType, e.Value.dbValue);
                    }
                }
                //DbCallback.AddInputParameter("@Pid", SqlDbType.Int, e.PlantationId);
                //DbCallback.AddInputParameter("@Id", SqlDbType.BigInt, e.Id);
                //DbCallback.AddInputParameter("@Species", SqlDbType.NVarChar, e.Species);
                //DbCallback.AddInputParameter("@Detail", SqlDbType.NVarChar, e.Detail);
                //DbCallback.AddInputParameter("@ActivityDate", SqlDbType.DateTime, e.ActivityDate);
                //DbCallback.AddInputParameter("@PlantCount", SqlDbType.Int, e.PlantCount);
                //DbCallback.AddInputParameter("@PlantHeight", SqlDbType.Decimal, e.PlantHeight);
                //DbCallback.AddInputParameter("@AmountRate", SqlDbType.Decimal, e.AmountRate);
                //DbCallback.AddInputParameter("@AdvanceAmount", SqlDbType.Decimal, e.AdvanceAmount);
                //DbCallback.AddInputParameter("@TotalAmount", SqlDbType.Decimal, e.TotalAmount);
                //DbCallback.AddInputParameter("@UserID", SqlDbType.Int, e.UserId);

                // ------------------------------------------------
                // Output parameters
                // ------------------------------------------------
                if (output != null)
                {
                    foreach (KeyValuePair<string, ParameterStructure> e in output)
                    {
                        if (e.Value.Size <= 0) DbCallback.AddOutputParameter(e.Value.Name, e.Value.sqlDbType);
                        else DbCallback.AddOutputParameter(e.Value.Name, e.Value.sqlDbType, e.Value.Size);
                    }
                }
                //DbCallback.AddOutputParameter("@IntResult", SqlDbType.Int);
                //DbCallback.AddOutputParameter("@MessageResult", SqlDbType.NVarChar, 100);

                // ------------------------------------------------
                // Set return value
                // ------------------------------------------------
                DbCallback.SetReturnValue();

                // ------------------------------------------------
                // Execute
                // ------------------------------------------------
                DbCallback.ExecuteNonQuery();

                // ------------------------------------------------
                // Get return output value
                // ------------------------------------------------
                if (output != null)
                {
                    foreach (KeyValuePair<string, ParameterStructure> e in output)
                    {
                        e.Value.dbValue = DbCallback.OutputParameterToObject(e.Value.Name);
                    }
                }
                //rowCount = DbCallback.OutputParameterToInt("@IntResult");
                //message = DbCallback.OutputParameterToString("@MessageResult");

                // ------------------------------------------------
                // Stroe procedure name
                // ------------------------------------------------
                returnValue = DbCallback.GetReturnValue();
            }
            catch (Exception ex)
            {
                DbCallback.CloseConnection();
                throw ex;
            }
        }

        public void ExecuteNonQuery(string sprocName, ref List<SaveStructure> e)
        {
            // ------------------------------------------------
            // Transaction loop
            // ------------------------------------------------                
            SqlConnection conn = new SqlConnection(DbCallback.ConnectionString);
            conn.Open();
            SqlTransaction tx = conn.BeginTransaction();
            bool CatchFlag = false;
            Exception _ex;
            try
            {
                for (int i = 0; i < e.Count; i++)
                {
                    SaveStructure arg = e[i];

                    // ------------------------------------------------
                    // Initialize return value
                    // ------------------------------------------------
                    arg.ReturnValue = -99;

                    // ------------------------------------------------
                    // Stroe procedure name
                    // ------------------------------------------------
                    DbCallback.SetCommandStoredProcedure(sprocName);

                    // ------------------------------------------------
                    // Input parameters
                    // ------------------------------------------------
                    if (arg.Inputs != null)
                    {
                        foreach (KeyValuePair<string, ParameterStructure> input in arg.Inputs)
                        {
                            DbCallback.AddInputParameter(input.Value.Name, input.Value.sqlDbType, input.Value.dbValue);
                        }
                    }

                    // ------------------------------------------------
                    // Output parameters
                    // ------------------------------------------------
                    if (arg.Output != null)
                    {
                        foreach (KeyValuePair<string, ParameterStructure> output in arg.Output)
                        {
                            if (output.Value.Size <= 0) DbCallback.AddOutputParameter(output.Value.Name, output.Value.sqlDbType);
                            else DbCallback.AddOutputParameter(output.Value.Name, output.Value.sqlDbType, output.Value.Size);
                        }
                    }

                    // ------------------------------------------------
                    // Set return value
                    // ------------------------------------------------
                    DbCallback.SetReturnValue();

                    // ------------------------------------------------
                    // Execute!
                    // ------------------------------------------------
                    DbCallback.ExecuteNonQuery(conn, tx);

                    // ------------------------------------------------
                    // Get return output value
                    // ------------------------------------------------
                    if (arg.Output != null)
                    {
                        foreach (KeyValuePair<string, ParameterStructure> output in arg.Output)
                        {
                            output.Value.dbValue = DbCallback.OutputParameterToObject(output.Value.Name);
                        }
                    }

                    // ------------------------------------------------
                    // Stroe procedure name
                    // ------------------------------------------------
                    arg.ReturnValue = DbCallback.GetReturnValue();

                    // ------------------------------------------------
                    // Stroe procedure validation failed!
                    // ------------------------------------------------
                    if (arg.ReturnValue == -2)
                    {
                        if (arg.Output.ContainsKey("@MessageResult"))
                        {
                            throw new Exception(arg.Output["@MessageResult"].dbValue.ToString());
                        }
                        else if (arg.Output.ContainsKey("MessageResult"))
                        {
                            throw new Exception(arg.Output["MessageResult"].dbValue.ToString());
                        }
                        else
                        {
                            throw new Exception("Return value equals -2. It means there is some error ing store procedure.");
                        }
                    }
                }

                tx.Commit();
                CatchFlag = false;
                _ex = null;
            }
            catch (Exception ex)
            {
                tx.Rollback();
                DbCallback.CloseConnection();
                CatchFlag = true;
                _ex = ex;
            }
            conn.Close();
            if (CatchFlag) throw _ex;
        }

    }

    public class ParameterStructure
    {
        public string Name { get; set; }
        public SqlDbType sqlDbType { get; set; }
        public int Size { get; set; }
        public object dbValue { get; set; }
        public ParameterStructure(string name, SqlDbType type, object value = null, int size = 0)
        {
            this.Name = name;
            this.sqlDbType = type;
            this.dbValue = value;
            this.Size = size;
        }
    }

    /// <summary>
    /// ตัวแปรสำหรับรับค่าข้อมูลเพื่อบันทึก
    /// </summary>
    public class SaveStructure
    {
        public Dictionary<string, ParameterStructure> Inputs { get; set; }
        public int ReturnValue { get; set; }
        public Dictionary<string, ParameterStructure> Output { get; set; }
    }

}
