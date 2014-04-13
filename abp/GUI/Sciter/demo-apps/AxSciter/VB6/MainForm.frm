VERSION 5.00
Object = "{25D9681B-32F2-44C9-B94F-5E82E7ED0C75}#1.0#0"; "AxSciter.dll"
Begin VB.Form Form1 
   Caption         =   "The Sciter, ladies and gentlemen:"
   ClientHeight    =   5220
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   10245
   LinkTopic       =   "Form1"
   ScaleHeight     =   5220
   ScaleWidth      =   10245
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox TextToEval 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   9.75
         Charset         =   204
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   3960
      TabIndex        =   5
      Text            =   "Hello(""Heya"");"
      Top             =   0
      Width           =   3135
   End
   Begin VB.CommandButton EvalHello 
      Caption         =   "Eval >"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   2760
      TabIndex        =   4
      Top             =   0
      Width           =   1095
   End
   Begin VB.CommandButton CallHello 
      Caption         =   "Hello(""Hi"")"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   1560
      TabIndex        =   3
      Top             =   0
      Width           =   1095
   End
   Begin VB.CommandButton LoadTest 
      Caption         =   "Load test.htm"
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   0
      TabIndex        =   2
      Top             =   0
      Width           =   1455
   End
   Begin VB.ListBox Log 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1500
      IntegralHeight  =   0   'False
      Left            =   0
      TabIndex        =   1
      Top             =   3720
      Width           =   2895
   End
   Begin AxSciterLibCtl.Sciter Sciter 
      Height          =   2535
      Left            =   0
      OleObjectBlob   =   "MainForm.frx":0000
      TabIndex        =   0
      Top             =   360
      Width           =   4455
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Dim WithEvents FirstText As Element
Attribute FirstText.VB_VarHelpID = -1

Private Sub CallHello_Click()
  Dim r
  r = Sciter.Call("Hello", "Hi!")
  MsgBox "Got from script:" & r
End Sub

Private Sub EvalHello_Click()
  Dim r
  r = Sciter.Eval(TextToEval.Text)
  MsgBox "Got from script:" & r
End Sub


Private Sub Form_Load()
  ' Sciter.LoadHtml "<html><body>Hello World</body></html>", ""
  
  ' Setup outbound object that represents collection of methods available in script
  ' trough <tiscript> var r = view.methodName(p1,p2,...); </tiscript>
  Set Sciter.Methods = New FunctionsForScript
  
End Sub

Private Sub Form_Resize()
  Sciter.Left = 0
  Dim l As Long
  l = Me.ScaleHeight - Sciter.Top - Log.Height
  If l > 0 Then Sciter.Height = Me.ScaleHeight - Sciter.Top - Log.Height
  Sciter.Width = Me.ScaleWidth
  Log.Top = Me.ScaleHeight - Log.Height
  Log.Width = Me.ScaleWidth
End Sub

Private Sub LoadTest_Click()
  Sciter.LoadUrl "file://" & App.Path & "/test.htm"
  Set FirstText = Sciter.Root.Select("body>text")
End Sub

Private Sub FirstText_OnSize()
  Dim w As Long, h As Long
  FirstText.Dimension w, h, BorderBox
  Debug.Print "dimensions:", w, h
End Sub

Private Function FirstText_OnMouse(ByVal target As AxSciterLibCtl.IElement, ByVal eventType As Long, ByVal x As Long, ByVal y As Long, ByVal buttons As Long, ByVal keys As Long) As Boolean
  If eventType = ME_MOUSE_DOWN Then
     Debug.Print "got mouse click at", x, y
  End If
  FirstText_OnMouse = True ' processed, a.k.a. consumed
End Function


Private Sub Sciter_onStdOut(ByVal msg As String)
  Log.AddItem "stdout:" & msg
End Sub
Private Sub Sciter_onStdErr(ByVal msg As String)
  Log.AddItem "stderr:" & msg
End Sub


