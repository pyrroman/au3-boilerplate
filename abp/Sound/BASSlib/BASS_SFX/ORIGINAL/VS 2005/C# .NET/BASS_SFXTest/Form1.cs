using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace BASS_SFXTest
{
    public partial class frmMain : Form
    {
        [DllImport("bass.dll")]
        public static extern bool BASS_Init(int device, uint freq, uint flag, IntPtr hParent, uint GUID);

        [DllImport("bass.dll")]
        public static extern int BASS_StreamCreateFile(bool mem, [MarshalAs(UnmanagedType.LPWStr)] String str, long offset, long length, long flags);

        [DllImport("bass.dll")]
        public static extern uint BASS_ErrorGetCode();

        [DllImport("bass.dll")]
        public static extern bool BASS_Free();

        [DllImport("bass.dll")]
        public static extern bool BASS_StreamFree(int stream);

        [DllImport("bass.dll")]
        public static extern bool BASS_ChannelPlay(int stream, bool restart);

        [DllImport("bass.dll")]
        public static extern bool BASS_ChannelStop(int stream);

        [DllImport("bass_sfx.dll")]
        public static extern bool BASS_SFX_Init(IntPtr hInstance, IntPtr hWnd);

        [DllImport("bass_sfx.dll")]
        public static extern int BASS_SFX_PluginCreate(string file, IntPtr hPluginWnd, int width, int height, int flags);

        [DllImport("bass_sfx.dll")]
        public static extern bool BASS_SFX_PluginStart(int handle);

        [DllImport("bass_sfx.dll")]
        public static extern bool BASS_SFX_PluginSetStream(int handle, int stream);

        [DllImport("bass_sfx.dll")]
        public static extern bool BASS_SFX_PluginRender(int handle, int hStream, IntPtr hDC);

        int hStream = 0;
        int BASS_UNICODE = -2147483648;

        int hSFX = 0;
        int hSFX2 = 0;
        int hSFX3 = 0;

        IntPtr hVisDC = IntPtr.Zero;
        IntPtr hVisDC2 = IntPtr.Zero;
        IntPtr hVisDC3 = IntPtr.Zero;
        
        public frmMain()
        {
            InitializeComponent();
        }

        private void frmMain_Load(object sender, EventArgs e)
        {
            hVisDC = m_oVisPanel.CreateGraphics().GetHdc();
            hVisDC2 = m_oVisPanel2.CreateGraphics().GetHdc();
            hVisDC3 = m_oVisPanel3.CreateGraphics().GetHdc();

            if (BASS_Init(-1, 44100, 0, this.Handle, 0))
            {
                BASS_SFX_Init(System.Diagnostics.Process.GetCurrentProcess().Handle, this.Handle);

                hStream = BASS_StreamCreateFile(false, "music\\Matrix.mp3", 0, 0, BASS_UNICODE);
                BASS_ChannelPlay(hStream, false);

                hSFX = BASS_SFX_PluginCreate("plugins\\sphere.svp", m_oVisPanel.Handle, m_oVisPanel.Width, m_oVisPanel.Height, 0); //sonique
                hSFX2 = BASS_SFX_PluginCreate("plugins\\blaze.dll", m_oVisPanel2.Handle, m_oVisPanel2.Width, m_oVisPanel2.Height, 0); //windows media player
                hSFX3 = BASS_SFX_PluginCreate("BBPlugin\\oscillo.dll", m_oVisPanel2.Handle, m_oVisPanel3.Width, m_oVisPanel3.Height, 0); //bassbox

                BASS_SFX_PluginStart(hSFX);
                BASS_SFX_PluginStart(hSFX2);
                BASS_SFX_PluginStart(hSFX3);
                timer1.Interval = 27;
                timer1.Enabled = true;
            }
        }

        private void timer1_Tick(object sender, EventArgs e)
        {
            if (hSFX != -1)
                BASS_SFX_PluginRender(hSFX, hStream, hVisDC);
            if (hSFX2 != -1)
                BASS_SFX_PluginRender(hSFX2, hStream, hVisDC2);
            if (hSFX3 != -1)
                BASS_SFX_PluginRender(hSFX3, hStream, hVisDC3);
        }
    }
}