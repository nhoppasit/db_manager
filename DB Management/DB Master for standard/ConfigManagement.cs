using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data;

namespace DB_Manager
{
    public class ConfigManagement : IDbCommand, IDisposable
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
                    base.Dispose();
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

        public int GetIntValue(string name)
        {
            try
            {
                DataSet ds = new DataSet();
                stm = "SELECT * FROM tbConfig WHERE Name=@Name";
                DbCallback.SetCommandText(stm);
                DbCallback.AddInputParameter("@Name", SqlDbType.NVarChar, name);
                ds = DbCallback.ExecuteToDataSet();
                if (ds != null)
                    if (ds.Tables != null)
                        if (ds.Tables.Count > 0)
                            if (ds.Tables[0].Rows != null)
                                if (ds.Tables[0].Rows.Count > 0)
                                    return Convert.ToInt32(ds.Tables[0].Rows[0]["IntVal"]);
                return int.MinValue;
            }
            catch (Exception ex)
            {
                DbCallback.CloseConnection();
                throw ex;
            }
        }

        public string GetCharValue(string name)
        {
            try
            {
                DataSet ds = new DataSet();
                stm = "SELECT * FROM tbConfig WHERE Name=@Name";
                DbCallback.SetCommandText(stm);
                DbCallback.AddInputParameter("@Name", SqlDbType.NVarChar, name);
                ds = DbCallback.ExecuteToDataSet();
                if (ds != null)
                    if (ds.Tables != null)
                        if (ds.Tables.Count > 0)
                            if (ds.Tables[0].Rows != null)
                                if (ds.Tables[0].Rows.Count > 0)
                                    return (string)(ds.Tables[0].Rows[0]["CharVal"]);
                return string.Empty;
            }
            catch (Exception ex)
            {
                DbCallback.CloseConnection();
                throw ex;
            }
        }

    }
}
