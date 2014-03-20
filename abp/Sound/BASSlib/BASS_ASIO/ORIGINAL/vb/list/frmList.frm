VERSION 5.00
Begin VB.Form frmList 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "ASIO device list"
   ClientHeight    =   4110
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   6015
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   4110
   ScaleWidth      =   6015
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtList 
      BackColor       =   &H8000000F&
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   8.25
         Charset         =   177
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   4095
      Left            =   0
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   0
      Width           =   6015
   End
End
Attribute VB_Name = "frmList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'//////////////////////////////////////////////////////////////////
' frmList.frm - Copyright (c) 2005 JOBnik! [Arthur Aminov, ISRAEL]
'                                  e-mail: jobnik@jobnik.tk
'
' ASIO device list
' Originally translated from - list.c - Example of Ian Luck
'//////////////////////////////////////////////////////////////////

Option Explicit
 
Private Sub Form_Load()
    'change and set the current path
    'so VB won't ever tell you, that "bassasio.dll" isn't found
    ChDrive App.Path
    ChDir App.Path

    'check if "bassasio.dll" is exists
    If (Not FileExists(RPP(App.Path) & "bassasio.dll")) Then
        Call MsgBox("BASSASIO.DLL does not exists", vbCritical, "BASSASIO.DLL")
        End
    End If

    Dim di As BASS_ASIO_DEVICEINFO
    Dim a As Long
    a = 0
    While BASS_ASIO_GetDeviceInfo(a, di)
        With txtList
            .Text = .Text & "dev " & a & ": " & VBStrFromAnsiPtr(di.name) & vbCrLf
            .Text = .Text & "driver: " & VBStrFromAnsiPtr(di.driver) & vbCrLf
            BASS_ASIO_Init (a)

            Dim i As BASS_ASIO_CHANNELINFO, b As Long, name_ As String
            b = 0
            While BASS_ASIO_ChannelGetInfo(1, b, i)
                name_ = Mid(i.name_, 1, InStr(1, i.name_, Chr(0)) - 1)
                .Text = .Text & vbTab & "in " & b & ": " & name_ & " (group " & i.group & ", format " & i.format_ & ")" & vbCrLf
                b = b + 1
            Wend
            b = 0
            While BASS_ASIO_ChannelGetInfo(0, b, i)
                name_ = Mid(i.name_, 1, InStr(1, i.name_, Chr(0)) - 1)
                .Text = .Text & vbTab & "out " & b & ": " & name_ & " (group " & i.group & ", format " & i.format_ & ")" & vbCrLf
                b = b + 1
            Wend
        End With
        Call BASS_ASIO_Free
        a = a + 1
    Wend

    Me.Show
End Sub

'--------------------------
' some useful functions :)
'--------------------------

'check if any file exists
Public Function FileExists(ByVal fp As String) As Boolean
    FileExists = (Dir(fp) <> "")
End Function

'RPP = Return Proper Path
Function RPP(ByVal fp As String) As String
    RPP = IIf(Mid(fp, Len(fp), 1) <> "\", fp & "\", fp)
End Function

'get file name from file path
Public Function GetFileName(ByVal fp As String) As String
    GetFileName = Mid(fp, InStrRev(fp, "\") + 1)
End Function
