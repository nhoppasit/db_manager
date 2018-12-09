using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Runtime.Serialization;
using System.Web;


/// <summary>
/// Summary description for ResultModelType
/// </summary>
[Serializable]
public class ResultModelType
{
    int code = -99;
    int rowCount = 0;
    bool flag = false;
    string message = "";
    DataSet ds = null;
    public int Code { get { return code; } set { code = value; } }
    public int RowCount { get { return rowCount; } set { rowCount = value; } }
    public bool Flag { get { return flag; } set { flag = value; } }
    public string Message { get { return message; } set { message = value; } }
    public DataSet DataSetResult { get { return ds; } set { ds = value; } }
    public string[] DataTexts { get; set; }
    public object[] DataObjects { get; set; }
}