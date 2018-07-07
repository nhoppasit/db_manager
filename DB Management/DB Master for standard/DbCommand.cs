using System;
using System.Data;
using System.Data.SqlClient;

namespace DB_Manager
{
    public class DbCommand : IDisposable
    {
        #region Dispose

        // Implement IDisposable. 
        // Do not make this method virtual. 
        // A derived class should not be able to override this method. 
        private bool disposed = false;
        public void Dispose()
        {
            Dispose(true);
            // This object will be cleaned up by the Dispose method. 
            // Therefore, you should call GC.SupressFinalize to 
            // take this object off the finalization queue 
            // and prevent finalization code for this object 
            // from executing a second time.
            GC.SuppressFinalize(this);
        }

        // Dispose(bool disposing) executes in two distinct scenarios. 
        // If disposing equals true, the method has been called directly 
        // or indirectly by a user's code. Managed and unmanaged resources 
        // can be disposed. 
        // If disposing equals false, the method has been called by the 
        // runtime from inside the finalizer and you should not reference 
        // other objects. Only unmanaged resources can be disposed. 
        protected virtual void Dispose(bool disposing)
        {
            // Check to see if Dispose has already been called. 
            if (!this.disposed)
            {
                // If disposing equals true, dispose all managed 
                // and unmanaged resources. 
                if (disposing)
                {
                    // Dispose managed resources.
                    this.CloseConnection();
                    this.ReturnConnection();
                }

                // Call the appropriate methods to clean up 
                // unmanaged resources here. 
                // If disposing is false, 
                // only the following code is executed.                                

                // Note disposing has been done.
                disposed = true;
            }
        }

        #endregion

        #region Variables

        /// <summary>
        /// Get connection string of BO23 database
        /// </summary>
        public string ConnectionString { get; private set; }
        private Object _SqlCommand;
        private int _TIMEOUT = 14400;

        #endregion

        #region Constructor & destructor

        public DbCommand()
        {
            //ConnectionString = Properties.Settings.Default.ConnectionString + ";Password=" + DB_Security.Settings.Password;
            ConnectionString = DB_Security.Settings.ConnectionString;
            _SqlCommand = new SqlCommand();
        }
        ~DbCommand() { Dispose(); }

        #endregion

        #region Set command

        public void SetCommandText(string cmdText)
        {
            ((SqlCommand)(this._SqlCommand)).Parameters.Clear();
            ((SqlCommand)(this._SqlCommand)).CommandText = cmdText;
            ((SqlCommand)(this._SqlCommand)).CommandType = CommandType.Text;
        }
        public void SetCommandStoredProcedure(string storedProcName)
        {
            // ((SqlCommand)(this._SqlCommand)).Parameters.Clear();
            ((SqlCommand)(this._SqlCommand)).CommandText = storedProcName;
            ((SqlCommand)(this._SqlCommand)).CommandType = CommandType.StoredProcedure;
        }
        public void AddInputParameter(string paramName, SqlDbType paramType, object paramValue)
        {
            SqlParameter param = new SqlParameter(paramName, paramType);
            param.Value = paramValue;
            param.Direction = ParameterDirection.Input;
            ((SqlCommand)(this._SqlCommand)).Parameters.Add(param);

        }

        #endregion

        #region Execute

        public DataSet ExecuteToDataSet()
        {
            DataSet dts = new DataSet();
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = this.ConnectionString;
                ((SqlCommand)(this._SqlCommand)).Connection = conn;
                //((SqlCommand)(this._SqlCommand)).CommandTimeout = _TIMEOUT;
                SqlDataAdapter adapter = new SqlDataAdapter(((SqlCommand)(this._SqlCommand)));
                adapter.Fill(dts);
            }
            return dts;
        }
        public DataSet ExecuteToDataSet(DataSet typedDataSet, string tableName)
        {
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = this.ConnectionString;
                ((SqlCommand)(this._SqlCommand)).Connection = conn;
                ((SqlCommand)(this._SqlCommand)).CommandTimeout = _TIMEOUT;
                SqlDataAdapter adapter = new SqlDataAdapter(((SqlCommand)(this._SqlCommand)));
                adapter.Fill(typedDataSet, tableName);
            }

            return typedDataSet;
        }
        public int ExecuteNonQuery()
        {
            int result = 0;
            using (SqlConnection conn = new SqlConnection())
            {
                conn.ConnectionString = this.ConnectionString;
                ((SqlCommand)(this._SqlCommand)).Connection = conn;
                //((SqlCommand)(this._SqlCommand)).CommandTimeout = _TIMEOUT;
                this.OpenConnection();
                result = ((SqlCommand)(this._SqlCommand)).ExecuteNonQuery();
                this.CloseConnection();
            }
            return result;
        }
        public int ExecuteNonQuery(SqlConnection conn, SqlTransaction tx)
        {
            int result = 0;
            try
            {
                conn.ConnectionString = this.ConnectionString;
                ((SqlCommand)(this._SqlCommand)).Connection = conn;
                //((SqlCommand)(this._SqlCommand)).CommandTimeout = _TIMEOUT;
                this.OpenConnection();
                tx = conn.BeginTransaction();
                ((SqlCommand)(this._SqlCommand)).Transaction = tx;
                result = ((SqlCommand)(this._SqlCommand)).ExecuteNonQuery();
                this.CloseConnection();
            }
            catch (Exception ex) { throw ex; }
            return result;
        }

        #endregion

        #region Connection

        public void OpenConnection()
        {
            if (((SqlCommand)(this._SqlCommand)).Connection.State != ConnectionState.Open)
            {
                ((SqlCommand)(this._SqlCommand)).Connection.Open();
            }
        }
        public void CloseConnection()
        {
            if (((SqlCommand)(this._SqlCommand)).Connection.State != ConnectionState.Closed)
            {
                ((SqlCommand)(this._SqlCommand)).Connection.Close();
            }
        }
        public void ReturnConnection()
        {
            ConnectionString = null;
        }

        #endregion
    }
}
