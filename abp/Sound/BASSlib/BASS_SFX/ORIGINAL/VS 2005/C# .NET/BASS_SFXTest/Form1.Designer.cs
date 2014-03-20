namespace BASS_SFXTest
{
    partial class frmMain
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.m_oVisPanel = new System.Windows.Forms.PictureBox();
            this.timer1 = new System.Windows.Forms.Timer(this.components);
            this.m_oVisPanel2 = new System.Windows.Forms.PictureBox();
            this.m_oVisPanel3 = new System.Windows.Forms.PictureBox();
            ((System.ComponentModel.ISupportInitialize)(this.m_oVisPanel)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.m_oVisPanel2)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.m_oVisPanel3)).BeginInit();
            this.SuspendLayout();
            // 
            // m_oVisPanel
            // 
            this.m_oVisPanel.Location = new System.Drawing.Point(12, 12);
            this.m_oVisPanel.Name = "m_oVisPanel";
            this.m_oVisPanel.Size = new System.Drawing.Size(191, 184);
            this.m_oVisPanel.TabIndex = 0;
            this.m_oVisPanel.TabStop = false;
            // 
            // timer1
            // 
            this.timer1.Interval = 27;
            this.timer1.Tick += new System.EventHandler(this.timer1_Tick);
            // 
            // m_oVisPanel2
            // 
            this.m_oVisPanel2.Location = new System.Drawing.Point(247, 12);
            this.m_oVisPanel2.Name = "m_oVisPanel2";
            this.m_oVisPanel2.Size = new System.Drawing.Size(191, 184);
            this.m_oVisPanel2.TabIndex = 1;
            this.m_oVisPanel2.TabStop = false;
            // 
            // m_oVisPanel3
            // 
            this.m_oVisPanel3.Location = new System.Drawing.Point(12, 239);
            this.m_oVisPanel3.Name = "m_oVisPanel3";
            this.m_oVisPanel3.Size = new System.Drawing.Size(191, 184);
            this.m_oVisPanel3.TabIndex = 2;
            this.m_oVisPanel3.TabStop = false;
            // 
            // frmMain
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(593, 485);
            this.Controls.Add(this.m_oVisPanel3);
            this.Controls.Add(this.m_oVisPanel2);
            this.Controls.Add(this.m_oVisPanel);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "frmMain";
            this.Text = "BASS_SFX Test";
            this.Load += new System.EventHandler(this.frmMain_Load);
            ((System.ComponentModel.ISupportInitialize)(this.m_oVisPanel)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.m_oVisPanel2)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.m_oVisPanel3)).EndInit();
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.PictureBox m_oVisPanel;
        private System.Windows.Forms.Timer timer1;
        private System.Windows.Forms.PictureBox m_oVisPanel2;
        private System.Windows.Forms.PictureBox m_oVisPanel3;
    }
}

