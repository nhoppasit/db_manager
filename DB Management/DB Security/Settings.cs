using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DB_Security
{
    public static class Settings
    {
        static string _connectionString = @"Data Source=SOMPHOP-PC\SQLEXPRESS;Initial Catalog=db_ncs_01;User ID=ncs_admin;Password=thunder@11";
        //static string _connectionString = @"Data Source=BHMVISION\SQLEXPRESS;Initial Catalog=db_ncs_01;User ID=ncs_admin;Password=thunder@11";
        public static string ConnectionString { get { return _connectionString; } }
    }
}
