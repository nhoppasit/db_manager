using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace Test
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {

        }

        LogFile.Log log;
        private void button1_Click(object sender, EventArgs e)
        {
            string LogPath = string.Empty;
            using (DB_Manager.ConfigManagement cm = new DB_Manager.ConfigManagement())
            {
                try { LogPath = cm.GetCharValue("Motion_Card_Log_Path"); }
                catch { LogPath = @"C:\TestLog\Test"; }
            }
            log = new LogFile.Log(LogPath, "Test log");
        }
    }
}
