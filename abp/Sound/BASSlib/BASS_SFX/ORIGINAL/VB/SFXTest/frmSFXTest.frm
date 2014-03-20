VERSION 5.00
Begin VB.Form frmSFXTest 
   Caption         =   "SFXTest"
   ClientHeight    =   4335
   ClientLeft      =   120
   ClientTop       =   420
   ClientWidth     =   10575
   LinkTopic       =   "Form1"
   ScaleHeight     =   289
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   705
   StartUpPosition =   3  'Windows Default
   Begin VB.PictureBox Picture3 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      ForeColor       =   &H80000008&
      Height          =   2775
      Left            =   6960
      ScaleHeight     =   185
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   217
      TabIndex        =   2
      Top             =   120
      Width           =   3255
   End
   Begin VB.PictureBox Picture2 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      ForeColor       =   &H80000008&
      Height          =   2775
      Left            =   3720
      ScaleHeight     =   185
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   201
      TabIndex        =   1
      Top             =   120
      Width           =   3015
   End
   Begin VB.PictureBox Picture1 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      FillStyle       =   0  'Solid
      ForeColor       =   &H80000008&
      Height          =   2775
      Left            =   120
      ScaleHeight     =   185
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   225
      TabIndex        =   0
      Top             =   120
      Width           =   3375
   End
   Begin VB.Timer Timer1 
      Left            =   4440
      Top             =   3240
   End
End
Attribute VB_Name = "frmSFXTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim hStream As Long
Dim hSFX As Long
Dim hSFX2 As Long
Dim hSFX3 As Long

Private Sub Form_Load()
hSFX = -1
hSFX2 = -1
hSFX3 = -1
hStream = 0
If BASS_Init(-1, 44100, 0, Me.hWnd, 0) Then
BASS_SFX_Init App.hInstance, Me.hWnd
hSFX = BASS_SFX_PluginCreate("plugins\sphere.svp", Picture1.hWnd, Picture1.Width, Picture1.Height, 0)
hSFX2 = BASS_SFX_PluginCreate("plugins\blaze.dll", Picture2.hWnd, Picture2.Width, Picture2.Height, 0)
hSFX3 = BASS_SFX_PluginCreate("BBPlugin\oscillo", Picture3.hWnd, Picture3.Width, Picture3.Height, 0)

    hStream = BASS_StreamCreateFile(0, StrPtr("music\matrix.mp3"), 0, 0, 0)
    If hStream Then
        BASS_ChannelPlay hStream, 0
        BASS_SFX_PluginStart hSFX
        BASS_SFX_PluginStart hSFX2
        BASS_SFX_PluginStart hSFX3
        Timer1.Interval = 27
        Timer1.Enabled = True
    End If
End If

End Sub

Private Sub Form_Unload(Cancel As Integer)
BASS_ChannelStop hStream
BASS_StreamFree hStream
BASS_SFX_Free
BASS_Free
End Sub

Private Sub Timer1_Timer()
If (hSFX <> -1) Then
BASS_SFX_PluginRender hSFX, hStream, Picture1.hDC
End If
If (hSFX2 <> -1) Then
BASS_SFX_PluginRender hSFX2, hStream, Picture2.hDC
End If
If (hSFX3 <> -1) Then
BASS_SFX_PluginRender hSFX3, hStream, Picture3.hDC
End If
End Sub
