<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class frmMain
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.components = New System.ComponentModel.Container
        Me.m_oVisPanel3 = New System.Windows.Forms.PictureBox
        Me.m_oVisPanel2 = New System.Windows.Forms.PictureBox
        Me.m_oVisPanel = New System.Windows.Forms.PictureBox
        Me.Timer1 = New System.Windows.Forms.Timer(Me.components)
        CType(Me.m_oVisPanel3, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.m_oVisPanel2, System.ComponentModel.ISupportInitialize).BeginInit()
        CType(Me.m_oVisPanel, System.ComponentModel.ISupportInitialize).BeginInit()
        Me.SuspendLayout()
        '
        'm_oVisPanel3
        '
        Me.m_oVisPanel3.Location = New System.Drawing.Point(12, 239)
        Me.m_oVisPanel3.Name = "m_oVisPanel3"
        Me.m_oVisPanel3.Size = New System.Drawing.Size(191, 184)
        Me.m_oVisPanel3.TabIndex = 5
        Me.m_oVisPanel3.TabStop = False
        '
        'm_oVisPanel2
        '
        Me.m_oVisPanel2.Location = New System.Drawing.Point(247, 12)
        Me.m_oVisPanel2.Name = "m_oVisPanel2"
        Me.m_oVisPanel2.Size = New System.Drawing.Size(191, 184)
        Me.m_oVisPanel2.TabIndex = 4
        Me.m_oVisPanel2.TabStop = False
        '
        'm_oVisPanel
        '
        Me.m_oVisPanel.Location = New System.Drawing.Point(12, 12)
        Me.m_oVisPanel.Name = "m_oVisPanel"
        Me.m_oVisPanel.Size = New System.Drawing.Size(191, 184)
        Me.m_oVisPanel.TabIndex = 3
        Me.m_oVisPanel.TabStop = False
        '
        'Timer1
        '
        '
        'frmMain
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(551, 456)
        Me.Controls.Add(Me.m_oVisPanel3)
        Me.Controls.Add(Me.m_oVisPanel2)
        Me.Controls.Add(Me.m_oVisPanel)
        Me.MaximizeBox = False
        Me.MinimizeBox = False
        Me.Name = "frmMain"
        Me.Text = "BASS_SFXTestVB"
        CType(Me.m_oVisPanel3, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.m_oVisPanel2, System.ComponentModel.ISupportInitialize).EndInit()
        CType(Me.m_oVisPanel, System.ComponentModel.ISupportInitialize).EndInit()
        Me.ResumeLayout(False)

    End Sub
    Private WithEvents m_oVisPanel3 As System.Windows.Forms.PictureBox
    Private WithEvents m_oVisPanel2 As System.Windows.Forms.PictureBox
    Private WithEvents m_oVisPanel As System.Windows.Forms.PictureBox
    Friend WithEvents Timer1 As System.Windows.Forms.Timer

End Class
