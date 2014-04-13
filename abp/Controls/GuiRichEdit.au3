#include-once
#include <GUIConstants.au3>
#include <StructureConstants.au3>
#include <SendMessage.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>

; Author(s): GaryFrost, grham, Prog@ndy, KIP
; OLE stuff: example from http://www.powerbasic.com/support/pbforums/showpost.php?p=294112&postcount=7
Global $__GCR_DebugIt = 0

;~ Global Const $WM_NOTIFY = 0x4E
;~ Global Const $WM_USER = 0x400
Global $RICHEDIT_OLE_CALLBACKDLL = "EMPTY"
Global Const $RICHEDIT_CLASS10A = "RICHEDIT"
Global Const $RICHEDIT_CLASS = $RICHEDIT_CLASS10A
Global Const $RICHEDIT_CLASSA = "RichEdit20A"
Global Const $RICHEDIT_CLASSW = "RichEdit20W"
Global Const $RICHEDIT_CLASS50W = "RichEdit50W"
Global $_GRE_sRTFClassName, $h_GUICtrlRTF_lib


; Select the DLL :)
__GUICtrlRichEdit_LoadDLL()
;Prog@ndy
Func __GUICtrlRichEdit_LoadDLL()
	Switch True;@AutoItUnicode
		Case True
			;MSFTEDIT.DLL
			$h_GUICtrlRTF_lib = DllCall("kernel32.dll", "hwnd", "LoadLibraryW", "wstr", "MSFTEDIT.DLL")
			If $h_GUICtrlRTF_lib[0] = 0 Then ContinueCase
			$_GRE_sRTFClassName = $RICHEDIT_CLASS50W
			__GCR_DebugPrint("loaded MSFTEDIT.DLL, Unicode used")
			;$dll = DllOpen("RICHED20.DLL")
			;$_GRE_sRTFClassName = "RichEdit20A"
		Case False
			;RICHED20.DLL
			$h_GUICtrlRTF_lib = DllCall("kernel32.dll", "hwnd", "LoadLibraryA", "str", "RICHED20.DLL")
			If $h_GUICtrlRTF_lib[0] = 0 Then ContinueCase
			__GCR_DebugPrint("loaded RICHED20.DLL, Unicode used")
			$_GRE_sRTFClassName = $RICHEDIT_CLASSW
		Case Else ;Fallback Win95
			$h_GUICtrlRTF_lib = DllCall("kernel32.dll", "hwnd", "LoadLibraryA", "str", "RICHED32.DLL")
			If $h_GUICtrlRTF_lib[0] = 0 Then Exit 0 * MsgBox(32, @ScriptName & " - Error", "No RichEdit found. Exiting")
			__GCR_DebugPrint("loaded RICHED32.DLL, Fallback for Win95, no Unicode")
			$_GRE_sRTFClassName = $RICHEDIT_CLASS10A
	EndSwitch
EndFunc   ;==>__GUICtrlRichEdit_LoadDLL
;--------------------------------------------------------------------------------------------------------------------------
;---------------------------- Constants -----------------------------------------------------------------------------------

Global Const $ICC_STANDARD_CLASSES = 0x4000

;~ Global Const $ST_DEFAULT = 0
;~ Global Const $ST_KEEPUNDO = 1
;~ Global Const $ST_SELECTION = 2

;~ Global Const $GT_DEFAULT = 0
;~ Global Const $GT_SELECTION = 2
;~ Global Const $GT_USECRLF = 1

;~ Global Const $GTL_CLOSE = 4
;~ Global Const $GTL_DEFAULT = 0
;~ Global Const $GTL_NUMBYTES = 16
;~ Global Const $GTL_NUMCHARS = 8
;~ Global Const $GTL_PRECISE = 2
;~ Global Const $GTL_USECRLF = 1


; pitch and family
;~ If Not IsDeclared("DEFAULT_PITCH") Then Global Const $DEFAULT_PITCH	= 0

;~ If Not IsDeclared("FF_DONTCARE") Then Global Const $FF_DONTCARE		= 0
;~ Global Const $FF_ROMAN = 16
;~ Global Const $FF_SWISS = 32
;~ Global Const $FF_MODERN = 48
;~ Global Const $FF_SCRIPT = 64

;~ Global Const $FW_DONTCARE = 0
;~ Global Const $FW_THIN = 100
;~ Global Const $FW_EXTRALIGHT = 200
;~ Global Const $FW_ULTRALIGHT = 200
;~ Global Const $FW_LIGHT = 300
;~ Global Const $FW_NORMAL = 400
;~ Global Const $FW_REGULAR = 400
;~ Global Const $FW_MEDIUM = 500
;~ Global Const $FW_SEMIBOLD = 600
;~ Global Const $FW_DEMIBOLD = 600
;~ Global Const $FW_BOLD = 700
;~ Global Const $FW_EXTRABOLD = 800
;~ Global Const $FW_ULTRABOLD = 800
;~ Global Const $FW_HEAVY = 900
;~ Global Const $FW_BLACK = 900

; char sets
;~ Global Const $ANSI_CHARSET = 0
;~ Global Const $DEFAULT_CHARSET = 1
;~ Global Const $SYMBOL_CHARSET = 2
;~ Global Const $MAC_CHARSET = 77
;~ Global Const $SHIFTJIS_CHARSET = 128
;~ Global Const $HANGEUL_CHARSET = 129
;~ Global Const $GB2312_CHARSET = 134
;~ Global Const $CHINESEBIG5_CHARSET = 136
;~ Global Const $GREEK_CHARSET = 161
;~ Global Const $TURKISH_CHARSET = 162
;~ Global Const $VIETNAMESE_CHARSET = 163
;~ Global Const $BALTIC_CHARSET = 186
;~ Global Const $RUSSIAN_CHARSET = 204
;~ Global Const $OEM_CHARSET = 255

;~ Global Const $CFU_UNDERLINENONE = 0
;~ Global Const $CFU_UNDERLINE = 1
;~ Global Const $CFU_UNDERLINEWORD = 2
;~ Global Const $CFU_UNDERLINEDOUBLE = 3
;~ Global Const $CFU_UNDERLINEDOTTED = 4

;~ ; code pages
;~ Global Const $CP_ACP = 0 ; use system default
;~ Global Const $CP_UNICODE = 1200
Global Const $CP_37 = 37
Global Const $CP_273 = 273
Global Const $CP_277 = 277
Global Const $CP_278 = 278
Global Const $CP_280 = 280
Global Const $CP_284 = 284
Global Const $CP_285 = 285
Global Const $CP_290 = 290
Global Const $CP_297 = 297
Global Const $CP_423 = 423
Global Const $CP_500 = 500
Global Const $CP_875 = 875
Global Const $CP_930 = 930
Global Const $CP_931 = 931
Global Const $CP_932 = 932
Global Const $CP_933 = 933
Global Const $CP_935 = 935
Global Const $CP_936 = 936
Global Const $CP_937 = 937
Global Const $CP_939 = 939
Global Const $CP_949 = 949
Global Const $CP_950 = 950
Global Const $CP_1027 = 1027
Global Const $CP_5026 = 5026
Global Const $CP_5035 = 5035

;~ Global Const $CFM_ALLCAPS = 0x80
;~ Global Const $CFM_ANIMATION = 0x40000
;~ Global Const $CFM_BACKCOLOR = 0x4000000
;~ Global Const $CFM_BOLD = 0x1
;~ Global Const $CFM_CHARSET = 0x8000000
;~ Global Const $CFM_COLOR = 0x40000000
;~ Global Const $CFM_DISABLED = 0x2000
;~ Global Const $CFM_EMBOSS = 0x800
;~ Global Const $CFM_FACE = 0x20000000
;~ Global Const $CFM_HIDDEN = 0x100
;~ Global Const $CFM_IMPRINT = 0x1000
;~ Global Const $CFM_ITALIC = 0x2
;~ Global Const $CFM_KERNING = 0x100000
;~ Global Const $CFM_LCID = 0x2000000
;~ Global Const $CFM_LINK = 0x20
;~ Global Const $CFM_OFFSET = 0x10000000
;~ Global Const $CFM_OUTLINE = 0x200
;~ Global Const $CFM_PROTECTED = 0x10
;~ Global Const $CFM_REVAUTHOR = 0x8000
;~ Global Const $CFM_REVISED = 0x4000
;~ Global Const $CFM_SHADOW = 0x400
;~ Global Const $CFM_SIZE = 0x80000000
;~ Global Const $CFM_SMALLCAPS = 0x40
;~ Global Const $CFM_SPACING = 0x200000
;~ Global Const $CFM_STRIKEOUT = 0x8
;~ Global Const $CFM_STYLE = 0x80000
;~ Global Const $CFM_SUBSCRIPT = BitOR(0x10000, 0x20000)
;~ Global Const $CFM_SUPERSCRIPT = $CFM_SUBSCRIPT
;~ Global Const $CFM_UNDERLINE = 0x4
;~ Global Const $CFM_UNDERLINETYPE = 0x800000
;~ Global Const $CFM_WEIGHT = 0x400000

;~ Global Const $CFE_ALLCAPS = $CFM_ALLCAPS
;~ Global Const $CFE_AUTOBACKCOLOR = $CFM_BACKCOLOR
;~ Global Const $CFE_AUTOCOLOR = 0x40000000
;~ Global Const $CFE_BOLD = $CFM_BOLD
;~ Global Const $CFE_DISABLED = $CFM_DISABLED
;~ Global Const $CFE_EMBOSS = $CFM_EMBOSS
;~ Global Const $CFE_HIDDEN = $CFM_HIDDEN
;~ Global Const $CFE_IMPRINT = $CFM_IMPRINT
;~ Global Const $CFE_ITALIC = $CFM_ITALIC
;~ Global Const $CFE_LINK = $CFM_LINK
;~ Global Const $CFE_OUTLINE = $CFM_OUTLINE
;~ Global Const $CFE_PROTECTED = $CFM_PROTECTED
;~ Global Const $CFE_REVISED = $CFM_REVISED
;~ Global Const $CFE_SHADOW = $CFM_SHADOW
;~ Global Const $CFE_SMALLCAPS = $CFM_SMALLCAPS
;~ Global Const $CFE_STRIKEOUT = 0x8
;~ Global Const $CFE_SUBSCRIPT = 0x10000
;~ Global Const $CFE_SUPERSCRIPT = 0x20000
;~ Global Const $CFE_UNDERLINE = 0x4

Global Const $CFM_EFFECTS = BitOR($CFM_BOLD, $CFM_ITALIC, $CFM_UNDERLINE, $CFM_COLOR, $CFM_STRIKEOUT, $CFE_PROTECTED, $CFM_LINK)
Global Const $CFM_ALL = BitOR($CFM_EFFECTS, $CFM_SIZE, $CFM_FACE, $CFM_OFFSET, $CFM_CHARSET)

;~ Global Const $SCF_DEFAULT = 0x0
;~ Global Const $SCF_SELECTION = 0x1
;~ Global Const $SCF_WORD = 0x2
;~ Global Const $SCF_ALL = 0x4
;~ Global Const $SCF_USEUIRULES = 0x8
;~ Global Const $SCF_ASSOCIATEFONT = 0x10
;~ Global Const $SCF_NOKBUPDATE = 0x20

Global Enum $UID_UNKNOWN = 0, _
		$UID_TYPING = 1, _
		$UID_DELETE = 2, _
		$UID_DRAGDROP = 3, _
		$UID_CUT = 4, _
		$UID_PASTE = 5

;--------------------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------------------
;---------------------- Messages ------------------------------------------------------------------------------------------
; RichEdit Messages
;~ Global Const $EM_AUTOURLDETECT = ($WM_USER + 91)
;~ Global Const $EM_CANPASTE = ($WM_USER + 50)
;~ Global Const $EM_CANREDO = ($WM_USER + 85)
;~ Global Const $EM_DISPLAYBAND = ($WM_USER + 51)
;~ Global Const $EM_EXGETSEL = ($WM_USER + 52)
;~ Global Const $EM_EXLIMITTEXT = ($WM_USER + 53)
;~ Global Const $EM_EXLINEFROMCHAR = ($WM_USER + 54)
;~ Global Const $EM_EXSETSEL = ($WM_USER + 55)
;~ Global Const $EM_FINDTEXT = ($WM_USER + 56)
;~ Global Const $EM_FINDTEXTEX = ($WM_USER + 79)
;~ Global Const $EM_FINDTEXTEXW = ($WM_USER + 124)
;~ Global Const $EM_FINDTEXTW = ($WM_USER + 123)
;~ Global Const $EM_FINDWORDBREAK = ($WM_USER + 76)
;~ Global Const $EM_FORMATRANGE = ($WM_USER + 57)
;~ Global Const $EM_GETAUTOURLDETECT = ($WM_USER + 92)
;~ Global Const $EM_GETBIDIOPTIONS = ($WM_USER + 201)
;~ Global Const $EM_GETCHARFORMAT = ($WM_USER + 58)
;~ Global Const $EM_GETEDITSTYLE = ($WM_USER + 205)
;~ Global Const $EM_GETEVENTMASK = ($WM_USER + 59)
;~ Global Const $EM_GETIMECOLOR = ($WM_USER + 105)
;~ Global Const $EM_GETIMECOMPMODE = ($WM_USER + 122)
;~ Global Const $EM_GETIMEMODEBIAS = ($WM_USER + 127)
;~ Global Const $EM_GETIMEOPTIONS = ($WM_USER + 107)
;~ Global Const $EM_GETLANGOPTIONS = ($WM_USER + 121)
;~ Global Const $EM_GETOPTIONS = ($WM_USER + 78)
;~ Global Const $EM_GETPARAFORMAT = ($WM_USER + 61)
;~ Global Const $EM_GETPUNCTUATION = ($WM_USER + 101)
;~ Global Const $EM_GETREDONAME = ($WM_USER + 87)
;~ Global Const $EM_GETSCROLLPOS = ($WM_USER + 221)
;~ Global Const $EM_GETSELTEXT = ($WM_USER + 62)
;~ Global Const $EM_GETTEXTEX = ($WM_USER + 94)
;~ Global Const $EM_GETTEXTLENGTHEX = ($WM_USER + 95)
;~ Global Const $EM_GETTEXTMODE = ($WM_USER + 90)
;~ Global Const $EM_GETTEXTRANGE = ($WM_USER + 75)
;~ Global Const $EM_GETTYPOGRAPHYOPTIONS = ($WM_USER + 203)
;~ Global Const $EM_GETUNDONAME = ($WM_USER + 86)
;~ Global Const $EM_GETWORDBREAKPROCEX = ($WM_USER + 80)
;~ Global Const $EM_GETWORDWRAPMODE = ($WM_USER + 103)
;~ Global Const $EM_GETZOOM = ($WM_USER + 224)
;~ Global Const $EM_HIDESELECTION = ($WM_USER + 63)
;~ Global Const $EM_PASTESPECIAL = ($WM_USER + 64)
;~ Global Const $EM_RECONVERSION = ($WM_USER + 125)
;~ Global Const $EM_REDO = ($WM_USER + 84)
;~ Global Const $EM_REQUESTRESIZE = ($WM_USER + 65)
;~ Global Const $EM_SELECTIONTYPE = ($WM_USER + 66)
;~ Global Const $EM_SETBIDIOPTIONS = ($WM_USER + 200)
;~ Global Const $EM_SETBKGNDCOLOR = ($WM_USER + 67)
;~ Global Const $EM_SETCHARFORMAT = ($WM_USER + 68)
;~ Global Const $EM_SETEDITSTYLE = ($WM_USER + 204)
;~ Global Const $EM_SETEVENTMASK = ($WM_USER + 69)
;~ Global Const $EM_SETFONTSIZE = ($WM_USER + 223)
;~ Global Const $EM_SETIMECOLOR = ($WM_USER + 104)
;~ Global Const $EM_SETIMEMODEBIAS = ($WM_USER + 126)
;~ Global Const $EM_SETIMEOPTIONS = ($WM_USER + 106)
;~ Global Const $EM_SETLANGOPTIONS = ($WM_USER + 120)
;~ Global Const $EM_SETOLECALLBACK = ($WM_USER + 70)
;~ Global Const $EM_SETOPTIONS = ($WM_USER + 77)
;~ Global Const $EM_SETPALETTE = ($WM_USER + 93)
;~ Global Const $EM_SETPARAFORMAT = ($WM_USER + 71)
;~ Global Const $EM_SETPUNCTUATION = ($WM_USER + 100)
;~ Global Const $EM_SETSCROLLPOS = ($WM_USER + 222)
;~ Global Const $EM_SETTARGETDEVICE = ($WM_USER + 72)
;~ Global Const $EM_SETTEXTEX = ($WM_USER + 97)
;~ Global Const $EM_SETTEXTMODE = ($WM_USER + 89)
;~ Global Const $EM_SETTYPOGRAPHYOPTIONS = ($WM_USER + 202)
;~ Global Const $EM_SETUNDOLIMIT = ($WM_USER + 82)
;~ Global Const $EM_SETWORDBREAKPROCEX = ($WM_USER + 81)
;~ Global Const $EM_SETWORDWRAPMODE = ($WM_USER + 102)
;~ Global Const $EM_SETZOOM = ($WM_USER + 225)
;~ Global Const $EM_SHOWSCROLLBAR = ($WM_USER + 96)
;~ Global Const $EM_STOPGROUPTYPING = ($WM_USER + 88)
;~ Global Const $EM_STREAMIN = ($WM_USER + 73)
;~ Global Const $EM_STREAMOUT = ($WM_USER + 74)

;~ Global Const $EN_ALIGNLTR = 0X710
;~ Global Const $EN_ALIGNRTL = 0X711
;~ Global Const $EN_CORRECTTEXT = 0X705
;~ Global Const $EN_DRAGDROPDONE = 0X70c
;~ Global Const $EN_DROPFILES = 0X703
;~ Global Const $EN_IMECHANGE = 0X707
;~ Global Const $EN_LINK = 0X70b
;~ Global Const $EN_MSGFILTER = 0X700
;~ Global Const $EN_OBJECTPOSITIONS = 0X70a
;~ Global Const $EN_OLEOPFAILED = 0X709
;~ Global Const $EN_PROTECTED = 0X704
;~ Global Const $EN_REQUESTRESIZE = 0X701
;~ Global Const $EN_SAVECLIPBOARD = 0X708
;~ Global Const $EN_SELCHANGE = 0X702
;~ Global Const $EN_STOPNOUNDO = 0X706

;~ Global Const $ENM_CHANGE = 0x1
;~ Global Const $ENM_CORRECTTEXT = 0x400000
;~ Global Const $ENM_DRAGDROPDONE = 0x10
;~ Global Const $ENM_DROPFILES = 0x100000
;~ Global Const $ENM_IMECHANGE = 0x800000
;~ Global Const $ENM_KEYEVENTS = 0x10000
;~ Global Const $ENM_LINK = 0x4000000
;~ Global Const $ENM_MOUSEEVENTS = 0x20000
;~ Global Const $ENM_OBJECTPOSITIONS = 0x2000000
;~ Global Const $ENM_PROTECTED = 0x200000
;~ Global Const $ENM_REQUESTRESIZE = 0x40000
;~ Global Const $ENM_SCROLL = 0x4
;~ Global Const $ENM_SCROLLEVENTS = 0x8
;~ Global Const $ENM_SELCHANGE = 0x80000
;~ Global Const $ENM_UPDATE = 0x2


Global Const $ES_DISABLENOSCROLL = 0x2000
Global Const $ES_EX_NOCALLOLEINIT = 0x1000000
Global Const $ES_NOIME = 0x80000
Global Const $ES_SELFIME = 0x40000
Global Const $ES_SUNKEN = 0x4000

;~ Global Const $ES_NUMBER					= 0x2000
;~ Global Const $ES_PASSWORD				= 0x20
;~ Global Const $ES_READONLY				= 0x800
;~ Global Const $ES_RIGHT					= 0x2
;~ Global Const $ES_WANTRETURN			= 0x1000

;~ If Not IsDeclared("WM_LBUTTONDBLCLK") Then Global Const $WM_LBUTTONDBLCLK = 0x203
;~ If Not IsDeclared("WM_LBUTTONDOWN") Then Global Const $WM_LBUTTONDOWN = 0x201
;~ Global Const $WM_LBUTTONUP = 0x202
;~ Global Const $WM_MOUSEMOVE = 0x200
;~ If Not IsDeclared("WM_RBUTTONDBLCLK") Then Global Const $WM_RBUTTONDBLCLK = 0x206
;~ If Not IsDeclared("WM_RBUTTONDOWN") Then Global Const $WM_RBUTTONDOWN = 0x204
;~ If Not IsDeclared("WM_RBUTTONUP") Then Global Const $WM_RBUTTONUP = 0x205
;~ Global Const $WM_SETCURSOR = 0x20

;~ ; structure formats
;~ Global Const $LF_FACESIZE = 32
;~ Global Const $MAX_TAB_STOPS = 32

Global Const $CFM_RichEdit_SET = 0x08000000


;~ Global Const $PFA_LEFT = 0x1
;~ Global Const $PFA_RIGHT = 0x2
;~ Global Const $PFA_CENTER = 0x3
;~ Global Const $PFA_JUSTIFY = 4

;~ Global Const $PFE_TABLE = 0x4000

;~ Global Const $PFM_NUMBERING = 0x20
;~ Global Const $PFM_ALIGNMENT = 0x8
;~ Global Const $PFM_SPACEBEFORE = 0x40
;~ Global Const $PFM_NUMBERINGSTYLE = 0x2000
;~ Global Const $PFM_NUMBERINGSTART = 0x8000
;~ Global Const $PFM_BORDER = 0x800
;~ Global Const $PFM_RIGHTINDENT = 0x2
;~ Global Const $PFM_STARTINDENT = 0x1
;~ Global Const $PFM_OFFSET = 0x4
;~ Global Const $PFM_LINESPACING = 0x100
;~ Global Const $PFM_SPACEAFTER = 0x80
;~ Global Const $PFM_NUMBERINGTAB = 0x4000
;~ Global Const $PFM_TABLE = 0x40000000

;~ Global Const $PFN_BULLET = 0x1

;~ Global Const $WB_CLASSIFY = 3
;~ Global Const $WB_ISDELIMITER = 2
;~ Global Const $WB_LEFT = 0
;~ Global Const $WB_LEFTBREAK = 6
;~ Global Const $WB_MOVEWORDLEFT = 4
;~ Global Const $WB_MOVEWORDNEXT = 5
;~ Global Const $WB_MOVEWORDPREV = 4
;~ Global Const $WB_MOVEWORDRIGHT = 5
;~ Global Const $WB_NEXTBREAK = 7
;~ Global Const $WB_PREVBREAK = 6
;~ Global Const $WB_RIGHT = 1
;~ Global Const $WB_RIGHTBREAK = 7

;~ ; For Stream Callbacks :)

;~ Global Const $SF_TEXT = 0x1
;~ Global Const $SF_RTF = 0x2
;~ Global Const $SF_RTFNOOBJS = 0x3
;~ Global Const $SF_TEXTIZED = 0x4

;~ Global Const $SF_UNICODE = 0x0010
;~ Global Const $SF_USECODEPAGE = 0x20
;~ Global Const $SFF_PLAINRTF = 0x4000
;~ Global Const $SFF_SELECTION = 0x8000


;--------------------------------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------------------------------
;---------------- DLL Structures ------------------------------------------------------------------------------------------

Global Const $tagEDITSTREAM = "long_PTR dwCookie; DWORD dwError; ptr pfnCallback"

;~ Global Const $tagNMHDR = "int;int;int"
;~ HWND hwndFrom;
;~ UINT idFrom;
;~ UINT code;

;~ Global Const $tagRECT = "int;int;int;int"

Global Const $tagBIDIOPTIONS = "uint;int;int"
;~ UINT cbSize;
;~ WORD wMask;
;~ WORD wEffects

Global Const $tagCHARFORMAT = "uint;dword;dword;int;int;int;byte;byte;char[" & $LF_FACESIZE & "]"
;~ UINT cbSize;
;~ DWORD dwMask;
;~ DWORD dwEffects;
;~ LONG yHeight;
;~ LONG yOffset;
;~ COLORREF crTextColor;
;~ BYTE bCharSet;
;~ BYTE bPitchAndFamily;
;~ TCHAR szFaceName[LF_FACESIZE];

;~ Global Const $tagCHARFORMAT2 = "uint;dword;dword;int;int;int;byte;byte;char[" & $LF_FACESIZE & "];int;short;int;byte;byte;byte;byte"
Global Const $tagCHARFORMAT2 = "UINT cbSize;DWORD dwMask;DWORD dwEffects;LONG yHeight;LONG yOffset;long crTextColor;BYTE bCharSet;BYTE bPitchAndFamily;" & _
		"CHAR szFaceName[" & $LF_FACESIZE & "];ushort wWeight;SHORT sSpacing;long crBackColor;dword lcid;DWORD dwReserved;SHORT sStyle;ushort wKerning;BYTE bUnderlineType;BYTE bAnimation;BYTE bRevAuthor;BYTE bReserved1"
;~ UINT cbSize;
;~ DWORD dwMask;
;~ DWORD dwEffects;
;~ LONG yHeight;
;~ LONG yOffset;
;~ COLORREF crTextColor;
;~ BYTE bCharSet;
;~ BYTE bPitchAndFamily;
;~ TCHAR szFaceName[LF_FACESIZE];
;~ WORD wWeight;
;~ SHORT sSpacing;
;~ COLORREF crBackColor;
;~ LCID lcid;
;~ DWORD dwReserved;
;~ SHORT sStyle;
;~ WORD wKerning;
;~ BYTE bUnderlineType;
;~ BYTE bAnimation;
;~ BYTE bRevAuthor;
;~ BYTE bReserved1;

Global Const $tagCHARRANGE = "int;int"
;~ LONG cpMin;
;~ LONG cpMax;

Global Const $tagCOMPCOLOR = "int;int;dword"
;~ COLORREF crText;
;~ COLORREF crBackground;
;~ DWORD dwEffects

;~ editstream {
;~     DWORD_PTR dwCookie;
;~     DWORD dwError;
;~     EDITSTREAMCALLBACK pfnCallback

Global Const $tagENCORRECTTEXT = $tagNMHDR & ";" & $tagCHARRANGE & ";int"
;~ NMHDR nmhdr;
;~ CHARRANGE chrg;
;~ WORD seltyp;

Global Const $tagENDROPFILES = $tagNMHDR & ";int;int;int"
;~ NMHDR nmhdr;
;~ HANDLE hDrop;
;~ LONG cp;
;~ BOOL fProtected

Global Const $tagENLINK = $tagNMHDR & ";uint msg;int wParam;int lParam;" & $tagCHARRANGE
;~ NMHDR nmhdr;
;~ UINT msg;
;~ WPARAM wParam;
;~ LPARAM lParam;
;~ CHARRANGE chrg

Global Const $tagENLOWFIRTF = $tagNMHDR & ";ptr"
;~ NMHDR nmhdr;
;~ CHAR *szControl

Global Const $tagENOLEOPFAILED = $tagNMHDR & ";int;int;int"
;~ NMHDR nmhdr;
;~ LONG iob;
;~ LONG lOper;
;~ HRESULT hr;

Global Const $tagENPROTECTED = $tagNMHDR & ";uint msg;int wParam;int lParam;" & $tagCHARRANGE
;~ NMHDR nmhdr;
;~ UINT msg;
;~ WPARAM wParam;
;~ LPARAM lParam;
;~ CHARRANGE chrg

Global Const $tagENSAVECLIPBOARD = $tagNMHDR & ";int;int"
;~ NMHDR nmhdr;
;~ LONG cObjectCount;
;~ LONG cch;

;~ Global Const $tagFINDTEXT = $tagCHARRANGE & ";ptr"
Global Const $tagFINDTEXT = $tagCHARRANGE & ";char[128]"
;~ CHARRANGE chrg;
;~ LPCTSTR lpstrText;

Global Const $tagFINDTEXTEX = $tagCHARRANGE & ";char[128];" & $tagCHARRANGE
;~ CHARRANGE chrg;
;~ LPCTSTR lpstrText;
;~ CHARRANGE chrgText

Global Const $tagFORMATRANGE = "int;int;" & $tagRECT & ";" & $tagRECT & ";" & $tagCHARRANGE
;~ HDC hdc;
;~ HDC hdcTarget;
;~ RECT rc;
;~ RECT rcPage;
;~ CHARRANGE chrg

Global Const $tagGETTEXTEX = "dword;dword;uint;char;int"
;~ DWORD cb;
;~ DWORD flags;
;~ UINT codepage;
;~ LPCSTR lpDefaultChar;
;~ LPBOOL lpUsedDefChar

Global Const $tagGETTEXTLENGTHEX = "dword;uint"
;~ DWORD flags;
;~ UINT codepage;

;~ tagHyphenateInfo {
;~     SHORT cbSize;
;~     SHORT dxHyphenateZone;
;~     PFNHYPHENATEPROC pfnHyphenate

Global Const $tagKHYPH = "int;int;int;int;int;int;int"
;~ khyphNil,
;~ khyphNormal,
;~ khyphAddBefore,
;~ khyphChangeBefore,
;~ khyphDeleteBefore,
;~ khyphChangeAfter,
;~ khyphDelAndChange

Global Const $tagHYPHRESULT = $tagKHYPH & ";int;char"
;~ KHYPH khyph;
;~ LONG ichHyph;
;~ WCHAR chHyph

Global Const $tagIMECOMPTEXT = "int;dword"
;~ LONG cb;
;~ DWORD flags;

Global Const $tagEN_MSGFILTER = $tagNMHDR & ";uint msg;int wParam;int lParam"
;~ NMHDR nmhdr;
;~ UINT msg;
;~ WPARAM wParam;
;~ LPARAM lParam

Global Const $tagOBJECTPOSITIONS = $tagNMHDR & ";int;int"
;~ NMHDR nmhdr;
;~ LONG cObjectCount;
;~ LONG *pcpPositions

Global Const $tagPARAFORMAT = "uint;uint;short;short;int;int;int;short;short;int[" & $MAX_TAB_STOPS & "]"
;~ UINT cbSize;
;~ DWORD dwMask;
;~ WORD wNumbering;
;~ WORD wReserved;
;~ LONG dxStartIndent;
;~ LONG dxRightIndent;
;~ LONG dxOffset;
;~ WORD wAlignment;
;~ SHORT cTabCount;
;~ LONG rgxTabs[MAX_TAB_STOPS];

Global Const $tagPARAFORMAT2 = "uint;uint;short;short;int;int;int;short;short;int[" & $MAX_TAB_STOPS & "];int;int;int;ushort;byte;byte;short;short;short;short;short;short;short;short"
;								 1	  2	   3	  4	   5   6   7	8	  9		10	  					  11  12  13	14	  15   16	17	  18	19	  20	21    22     23    24
;~ UINT cbSize;
;~ DWORD dwMask;
;~ WORD  wNumbering;
;~ WORD  wEffects;
;~ LONG  dxStartIndent;
;~ LONG  dxRightIndent;
;~ LONG  dxOffset;
;~ WORD  wAlignment;
;~ SHORT cTabCount;
;~ LONG  rgxTabs[MAX_TAB_STOPS];
;~ LONG  dySpaceBefore;
;~ LONG  dySpaceAfter;
;~ LONG  dyLineSpacing;
;~ SHORT sStyle;
;~ BYTE  bLineSpacingRule;
;~ BYTE  bOutlineLevel;
;~ WORD  wShadingWeight;
;~ WORD  wShadingStyle;
;~ WORD  wNumberingStart;
;~ WORD  wNumberingStyle;
;~ WORD  wNumberingTab;
;~ WORD  wBorderSpace;
;~ WORD  wBorderWidth;
;~ WORD  wBorders;

Global Const $tagPUNCTUATION = "uint;ptr"
;~ UINT iSize;
;~ LPSTR szPunctuation

;~ Global $reobject_fmt = "dword;int;int; {
;~     DWORD cbStruct;
;~     LONG cp;
;~     CLSID clsid;
;~     LPOLEOBJECT poleobj;
;~     LPSTORAGE pstg;
;~     LPOLECLIENTSITE polesite;
;~     SIZEL sizel;
;~     DWORD dvaspect;
;~     DWORD dwFlags;
;~     DWORD dwUser

Global Const $tagREPASTESPECIAL = "dword;dword"
;~ DWORD dwAspect;
;~ DWORD_PTR dwParam

Global Const $tagREQRESIZE = $tagNMHDR & ";" & $tagRECT
;~ NMHDR nmhdr;
;~ RECT rc;

Global Const $tagSELCHANGE = $tagNMHDR & ";" & $tagCHARRANGE & ";long seltyp"
;~ NMHDR nmhdr;
;~ CHARRANGE chrg;
;~ WORD seltyp;

Global Const $tagSETTEXTEX = "dword;uint"
;~ DWORD flags;
;~ UINT codepage

Global Const $tagTEXTRANGE = $tagCHARRANGE & ";ptr"
;~ CHARRANGE chrg;
;~ LPSTR lpstrText

;~ Global Const $tagLOGFONT = "int;int;int;int;int;byte;byte;byte;byte;byte;byte;byte;byte;char[" & $LF_FACESIZE & "]"
;~ LONG lfHeight;
;~ LONG lfWidth;
;~ LONG lfEscapement;
;~ LONG lfOrientation;
;~ LONG lfWeight;
;~ BYTE lfItalic;
;~ BYTE lfUnderline;
;~ BYTE lfStrikeOut;
;~ BYTE lfCharSet;
;~ BYTE lfOutPrecision;
;~ BYTE lfClipPrecision;
;~ BYTE lfQuality;
;~ BYTE lfPitchAndFamily;
;~ TCHAR lfFaceName[LF_FACESIZE];

;--------------------------------------------------------------------------------------------------------------------------

;===============================================================================
;
; Description:			_GUICtrlRichEdit_Create
; Parameter(s):		$h_Gui			- Handle to parent window
;							$x					- The left side of the control
;							$y					- The top of the control
;							$width			- The width of the control
;							$height			- The height of the control
;							$v_styles		- styles to apply to the control (Optional) for multiple styles bitor them.
;							$v_exstyles		- extended styles to apply to the control (Optional) for multiple styles bitor them.
; Requirement:
; Return Value(s):   Returns hWhnd if successful, or 0 with error set to 1 otherwise.
; User CallTip:      _GUICtrlRichEdit_Create($h_Gui, $x, $y, $width, $height, [, $v_styles = -1[, $v_exstyles = -1]]) Creates RichEdit Control.
; Author(s):         Gary Frost (gafrost (custompcs@charter.net))
; Note(s):
;===============================================================================
;
Func _GUICtrlRichEdit_Create(ByRef $h_Gui, $x, $y, $width, $height, $v_styles = -1, $v_exstyles = -1)
	Local $h_RichEdit, $style
	If (Not IsHWnd($h_Gui) Or Not IsNumber($h_Gui)) And Not WinExists($h_Gui) Then Return SetError(1, 0, 0)
	If Not IsHWnd($h_Gui) Then $h_Gui = HWnd($h_Gui)
	If $v_styles < 0 Or $v_styles = Default Then $v_styles = 1345343940
	$style = BitOR($WS_CHILD, $WS_VISIBLE, $ES_MULTILINE, $ES_WANTRETURN)
	$style = BitOR($style, $v_styles)
	If $v_exstyles <= -1 Or $v_exstyles = Default Then $v_exstyles = 0

;~ 	Local $stICCE = DllStructCreate('dword;dword')
;~ 	DllStructSetData($stICCE, 1, DllStructGetSize($stICCE))
;~ 	DllStructSetData($stICCE, 2, $ICC_STANDARD_CLASSES)

	$h_RichEdit = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $v_exstyles, _
			"wstr", $_GRE_sRTFClassName, "wstr", "", _
			"dword", $style, "int", $x, "int", $y, "int", $width, "int", $height, _
			"hwnd", $h_Gui, "hwnd", 0, "hwnd", $h_Gui, "ptr", 0)

	If Not @error Then
		Return $h_RichEdit[0]
	Else
		SetError(1)
	EndIf


	Return 0
EndFunc   ;==>_GUICtrlRichEdit_Create

;===============================================================================
;
; Description:			_GUICtrlRichEdit_CreateInput
; Parameter(s):		$h_Gui			- Handle to parent window
;							$x					- The left side of the control
;							$y					- The top of the control
;							$width			- The width of the control
;							$height			- The height of the control
;							$v_styles		- styles to apply to the control (Optional) for multiple styles bitor them.
;							$v_exstyles		- extended styles to apply to the control (Optional) for multiple styles bitor them.
; Requirement:
; Return Value(s):   Returns hWhnd if successful, or 0 with error set to 1 otherwise.
; User CallTip:      _GUICtrlRichEdit_CreateInput($h_Gui, $x, $y, $width, $height, [, $v_styles = -1[, $v_exstyles = -1]]) Creates RichEdit Control.
; Author(s):         Gary Frost (gafrost (custompcs@charter.net))
; Note(s):
;===============================================================================
;
Func _GUICtrlRichEdit_CreateInput(ByRef $h_Gui, $x, $y, $width, $height, $v_styles = -1, $v_exstyles = -1)
	Local $h_RichEdit, $style
	If (Not IsHWnd($h_Gui) Or Not IsNumber($h_Gui)) And Not WinExists($h_Gui) Then Return SetError(1, 0, 0)
	If Not IsHWnd($h_Gui) Then $h_Gui = HWnd($h_Gui)
	If $v_styles < 0 Or $v_styles = Default Then $v_styles = 0x50010100
	$style = BitOR($WS_CHILD, $WS_VISIBLE)
	$style = BitOR($style, $v_styles)
	If $v_exstyles <= -1 Or $v_exstyles = Default Then $v_exstyles = 0

;~ 	Local $stICCE = DllStructCreate('dword;dword')
;~ 	DllStructSetData($stICCE, 1, DllStructGetSize($stICCE))
;~ 	DllStructSetData($stICCE, 2, $ICC_STANDARD_CLASSES)

	$h_RichEdit = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $v_exstyles, _
			"wstr", $_GRE_sRTFClassName, "wstr", "", _
			"dword", $style, "int", $x, "int", $y, "int", $width, "int", $height, _
			"hwnd", $h_Gui, "hwnd", 0, "hwnd", $h_Gui, "ptr", 0)

	If Not @error Then
		Return $h_RichEdit[0]
	Else
		SetError(1)
	EndIf


	Return 0
EndFunc   ;==>_GUICtrlRichEdit_CreateInput

; #FUNCTION# ====================================================================================================================
; Name...........: _GUICtrlRichEdit_Destroy
; Description ...: Destroys the specified window
; Syntax.........: _GUICtrlRichEdit_Destroy($hWnd)
; Parameters ....: $hWnd        - Handle to the richedit to be destroyed
; Return values .: Success      - True
;                  Failure      - False
; Author ........: Paul Campbell (PaulIA)
; Modified.......:
; Remarks .......: You cannot use _WinAPI_DestroyWindow to destroy a window created by a different thread
; Related .......: _WinAPI_CreateWindowEx
; Link ..........; @@MsdnLink@@ DestroyWindow
; Example .......;
; ===============================================================================================================================
Func _GUICtrlRichEdit_Destroy($hWnd)
	Local $aResult

	$aResult = DllCall("User32.dll", "int", "DestroyWindow", "hwnd", $hWnd)
	If @error Then Return SetError(@error, 0, False)
	Return SetExtended($aResult[0], $aResult[0] <> 0)
EndFunc   ;==>_GUICtrlRichEdit_Destroy

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetText()
; Description:     Sets the text of the RichEdit
; Parameter(s):		$h_RichEdit		- Handle to the control
;                   $s_Text         - Text to put into the control
; Requirement:
; Return Value(s):  If the operation is setting all of the text and succeeds, the return value is 1.
;                   If the operation is setting the selection and succeeds, the return value is the number of bytes or characters copied.
;                   If the operation fails, the return value is zero.
; User CallTip:     _GUICtrlRichEdit_SetText($h_Gui, $s_Text) Put text into the RichEdit Control.
; Author(s):        Gary Frost (gafrost (custompcs@charter.net))
;                   -modified by Prog@ndy
; Note(s):
;===============================================================================
;
Func _GUICtrlRichEdit_SetText(ByRef $h_RichEdit, $s_Text = "")
	Return _GUICtrlRichEdit_SetTextEx($h_RichEdit,$s_Text)
EndFunc   ;==>_GUICtrlRichEdit_SetText

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetTextEx()
; Description:     Sets the text of the RichEdit
; Parameter(s):  $h_RichEdit    - Handle to the control
;                   $s_Text         - Plain or RTF Text to put into the control
;                     $iSelect         = True  Replaces the selected text. If successful, the return value is the replacement number of bytes or characters
;                                    = False        Replaces all of the text (if any). If successful, the return value is 1
;                                    = Default-keyword  -- same as True or False, depending on whether text is selected --
;                     $fKeepUndo    - Keeps the undo stack, if set to true. Default: False
; Return values:        See above for success. If fails, returns zero
; Requirement:
; User CallTip:     _GUICtrlRichEdit_SetTextEx($h_Gui[, $s_Text[, $iSelect]]) Sets text in a RichEdit Control.
; Author(s):        Gary Frost (gafrost (custompcs@charter.net))
;                   -modified by Prog@ndy, Chris Haslam
; Note(s):
;===============================================================================
;
Func _GUICtrlRichEdit_SetTextEx(ByRef $h_RichEdit, $s_Text = "",$iSelect=False,$fKeepUndo=False)
    If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
    Local $lResult, $settext_struct
    $settext_struct = DllStructCreate($tagSETTEXTEX)
    If $iSelect = Default Then
        Local $a_sel = _GUICtrlRichEdit_GetSel($h_RichEdit)
        $iSelect = ($a_sel[0] <> $a_sel[1])
    EndIf
    Switch $iSelect
        Case True
            DllStructSetData($settext_struct, 1, $ST_SELECTION+($ST_KEEPUNDO*($fKeepUndo=True)))
        Case False
            DllStructSetData($settext_struct, 1, $ST_DEFAULT+($ST_KEEPUNDO*($fKeepUndo=True)))
        Case Else
            DllStructSetData($settext_struct, 1, $iSelect+($ST_KEEPUNDO*($fKeepUndo=True)))
    EndSwitch
    DllStructSetData($settext_struct, 2, $CP_ACP)
    If StringLeft($s_Text, 5) <> "{\rtf" And StringLeft($s_Text, 5) <> "{urtf" Then
        DllStructSetData($settext_struct, 2, $CP_UNICODE)
        Return _SendMessage($h_RichEdit, $EM_SETTEXTEX, DllStructGetPtr($settext_struct), $s_Text, 0, "ptr", "wstr")
    Else
        Return _SendMessage($h_RichEdit, $EM_SETTEXTEX, DllStructGetPtr($settext_struct), $s_Text, 0, "ptr", "str")
    EndIf
EndFunc   ;==>_GUICtrlRichEdit_SetText

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_AppendText()
; Description:     Replaces text of the current selection of the RichEdit
; Parameter(s):    $h_RichEdit	   - Handle to the control
;                  $s_Text         - Text to put into the control
;                  $fKeepUndo      - [Optional] Keeps the undo stack, if set to true. Default: False
; Requirement(s):
; Return Value(s): If the operation is setting all of the text and succeeds, the return value is 1.
;                   If the operation is setting the selection and succeeds, the return value is the number of bytes or characters copied.
;                   If the operation fails, the return value is zero.
; Author(s):       Gary Frost (gafrost (custompcs@charter.net))
;              -modified by Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_InsertText(ByRef $h_RichEdit, $s_Text = "",$fKeepUndo=False)
	Return _GUICtrlRichEdit_SetTextEx($h_RichEdit,$s_Text,True,$fKeepUndo)
EndFunc   ;==>_GUICtrlRichEdit_InsertText

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_AppendText()
; Description:     Appends text at the end of the RichEdit
; Parameter(s):    $h_RichEdit		- Handle to the control
;                  $s_Text         - Text to put into the control
;                  $fKeepUndo      - [Optional] Keeps the undo stack, if set to true. Default: False
; Requirement(s):
; Return Value(s): If the operation is setting all of the text and succeeds, the return value is 1.
;                   If the operation is setting the selection and succeeds, the return value is the number of bytes or characters copied.
;                   If the operation fails, the return value is zero.
; Author(s):       Gary Frost (gafrost (custompcs@charter.net))
;              -modified by Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_AppendText(ByRef $h_RichEdit, $s_Text = "",$fKeepUndo=False)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)

	Local $length = _GUICtrlRichEdit_GetTextLength($h_RichEdit) + 20
	_GUICtrlRichEdit_SetSel($h_RichEdit, $length, $length)
	Return _GUICtrlRichEdit_SetTextEx($h_RichEdit,$s_Text,True,$fKeepUndo)
EndFunc   ;==>_GUICtrlRichEdit_AppendText

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetTextRange()
; Description:     Gets a textrange
; Parameter(s):    $h_RichEdit		- Handle to the control
;                  $start           - Beginning Index of the text to get
;                  $end             - Ending Index of the text to get
; Requirement(s):
; Return Value(s): The message returns the number of characters copied, not including the terminating null character.
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetTextRange(ByRef $h_RichEdit, $start, $end)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Local $iChars = $end - $start + 3
	If $_GRE_sRTFClassName<>$RICHEDIT_CLASS10A Then
		Local $text_Struct = DllStructCreate("wchar[" & $iChars & "]")
	Else
		Local $text_Struct = DllStructCreate("char[" & $iChars & "]")
	EndIf
	Local $text_Pointer = DllStructGetPtr($text_Struct)
	Local $TextRange_Struct = DllStructCreate($tagTEXTRANGE)
	Local $TextRange_ptr = DllStructGetPtr($TextRange_Struct)
	DllStructSetData($TextRange_Struct, 1, $start)
	DllStructSetData($TextRange_Struct, 2, $end)
	DllStructSetData($TextRange_Struct, 3, $text_Pointer)

	Local $lResult = _SendMessage($h_RichEdit, $EM_GETTEXTRANGE, 0, $TextRange_ptr)

	If @error Then
		Return SetError(-1, -1, "")
	EndIf

	Return DllStructGetData($text_Struct, 1)
EndFunc   ;==>_GUICtrlRichEdit_GetTextRange


;================================================================================================================================
; Name...........:  _GUICtrlRichEdit_CharFromPos
; Description ...: Retrieve information about the character closest to a specified point in the client area
; Syntax.........: _GUICtrlRichEdit_CharFromPos($hWnd, $iX, $iY)
; Parameters ....: $hWnd        - Handle to the control
; Return values .: Success      - zero-based character index of the character nearest the specified point
;                                 (last character in the edit control if the specified point is beyond the last character in the control.)
; Author ........: Gary Frost (gafrost)
; Modified.......: Prog@ndy
; Remarks .......:
; Related .......:
; Link ..........;
; Example .......; Yes
;===============================================================================================================================
;
Func _GUICtrlRichEdit_CharFromPos($hWnd, $iX, $iY)
	If Not IsHWnd($hWnd) Then $hWnd = HWnd($hWnd)

	Local $iResult, $POINTL = DllStructCreate("LONG x; LONG y;")
	DllStructSetData($POINTL, 1, $iX)
	DllStructSetData($POINTL, 2, $iY)
	$iResult = _SendMessage($hWnd, $EM_CHARFROMPOS, 0, DllStructGetPtr($POINTL), 0, "wparam", "ptr")
	Return $iResult
EndFunc   ;==>_GUICtrlRichEdit_CharFromPos


;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_FindTextEx
; Description::    Sucht nach dem angegebenen Text
; Parameter(s):    $h_RichEdit - RichEdit
;                  $SuchText   - Text zum suchen
;                  $StartPos   - [Optional] Anfangsposition (Standard: Anfang des Textes)
;                  $EndPos     - [Optional] Endposition (Standard: Ende des Textes)
;                  $giveArray  - [Optional] ein array mit Anfang und Ende des Suchstrings geben
;                                     (Standard: Nur den Anfang)
; Requirement(s):  RichEdit
; Return Value(s): Anfangsposition des Suchstrings oder array mit Anfang und Ende
; Author(s):       Prog@ndy
;
;===============================================================================
;

Func _GUICtrlRichEdit_FindTextEx($h_RichEdit,$SuchText,$StartPosition=0,$EndPosition=-1,$giveArray=0)
	Local $FINDTEXTEX = DllStructCreate($tagFINDTEXTEX)
	; suchpositionen:
	DllStructSetData($FINDTEXTEX,1,0) ; Anfang: 0 = von ganz oben
	DllStructSetData($FINDTEXTEX,2,-1) ; Ende: -1 = bis ganz ans Ende
	Local $structSuchText = DllStructCreate("wchar[" & StringLen($SuchText)+1 & "]")
	DllStructSetData($structSuchText,1,$SuchText)
	DllStructSetData($FINDTEXTEX,3,DllStructGetPtr($structSuchText)) ; desn suchtext in die struct aufnehmen
	Local $start = _SendMessage($h_RichEdit,$EM_FINDTEXTEXW,DllStructGetPtr($FINDTEXTEX))
	If $giveArray And $start>=0 Then
		Local $array[2] = [DllStructGetData($FINDTEXTEX,4),DllStructGetData($FINDTEXTEX,5)]
		If $array[1] Then Return $array
	EndIf
	Return $start
EndFunc


;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetText()
; Description:     Same as _GUICtrlRichEdit_GetTextEx()
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetText(ByRef $h_RichEdit)
	Local $text = _GUICtrlRichEdit_GetTextEx($h_RichEdit)
	Return SetError(@error, 0, $text)
EndFunc   ;==>_GUICtrlRichEdit_GetText

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetTextEx()
; Description:     Gets the full text of a RichEdit
; Parameter(s):    $h_RichEdit		- Handle to the control
; Requirement(s):
; Return Value(s): Returns Text, @extended = are any default Characters used (non-ACP Unicode characters were replaced)
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetTextEx(ByRef $h_RichEdit)
	Local $buffLen = _GUICtrlRichEdit_GetTextLength($h_RichEdit) + 1
	If $_GRE_sRTFClassName<>$RICHEDIT_CLASS10A Then
		Local $text_Struct = DllStructCreate("wchar[" & $buffLen & "]")
	Else
		Local $text_Struct = DllStructCreate("char[" & $buffLen & "]")
	EndIf
	Local $TextEx_Struct = DllStructCreate($tagGETTEXTEX)
	Local $text_Pointer = DllStructGetPtr($text_Struct)
	Local $textEx_Ptr = DllStructGetPtr($TextEx_Struct)
	DllStructSetData($TextEx_Struct, 1, DllStructGetSize($text_Struct))
	DllStructSetData($TextEx_Struct, 2, $GT_USECRLF)
	DllStructSetData($TextEx_Struct, 3, $CP_UNICODE)
	If $_GRE_sRTFClassName==$RICHEDIT_CLASS10A Then DllStructSetData($TextEx_Struct, 3, $CP_ACP)
	Local $lResult = _SendMessage($h_RichEdit, $EM_GETTEXTEX, $textEx_Ptr, $text_Pointer)
	If $lResult = 0 Then Return SetError(1, 0, "")
	SetExtended(DllStructGetData($TextEx_Struct, 5))
	Return StringLeft(DllStructGetData($text_Struct, 1),$lResult)
EndFunc   ;==>_GUICtrlRichEdit_GetTextEx

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetTextLength()
; Description:     Gets the length of the text full in a RichEdit
; Parameter(s):    $h_RichEdit		- Handle to the control
;                  $Exact           - Should it be the exact number of characters?
; Requirement(s):
; Return Value(s): The message returns the number of characters in the edit control
;                  If $Exact is not set, it returns only the approximate length
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetTextLength(ByRef $h_RichEdit, $Exact = False)
	Local $GetTxtLen_Struct = DllStructCreate($tagGETTEXTLENGTHEX)
	Local $Txtlen_Ptr = DllStructGetPtr($GetTxtLen_Struct)
	If $Exact Then
		DllStructSetData($GetTxtLen_Struct, 1, BitOR($GTL_USECRLF, $GTL_PRECISE))
	Else
		DllStructSetData($GetTxtLen_Struct, 1, BitOR($GTL_USECRLF, $GTL_CLOSE))
	EndIf
	DllStructSetData($GetTxtLen_Struct, 2, $CP_UNICODE)
	If $_GRE_sRTFClassName==$RICHEDIT_CLASS10A Then DllStructSetData($GetTxtLen_Struct, 2, $CP_ACP)
	Local $lResult = _SendMessage($h_RichEdit, $EM_GETTEXTLENGTHEX, $Txtlen_Ptr, 0)
	Return $lResult

EndFunc   ;==>_GUICtrlRichEdit_GetTextLength

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetSelText()
; Description:     Gets the selected text of a RichEdit
; Parameter(s):    $h_RichEdit		- Handle to the control
; Requirement(s):
; Return Value(s): Returns selected Text
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetSelText($h_RichEdit)
;~ 	If Not _IsClassName ($h_Edit, "Edit") Then Return SetError($EC_ERR, $EC_ERR, $EC_ERR)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Local $selection = _GUICtrlRichEdit_GetSel($h_RichEdit)
	If UBound($selection) <> 2 Then Return SetError($EC_ERR, $EC_ERR, "")
	Local $a_selm, $ptr1 = "wchar[" & $selection[1] - $selection[0] + 2 & "]"
	If $_GRE_sRTFClassName==$RICHEDIT_CLASS10A Then $ptr1 = StringTrimLeft($ptr1,1)
	Local $lparam = DllStructCreate($ptr1)
	If @error Then Return SetError($EC_ERR, $EC_ERR, "")
	Local $i_ret = _SendMessage($h_RichEdit, $EM_GETSELTEXT, 0, DllStructGetPtr($lparam))
	If ($i_ret == 0) Then Return SetError($EC_ERR, $EC_ERR, "")
	Return DllStructGetData($lparam, 1)
EndFunc   ;==>_GUICtrlRichEdit_GetSelText

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetSel()
; Description:      Retrieves the starting and ending character positions of the current selection in an edit control.
; Parameter(s):     $h_RichEdit - controlID
; Requirement:      None
; Return Value(s):  Array containing the starting and ending selected positions
;							If an error occurs, the return value is $EC_ERR.
; Author(s):			Prog@ndy
; Note(s):				Return value: $array[1] contains the starting position
;							          $array[2] contains the ending position
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetSel($h_RichEdit)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Return _GUICtrlRichEdit_GetSelection($h_RichEdit)
EndFunc   ;==>_GUICtrlRichEdit_GetSel

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetSel()
; Description:     Selects a range of characters in an edit control.
; Parameter(s):		$h_RichEdit - controlID
;							$i_start - Specifies the starting character position of the selection.
;							$i_end - Specifies the ending character position of the selection.
; Requirement:			None
; Return Value(s):	None
; Author(s):			Gary Frost (custompcs at charter dot net)
; Note(s):				The start value can be greater than the end value.
;							The lower of the two values specifies the character position of the first character in the selection.
;							The higher value specifies the position of the first character beyond the selection.
;
;							The start value is the anchor point of the selection, and the end value is the active end.
;							If the user uses the SHIFT key to adjust the size of the selection, the active end can move but the anchor point remains the same.
;
;							If the $i_start is 0 and the $i_end is –1, all the text in the edit control is selected.
;							If the $i_start is –1, any current selection is deselected.
;
;							The control displays a flashing caret at the $i_end position regardless of the relative values of $i_start and $i_end.
;
;===============================================================================
;
Func _GUICtrlRichEdit_SetSel($h_RichEdit, $i_start, $i_end, $i_HideSel = 0)
;~ 	If Not _IsClassName ($h_RichEdit, "Edit") Then Return SetError($EC_ERR, $EC_ERR, 0)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Local $return = _SendMessage($h_RichEdit, $EM_SETSEL, $i_start, $i_end)
	If $i_HideSel > -1 Then _SendMessage($h_RichEdit, $EM_HIDESELECTION, $i_HideSel)
	Return $return
EndFunc   ;==>_GUICtrlRichEdit_SetSel

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_HideSelection
; Description:     Sets wheter the selection mark is visible.
; Parameter(s):    $hWnd
; Requirement(s):
; Return Value(s): If the functions succeeds returns >0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_HideSelection($hWnd, $iState = True)
	Return _SendMessage($hWnd, $EM_HIDESELECTION, $iState, 0)
EndFunc   ;==>_GUICtrlRichEdit_HideSelection


;===============================================================================
;
; Function Name:    _GUICtrlRichEdit_GetLineCount
; Description:      Retrieves the number of lines in a multiline edit control.
; Parameter(s):		$h_RichEdit - controlID
; Requirement:			None
; Return Value(s):	The return value is an integer specifying the total number of text lines in the multiline edit control.
; Author(s):			Gary Frost (custompcs at charter dot net)
; Note(s):				If the control has no text, the return value is 1.
;							The return value will never be less than 1.
;
;							The _GUICtrlEditGetLineCount retrieves the total number of text lines,
;							not just the number of lines that are currently visible.
;
;							If the Wordwrap feature is enabled, the number of lines can change when the dimensions of the editing window change.
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetLineCount($h_RichEdit)
;~ 	If Not _IsClassName ($h_RichEdit, "Edit") Then Return SetError($EC_ERR, $EC_ERR, $EC_ERR)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Return _SendMessage($h_RichEdit, $EM_GETLINECOUNT)
EndFunc   ;==>_GUICtrlRichEdit_GetLineCount

;===============================================================================
;
; Function Name:    _GUICtrlRichEdit_LineIndex
; Description:      Retrieves the character index of the first character of a specified line in a multiline edit control.
; Parameter(s):		$h_RichEdit - controlID
;							$i_line - Optional: Specifies the zero-based line number.
;										A value of –1 specifies the current line number (the line that contains the caret).
; Requirement:			None
; Return Value(s):	The return value is the character index of the line specified in the wParam parameter,
;							or it is $EC_ERR if the specified line number is greater than the number of lines in the edit control.
; Author(s):			Gary Frost (custompcs at charter dot net)
; Note(s):
;
;===============================================================================
;
Func _GUICtrlRichEdit_LineIndex($h_RichEdit, $i_line = -1)
;~ 	If Not _IsClassName ($h_RichEdit, "Edit") Then Return SetError($EC_ERR, $EC_ERR, $EC_ERR)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Return _SendMessage($h_RichEdit, $EM_LINEINDEX, $i_line)
EndFunc   ;==>_GUICtrlRichEdit_LineIndex

;===============================================================================
;
; FUnction Name:    _GUICtrlRichEdit_LineLength
; Description:      Retrieves the length, in characters, of a line in an edit control.
; Parameter(s):		$h_RichEdit - controlID
;							$i_index - Optional: Specifies the character index of a character in the line whose length is to be retrieved.
; Requirement:			None
; Return Value(s):	For multiline edit controls, the return value is the length, in TCHARs, of the line specified by the $i_index parameter.
;							For single-line edit controls, the return value is the length, in TCHARs, of the text in the edit control.
; Author(s):			Gary Frost (custompcs at charter dot net)
; Note(s):				$i_index
;								For ANSI text, this is the number of bytes
;								For Unicode text, this is the number of characters.
;								It does not include the carriage-return character at the end of the line.
;								If $i_index is greater than the number of characters in the control, the return value is zero.
;
;===============================================================================
;
Func _GUICtrlRichEdit_LineLength($h_RichEdit, $i_index = -1)
;~ 	If Not _IsClassName ($h_RichEdit, "Edit") Then Return SetError($EC_ERR, $EC_ERR, $EC_ERR)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Return _SendMessage($h_RichEdit, $EM_LINELENGTH, $i_index)
EndFunc   ;==>_GUICtrlRichEdit_LineLength

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetFirstVisibleLine
; Description:     Gets the first line which is visible in the Control
; Parameter(s):    $h_RichEdit - The handle of the RichEdit
; Requirement(s):
; Return Value(s): The line number of the first visible line.
; Author(s):       Gary Frost
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetFirstVisibleLine(ByRef $h_RichEdit)
	Return _SendMessage($h_RichEdit, $EM_GETFIRSTVISIBLELINE)
EndFunc   ;==>_GUICtrlRichEdit_GetFirstVisibleLine

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetZoom
; Description:     Sets the zoomlevel of the RichEdit.
; Parameter(s):    $h_RichEdit - The handle of the RichEdit
;                  $nominator  - Numerator of the zoom ratio.
;                  $denominator  - Denominator of the zoom ratio.
; Requirement(s):
; Return Value(s):     If the new zoom setting is accepted, the return value is TRUE.
;                      If the new zoom setting is not accepted, the return value is FALSE.
; Author(s):       Gary Frost
; Notes:           $nominator and $denominator: Both 0
;                       -> Turns off zooming by using the EM_SETZOOM message
;                  1/64 < ($nominator / $denominator) < 64
;                       -> Zooms display by the zoom ratio numerator/denominator
;
;===============================================================================
;
Func _GUICtrlRichEdit_SetZoom(ByRef $h_RichEdit, $nominator = 0, $denominator = 0)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Local $lResult = _SendMessage($h_RichEdit, $EM_SETZOOM, $nominator, $denominator)
	If Not @error Then
		Return $lResult
	Else
		Return SetError(1, 1, 0)
	EndIf
EndFunc   ;==>_GUICtrlRichEdit_SetZoom

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetZoom
; Description:     Sets the zoomlevel of the RichEdit.
; Parameter(s):    $h_RichEdit - The handle of the RichEdit
;                  $nominator  - Numerator of the zoom ratio.
;                  $denominator  - Denominator of the zoom ratio.
; Requirement(s):
; Return Value(s):     On success return Array:
;                         [0] -> nominator
;                         [1] -> denominator
;                      On error returns 0 and @error set to 1
; Author(s):       Gary Frost, Prog@ndy
; Notes:           $nominator and $denominator: Both 0
;                       -> Turns off zooming by using the EM_SETZOOM message
;                  1/64 < ($nominator / $denominator) < 64
;                       -> Zooms display by the zoom ratio numerator/denominator
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetZoom(ByRef $h_RichEdit)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Local $lResult = _SendMessage($h_RichEdit, $EM_GETZOOM, 0, 0, -1,"int*","int*")
	If Not @error And $lResult[0] = True Then
		Local $return[2] = [$lResult[3], $lResult[4]]
		Return $return
	EndIf
	Return SetError(1, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_GetZoom

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetEffect
; Description:     adds, removes effects and set to undefined
; Parameter(s):    $dwMask: the Mask for _GUICtrlRichEdit_SetFormat
;                  $dwEffects: the Effects for _GUICtrlRichEdit_SetFormat
;                  $effect: the effect to change
;                  $Flag: 1 : add the style       -> the Style will be set in RichEdit
;                         0 : delete the style    -> the Style will be removed in RichEdit
;                        -1 : set it to undefined -> the Style won't be changed in RichEdit
; Requirement(s):  RichEditUDF
; Return Value(s): Success: 1, Error 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_SetEffect(ByRef $dwMask, ByRef $dwEffects, $effect, $Flag = 1)
	Switch $Flag
		Case - 1
			$dwMask = BitAND($dwMask, BitNOT($effect))
			$dwEffects = BitAND($dwEffects, BitNOT($effect))
		Case 0
			$dwMask = BitOR($dwMask, $effect)
			$dwEffects = BitAND($dwEffects, BitNOT($effect))
		Case 1
			$dwMask = BitOR($dwMask, $effect)
			$dwEffects = BitOR($dwEffects, $effect)
		Case Else
			Return SetError(1, 0, 0)
	EndSwitch
	Return 1
EndFunc   ;==>_GUICtrlRichEdit_SetEffect

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetFormat
; Description:     Sets the format of the specified Format Range
; Parameter(s):    $h_RichEdit - The handle of the RichEdit
;                  $iFormatRange - Character formatting that applies to the control.
;                           If this parameter is zero, the default character format
;                           is set. Otherwise, it can be one of the following values:
;                           $SCF_ALL, $SCF_ASSOCIATEFONT, $SCF_DEFAULT, $SCF_NOKBUPDATE, $SCF_SELECTION, $SCF_USEUIRULES, $SCF_WORD
;                  $dwMask, $dwEffects: setting of Character effects
;                      To set effects, simply use _GUICtrlRichEdit_SetEffect on those variables ( before calling this function )
;                  The other parameters can be found at http://msdn.microsoft.com/en-us/library/bb787883(VS.85).aspx
; Requirement(s):  This function needs RichEdit 2.0 to work, because it uses CHARFORMAT2 for Win95, you have to write it on your own.
; Return Value(s): If the operation succeeds, the return value is a nonzero value.
;                  If the operation fails, the return value is zero.
; Author(s):       Gary Frost (gafrost (custompcs@charter.net))
;              -modified by Prog@ndy
;
;===============================================================================
;
; This can be done easily with _GUICtrlRichEdit_SetEffect
Func _GUICtrlRichEdit_SetFormat(ByRef $h_RichEdit, $iFormatRange, $dwMask, $dwEffects, $yHeight = -1, $yOffset = Default, _
		$crTextColor = -1, $bCharSet = -1, $bPitchAndFamily = -1, $szFaceName = "", _
		$wWeight = -1, $crBackColor = -1, $Underline = -1, $bUnderlineType = -1, $colorsAreCOLORREF = False)
	If Not IsHWnd($h_RichEdit) Then $h_RichEdit = HWnd($h_RichEdit)
	Local $charformat_struct, $lResult, $Format, $a_sel

	$charformat_struct = DllStructCreate($tagCHARFORMAT2)

	If $crBackColor > -1 Then
		$dwMask = BitOR($dwMask, $CFM_BACKCOLOR)
		If Not $colorsAreCOLORREF Then $crBackColor = __GCR_ColorConvert($crBackColor)
		DllStructSetData($charformat_struct, "crBackColor", $crBackColor)
	EndIf
;~ The crTextColor member is valid unless the CFE_AUTOCOLOR flag is set in the dwEffects member.
	If $crTextColor > -1 Then
		$dwMask = BitOR($dwMask, $CFM_COLOR)
		If Not $colorsAreCOLORREF Then $crTextColor = __GCR_ColorConvert($crTextColor)
		DllStructSetData($charformat_struct, "crTextColor", $crTextColor)
	EndIf
;~ The szFaceName member is valid.
	If $szFaceName <> "" Then
		$dwMask = BitOR($dwMask, $CFM_FACE)
		DllStructSetData($charformat_struct, 9, $szFaceName)
	EndIf
;~ The yOffset member is valid.
	If $yOffset <> Default Then
		$dwMask = BitOR($dwMask, $CFM_OFFSET)
		DllStructSetData($charformat_struct, 5, $yOffset)
	EndIf
;~ The yHeight member is valid.
	If $yHeight <> -1 Then
		$dwMask = BitOR($dwMask, $CFM_SIZE)
		DllStructSetData($charformat_struct, 4, $yHeight)
	EndIf
;~ 	The charset-Parameter
	If $bCharSet <> -1 Then
		$dwMask = BitOR($dwMask, $CFM_CHARSET)
		DllStructSetData($charformat_struct, 7, $bCharSet)
	EndIf
;~ The bUnderlineType member is valid.
	If $bUnderlineType <> -1 Then
		$dwMask = BitOR($dwMask, $CFM_UNDERLINETYPE)
		DllStructSetData($charformat_struct, "bUnderlineType", $bUnderlineType)
	EndIf
;~ The wWeight member is valid.
	If $wWeight <> -1 Then
		$dwMask = BitOR($dwMask, $CFM_WEIGHT)
		DllStructSetData($charformat_struct, "wWeight", $wWeight)
	EndIf

	If $iFormatRange = -1 Then
		$a_sel = _GUICtrlRichEdit_GetSel($h_RichEdit)
		If $a_sel[0] = $a_sel[1] Then
			$Format = $SCF_ALL
			__GCR_DebugPrint("$SCF_ALL")
		Else
			$Format = $SCF_SELECTION
			__GCR_DebugPrint("$SCF_SELECTION")
		EndIf
	EndIf

	DllStructSetData($charformat_struct, 1, DllStructGetSize($charformat_struct))
	DllStructSetData($charformat_struct, 2, $dwMask)
	DllStructSetData($charformat_struct, 3, $dwEffects)




	DllStructSetData($charformat_struct, 8, $bPitchAndFamily)


	$lResult = _SendMessage($h_RichEdit, $EM_SETCHARFORMAT, $iFormatRange, DllStructGetPtr($charformat_struct), 0, "wparam", "ptr")
	If @error Or $lResult = 0 Then
		If $__GCR_DebugIt Then __GCR_DebugPrint("Error setting char format information" & @LF & __GCR_GetLastErrorMessage("Error setting char format information"))
		Return SetError($EC_ERR, $EC_ERR, $EC_ERR)
	Else
		Return 1
	EndIf
EndFunc   ;==>_GUICtrlRichEdit_SetFormat

;====================================================================================================
; Function Name : _GUICtrlRichEdit_BkColor
; Description:    Sets a background color of a richedit control
; Parameters    : $hWnd         - Handle to the control
;                 $iColor       - Color to set
; Return values : none
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_BkColor($hWnd, $iColor)
	Return _SendMessage($hWnd, $EM_SETBKGNDCOLOR, 0, $iColor)
EndFunc   ;==>_GUICtrlRichEdit_BkColor

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetFontName
; Description:    Retrieves the font Name of the selected Text
; Parameters    : $hWnd         - Handle to the control
; Return values : Font name
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetFontName($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return DllStructGetData($tcharformat, 9)
EndFunc   ;==>_GUICtrlRichEdit_GetFontName

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetFontSize
; Description:    Retrieves the font size of the selected text. ( in printer points )
; Parameters    : $hWnd         - Handle to the control
; Return values : Font size
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetFontSize($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return DllStructGetData($tcharformat, 4) / 20
EndFunc   ;==>_GUICtrlRichEdit_GetFontSize

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetBold
; Description:    Retrieves if the selected text is bold.
; Parameters    : $hWnd         - Handle to the control
; Return values : Returns True or False
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetBold($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return BitAND(DllStructGetData($tcharformat, 3), $CFE_BOLD) / 1
EndFunc   ;==>_GUICtrlRichEdit_GetBold

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetItalic
; Description:    Retrieves if the selected text is italic.
; Parameters    : $hWnd         - Handle to the control
; Return values : Returns True or False
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetItalic($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return BitAND(DllStructGetData($tcharformat, 3), $CFE_ITALIC) / 2
EndFunc   ;==>_GUICtrlRichEdit_GetItalic

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetUnderline
; Description:    Retrieves if the selected text is underlined.
; Parameters    : $hWnd         - Handle to the control
; Return values : Returns True or False
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetUnderline($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return BitAND(DllStructGetData($tcharformat, 3), $CFE_UNDERLINE) / 4
EndFunc   ;==>_GUICtrlRichEdit_GetUnderline

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetStrikeOut
; Description:    Retrieves if the selected textis striked out.
; Parameters    : $hWnd         - Handle to the control
; Return values : Returns True or False
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetStrikeOut($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return BitAND(DllStructGetData($tcharformat, 3), $CFE_STRIKEOUT) / 8
EndFunc   ;==>_GUICtrlRichEdit_GetStrikeOut

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetFontColor
; Description:    Retrieves the Color of the selected text.
; Parameters    : $hWnd         - Handle to the control
; Return values : Font color (Hex)
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetFontColor($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return "0x" & StringTrimLeft(Hex(DllStructGetData($tcharformat, 6)), 2)
EndFunc   ;==>_GUICtrlRichEdit_GetFontColor

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetBkColor
; Description:    Retrieves the Background color of the selected text.
; Parameters    : $hWnd         - Handle to the control
; Return values : Background color (Hex)
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetBkColor($hWnd)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	Return 0 & "x" & StringTrimLeft(Hex(DllStructGetData($tcharformat, 12)), 2)
EndFunc   ;==>_GUICtrlRichEdit_GetBkColor

;====================================================================================================
; Function Name : _GUICtrlRichEdit_GetFormat
; Description:    Retrieves the Format of the selected text.
; Parameters    : $hWnd         - Handle to the control
; Return values : Returns an Array with font format
;							index 0: bold-italic-underline-strikeout
;								  1: fontcolor
;								  2: backgroundcolor
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetFormat($hWnd)
	Local $Array[3]
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	_SendMessage($hWnd, $EM_GETCHARFORMAT, $SCF_SELECTION, DllStructGetPtr($tcharformat))
	$Array[0] = BitAND(DllStructGetData($tcharformat, 3), $CFE_BOLD) / 1 & _
			BitAND(DllStructGetData($tcharformat, 3), $CFE_ITALIC) / 2 & _
			BitAND(DllStructGetData($tcharformat, 3), $CFE_UNDERLINE) / 4 & _
			BitAND(DllStructGetData($tcharformat, 3), $CFE_STRIKEOUT) / 8
	$Array[1] = 0 & "x" & StringTrimLeft(Hex(DllStructGetData($tcharformat, 6)), 2)
	$Array[2] = 0 & "x" & StringTrimLeft(Hex(DllStructGetData($tcharformat, 12)), 2)
	Return $Array
EndFunc   ;==>_GUICtrlRichEdit_GetFormat

;====================================================================================================
; Function Name: _GUICtrlRichEdit_GetNumbering
; Description:    Gets paragraph numbering and numbering type
; Parameters    : $hWnd         - Handle to the control
;                  $iChar        - Characters used for numbering:
;                                        0                     No numbering
;                               1 or $PFN_BULLET    Inserts a bullet
;                               2                   Arabic numbres (1,2,3   .)
;                               3                   Lowercase tetters
;                               4                   Uppercase letters
;                               5                   Lowercase roman numerals (i,ii,iii...)
;                               6                   Uppercase roman numerals (I, II,   .)
;                               7                   Uses a sequence of characters beginning with
;                                                    +the Unicode character specified by
;                                                    +the wNumberingStart member
;                 $iFormat      - Numbering style used with numbered paragraphs
;                               0                   Follows the number with a right parenthesis.
;                               0x100               Encloses the number in parentheses.
;                               0x200               Follows the number with a period.
;                               0x300               Displays only the number.
;                               0x400               Continues a numbered list without
;                                                    +applying the next number or bullet.
;                               0x8000              Starts a new number with wNumberingStart.
;                 $iStart       - Starting number or Unicode value used for numbered paragraphs.
;                 $iTab         - Minimum space between a paragraph number and the paragraph text, in twips.
; Return value: 1 for success, 0 for failure, and sets @error to 1
; Author        : chris haslam    c dot haslam at ieee dot org
; Notes         :
;====================================================================================================
 Func _GUICtrlRichEdit_GetNumbering($hWnd, ByRef $iChar , ByRef $iFormat , ByRef $iStart , ByRef $iTab)
    Local $tparaformat = DllStructCreate($tagPARAFORMAT),$dwMask=0
    DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
    Local $lResult = _SendMessage($hWnd, $EM_GETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
    If @error Then Return SetError(1,-1,0)
   $iChar = DllStructGetData($tparaformat, 3)
    $iStart = DllStructGetData($tparaformat, 19)
    $iFormat = DllStructGetData($tparaformat, 20)
    $iTab = DllStructGetData($tparaformat, 21)
    Return 1
EndFunc   ;==>_GUICtrlRichEdit_GetNumbering

;====================================================================================================
; Function Name:   _GUICtrlRichEdit_GetSelection()
; Description:      Retrieves the starting and ending character positions of the current selection in an edit control.
; Parameters    : $hWnd         - Handle to the control
; Return values : Returns the beginning and the ending position of the selection
; Author        :
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetSelection($hWnd)
	Local $tcharrange = DllStructCreate($tagCHARRANGE), $Array[2]
	_SendMessage($hWnd, $EM_EXGETSEL, 0, DllStructGetPtr($tcharrange))
	$Array[0] = DllStructGetData($tcharrange, 1)
	$Array[1] = DllStructGetData($tcharrange, 2)
	Return $Array
EndFunc   ;==>_GUICtrlRichEdit_GetSelection

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_GetScrollPos
; Description:     Gets the Scrolling position of a GCR
; Parameter(s):    $hRichText - handle to RichEdit
; Return Value(s): Array: [0]
; Author(s):       KIP, or otherwere from the forum ?
;
;===============================================================================
;
Func _GUICtrlRichEdit_GetScrollPos($hRichText)
	Local $return[2]

	Local $sT = DllStructCreate("long x; long y")

	Local $iRet = _SendMessage($hRichText, $EM_GETSCROLLPOS, 0, DllStructGetPtr($sT))

	$return[0] = DllStructGetData($sT, 1)
	$return[1] = DllStructGetData($sT, 2)

	Return $return
EndFunc   ;==>_GUICtrlRichEdit_GetScrollPos

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetScrollPos
; Description:     Sets the Scrolling position of a GCR
; Parameter(s):    $hRichText - handle to RichEdit
; Return Value(s): Array: [0]
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_SetScrollPos($hRichText, $Xcoord, $Ycoord)
	Local $return[2]

	Local $sT = DllStructCreate("long x; long y")
	DllStructSetData($sT, 1, $Xcoord)
	DllStructSetData($sT, 2, $Ycoord)
	Return _SendMessage($hRichText, $EM_SETSCROLLPOS, 0, DllStructGetPtr($sT))
EndFunc   ;==>_GUICtrlRichEdit_SetScrollPos


;====================================================================================================
; Function Name:  _GUICtrlRichEdit_IncreaseFontSize
; Description:    Increase or decrease the font size
; Parameters    : $hWnd         - Handle to the control
;                 $hDelta       - Value of incrementation, Negative ==> decrementation
; Return values : Returns True if successful, or False otherwise
; Author        :
; Notes         : Apllied to the the end of text
;====================================================================================================
;
Func _GUICtrlRichEdit_IncreaseFontSize($hWnd, $hDelta = 1)
	Local $textlength = _SendMessage($hWnd, $WM_GETTEXTLENGTH, 0, 0)
	_GUICtrlRichEdit_SetSel($hWnd, $textlength, $textlength, 1)
	Return _SendMessage($hWnd, $EM_SETFONTSIZE, $hDelta, 0)
EndFunc   ;==>_GUICtrlRichEdit_IncreaseFontSize

;====================================================================================================
; Function Name: _GUICtrlRichEdit_LimitText
; Description:    Limit the control to N chararacters
; Parameters    : $hWnd         - Handle to the control
;                 $hLimitTo     - Number of characters
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Notes         : Set 0 to disable the limit ( set to default, which is 64000 )
;====================================================================================================
;
Func _GUICtrlRichEdit_LimitText($hWnd, $hLimitTo)
	Switch $hLimitTo>64000
		Case True
			Local $Return = _SendMessage($hWnd, $EM_EXLIMITTEXT, $hLimitTo, 0)
			If $Return =0 Then ContinueCase
			Return $Return
		Case Else
			Return _SendMessage($hWnd, $EM_LIMITTEXT, $hLimitTo, 0)
	EndSwitch
EndFunc   ;==>_GUICtrlRichEdit_LimitText

;====================================================================================================
; Function Name:  _GUICtrlRichEdit_SetAlignment
; Description:    Sets Paragraph alignment.
; Parameters    : $hWnd         - Handle to the control
;                 $iAlignment   Values:
;                               1 or $PFA_LEFT		Paragraphs are aligned with the left margin.
;                               2 or $PFA_RIGHT     Paragraphs are aligned with the right margin.
;                               3 or $PFA_CENTER    Paragraphs are centered.
;                               4 or $PFA_JUSTIFY 	Paragraphs are justified. This value is
;													+included for compatibility with TOM interfaces;
;													+rich edit controls earlier than Rich Edit 3.0
;													+display the text aligned with the left margin.
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetAlignment($hWnd, $iAlignment) ; 1 ==> Left, 2 ==> Right, 3 ==> Center, 4 ==> Justify
	Local $tparaformat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
	DllStructSetData($tparaformat, 2, $PFM_ALIGNMENT)
	DllStructSetData($tparaformat, 8, $iAlignment)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
EndFunc   ;==>_GUICtrlRichEdit_SetAlignment

;====================================================================================================
; Function Name:  _GUICtrlRichEdit_SetFontName
; Description:    Select the Font Name
; Parameters    : $hWnd         - Handle to the control
;           	  $hFontName    - Name of the Font
;                 $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Modified      : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetFontName($hWnd, $hFontName, $iSelec = True)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_FACE)
	DllStructSetData($tcharformat, 9, $hFontName)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetFontName

;====================================================================================================
; FUnction Name:  _GUICtrlRichEdit_SetFontSize
; Description:    Set Font size
; Parameters    : $hWnd        - Handle to the control
;                 $iSize       - Size of the Font
;              	  $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Modified      : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetFontSize($hWnd, $iSize, $iSelec = True)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_SIZE)
	DllStructSetData($tcharformat, 4, $iSize * 20)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetFontSize

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetBold
; Description:    Toggle the Bold effect
; Parameters    : $hWnd         - Handle to the control
;                 $iStyle		- True = Set; False = Unset
;                 $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Modified     :  grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetBold($hWnd, $iStyle = True, $iSelec = True, $iHL = True)
	If $iStyle Then $iStyle = $CFE_BOLD
	If $iHL Then $iHL = $CFE_LINK
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_BOLD)
	DllStructSetData($tcharformat, 3, $iStyle)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetBold

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetItalic
; Description:    Toggle the Italic effect
; Parameters    : $hWnd         - Handle to the control
;                 $iStyle		- True = Set; False = Unset
;                 $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Modified     :  grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetItalic($hWnd, $iStyle = True, $iSelec = True)
	If $iStyle Then $iStyle = $CFE_ITALIC
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_ITALIC)
	DllStructSetData($tcharformat, 3, $iStyle)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetItalic

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetLineSpacing
; Description:    Type of line spacing.
; Parameters    : $hWnd         - Handle to the control
;                 $iNum	        Values:
;                               0					Single spacing.
;                               1                   One-and-a-half spacing.
;								2                   Double spacing.
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetLineSpacing($hWnd, $iNum, $iTwips = 0) ; 0 => 1, 1 => 1+1/2; 2 => 2
	Local $tparaformat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
	DllStructSetData($tparaformat, 2, BitOR($PFM_LINESPACING, $PFM_SPACEAFTER))
	If $iTwips <> 0 Then DllStructSetData($tparaformat, 13, $iTwips * 20)
	DllStructSetData($tparaformat, 15, $iNum)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
EndFunc   ;==>_GUICtrlRichEdit_SetLineSpacing

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetLink
; Description:    Toggle the Underline effect
; Parameters    : $hWnd         - Handle to the control
;                 $iStyle		- True = Set; False = Unset
;                 $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetLink($hWnd, $iStyle = True, $iSelec = True)
	If $iStyle Then $iStyle = $CFE_LINK
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_LINK)
	DllStructSetData($tcharformat, 3, $iStyle)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetLink

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetOffSet
; Description:    Indentation of the second and subsequent lines,
;				  +relative to the indentation of the first line, in twips.
; Parameters    : $hWnd         - Handle to the control
;                 $iOffset - (here: twips/100)
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetOffSet($hWnd, $iOffset)
	Local $tparaformat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
	DllStructSetData($tparaformat, 2, $PFM_OFFSET)
	DllStructSetData($tparaformat, 7, $iOffset * 100)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
EndFunc   ;==>_GUICtrlRichEdit_SetOffSet

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetProtected
; Description:    Characters are protected;
;				  +an attempt to modify them will cause an EN_PROTECTED notification message.
; Parameters    : $hWnd         - Handle to the control
;                 $iStyle		- True = Set; False = Unset
;                 $iSelec       - Modify entire text or selection (default)
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetProtected($hWnd, $iStyle = True, $iSelec = True)
	If $iStyle Then $iStyle = $CFE_PROTECTED
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_PROTECTED)
	DllStructSetData($tcharformat, 3, $iStyle)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetProtected

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetRevised
; Description:    Characters are marked as revised.
; Parameters    : $hWnd         - Handle to the control
;                 $iStyle		- True = Set; False = Unset
;                 $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetRevised($hWnd, $iStyle = True, $iSelec = True)
	If $iStyle Then $iStyle = $CFE_REVISED
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_REVISED)
	DllStructSetData($tcharformat, 3, $iStyle)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetRevised

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetUnderline
; Description:    Toggle the Underline effect
; Parameters    : $hWnd         - Handle to the control
;                 $iStyle		- True = Set; False = Unset
;                 $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetUnderline($hWnd, $iStyle = True, $iSelec = True)
	If $iStyle Then $iStyle = $CFE_UNDERLINE
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_UNDERLINE)
	DllStructSetData($tcharformat, 3, $iStyle)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetUnderline

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetStrikeOut
; Description:    Toggle the Strike Out effect
; Parameters    : $hWnd         - Handle to the control
;                 $iStyle		- True = Set; False = Unset
;                 $iSelec       - Modify entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Rewritten     : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetStrikeOut($hWnd, $iStyle = True, $iSelec = True)
	If $iStyle Then $iStyle = $CFE_STRIKEOUT
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_STRIKEOUT)
	DllStructSetData($tcharformat, 3, $iStyle)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetStrikeOut

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetFontColor
; Description:    Select the text color
; Parameters    : $hWnd         - Handle to the control
;           	  $hColor       - Color value
;                 $iSelect      - Color entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Rewritten     : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetFontColor($hWnd, $hColor, $iSelec = True)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_COLOR)
	DllStructSetData($tcharformat, 6, $hColor)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetFontColor

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetBkColor
; Description:    Select the Background text color
; Parameters    : $hWnd         - Handle to the control
;           	  $hColor       - Color value
;                 $iSelec       - Color entire text or selection (default)
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Rewritten     : grham (works)
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetBkColor($hWnd, $hColor, $iSelec = True)
	Local $tcharformat = DllStructCreate($tagCHARFORMAT2)
	DllStructSetData($tcharformat, 1, DllStructGetSize($tcharformat))
	DllStructSetData($tcharformat, 2, $CFM_BACKCOLOR)
	DllStructSetData($tcharformat, 12, $hColor)
	Local $iSelec2 = $SCF_ALL
	If $iSelec Then $iSelec2 = $SCF_SELECTION
	Return _SendMessage($hWnd, $EM_SETCHARFORMAT, $iSelec2, DllStructGetPtr($tcharformat))
EndFunc   ;==>_GUICtrlRichEdit_SetBkColor

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetEventMaks
; Description:    The EM_SETEVENTMASK message sets the event mask for a rich edit control.
;           The event mask specifies which notification messages the control sends to its parent window
; Parameters    : $hWnd         - Handle to the control
;                 $hMin         - Character Number start
;                 $hMax         - Character Number stop
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetEventMask($hWnd, $hFunction)
	Return _SendMessage($hWnd, $EM_SETEVENTMASK, 0, $hFunction)
EndFunc   ;==>_GUICtrlRichEdit_SetEventMask

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetNumbering
; Description:    Sets paragraph numbering and numbering type
; Parameters    : $hWnd         - Handle to the control
;                 $iChar        - Characters used for numbering:
;								0 					No numbering
;                               1 or $PFN_BULLET    Inserts a bullet
;                               2                   Arabic numbres (1,2,3   .)
;                               3                   Lowercase tetters
;                               4                   Uppercase letters
;                               5                   Lowercase roman numerals (i,ii,iii...)
;                               6                   Uppercase roman numerals (I, II,   .)
;                               7                   Uses a sequence of characters beginning with
;													+the Unicode character specified by
;													+the wNumberingStart member
;                 $iFormat      - Numbering style used with numbered paragraphs
;                               0                   Follows the number with a right parenthesis.
;                               0x100               Encloses the number in parentheses.
;                               0x200               Follows the number with a period.
;                               0x300               Displays only the number.
;                               0x400               Continues a numbered list without
;													+applying the next number or bullet.
;                               0x8000              Starts a new number with wNumberingStart.
;                 $iStart       - Starting number or Unicode value used for numbered paragraphs.
;                 $iTab         - Minimum space between a paragraph number and the paragraph text, in twips.
;        If a parameter (except $hWnd) is set to the keyword Default, it won't be changed
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetNumbering($hWnd, $iChar = 0, $iFormat = 0x200, $iStart = 1, $iTab = 300)
	Local $tparaformat = DllStructCreate($tagPARAFORMAT2), $dwMask = 0
	DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
	If $iChar <> Default Then $dwMask = BitOR($dwMask, $PFM_NUMBERING)
	If $iStart <> Default Then $dwMask = BitOR($dwMask, $PFM_NUMBERINGSTART)
	If $iFormat <> Default Then $dwMask = BitOR($dwMask, $PFM_NUMBERINGSTYLE)
	If $iTab <> Default Then $dwMask = BitOR($dwMask, $PFM_NUMBERINGTAB)
	If $dwMask = 0 Then Return SetError(1, 0, 0)
	DllStructSetData($tparaformat, 2, $dwMask)
	DllStructSetData($tparaformat, 3, $iChar)
	DllStructSetData($tparaformat, 19, $iStart)
	DllStructSetData($tparaformat, 20, $iFormat)
	DllStructSetData($tparaformat, 21, $iTab)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
EndFunc   ;==>_GUICtrlRichEdit_SetNumbering


;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetReadOnly
; Description:    Set the control in ReadOnly Mode
; Parameters    : $hWnd         - Handle to the control
;                 $hBool        - True = Enabled, False = Disabled
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetReadOnly($hWnd, $hBool = True)
	Return _SendMessage($hWnd, $EM_SETREADONLY, $hBool, 0)
EndFunc   ;==>_GUICtrlRichEdit_SetReadOnly

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetSpaceAfter
; Description:    Size of the spacing below the paragraph, in twips.
; Parameters    : $hWnd         - Handle to the control
;                 $iNum         - The value must be greater than or equal to zero. (here: twips/100)
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetSpaceAfter($hWnd, $iNum)
	Local $tparaformat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
	DllStructSetData($tparaformat, 2, $PFM_SPACEAFTER)
	DllStructSetData($tparaformat, 12, $iNum * 100)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
EndFunc   ;==>_GUICtrlRichEdit_SetSpaceAfter

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetSpaceBefore
; Description:    Size of the spacing above the paragraph, in twips.
; Parameters    : $hWnd         - Handle to the control
;                 $iNum         - The value must be greater than or equal to zero. (here: twips/100)
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetSpaceBefore($hWnd, $iNum)
	Local $tparaformat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
	DllStructSetData($tparaformat, 2, $PFM_SPACEBEFORE)
	DllStructSetData($tparaformat, 11, $iNum * 100)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
EndFunc   ;==>_GUICtrlRichEdit_SetSpaceBefore

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetStartIndent
; Description:    Indentation of the paragraph's first line, in twips.
; Parameters    : $hWnd         - Handle to the control
;                 $iStartIndent - (here: twips/100)
; Return values : None
; Author        : grham
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetStartIndent($hWnd, $iStartIndent)
	Local $tparaformat = DllStructCreate($tagPARAFORMAT2)
	DllStructSetData($tparaformat, 1, DllStructGetSize($tparaformat))
	DllStructSetData($tparaformat, 2, $PFM_STARTINDENT)
	DllStructSetData($tparaformat, 5, $iStartIndent * 100)
	Return _SendMessage($hWnd, $EM_SETPARAFORMAT, 0, DllStructGetPtr($tparaformat))
EndFunc   ;==>_GUICtrlRichEdit_SetStartIndent

;====================================================================================================
; Function Name: _GUICtrlRichEdit_SetUndoLimit
; Description:    Set Undolimit
; Parameters    : $hWnd         - Handle to the control
;                 $Limit        - New Limit
; Return values : The new maximum limit
; Author        : Yoan Roblet (Arcker)
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_SetUndoLimit($hWnd, $Limit)
	Return _SendMessage($hWnd, $EM_SETUNDOLIMIT, $Limit)
EndFunc   ;==>_GUICtrlRichEdit_SetUndoLimit

;====================================================================================================
; Function Name: _GUICtrlRichEdit_Undo
; Description:    Undo
; Parameters    : $hWnd         - Handle to the control
; Return values : True on success, otherwise False
; Author        : Yoan Roblet (Arcker)
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_Undo($hWnd)
	Return _SendMessage($hWnd, $EM_UNDO, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_Undo

;====================================================================================================
; Function Name: _GUICtrlRichEdit_Redo
; Description:    Redo
; Parameters    : $hWnd         - Handle to the control
; Return values : True on success, otherwise False
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_Redo($hWnd)
	Return _SendMessage($hWnd, $EM_REDO, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_Redo

;====================================================================================================
; Function Name: _GUICtrlRichEdit_CanRedo
; Description:    Check, if REDO is possible
; Parameters    : $hWnd         - Handle to the control
; Return values : True on success, otherwise False
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_CanRedo($hWnd)
	Return _SendMessage($hWnd, $EM_CANREDO, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_CanRedo

;====================================================================================================
; Function Name: _GUICtrlRichEdit_CanUndo
; Description:    Check, if UNDO is possible
; Parameters    : $hWnd         - Handle to the control
; Return values : True on success, otherwise False
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_CanUndo($hWnd)
	Return _SendMessage($hWnd, $EM_CANUNDO, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_CanUndo

;====================================================================================================
; Function Name: _GUICtrlRichEdit_UndoID2Text
; Description:    Trabslates an UndoID to Text
; Parameters    : $UID         - UndoID
; Return values : UndoID
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_UndoID2Text($UID)
	Switch $UID
		Case $UID_CUT
			Return "Cut"
		Case $UID_DELETE
			Return "Delete"
		Case $UID_DRAGDROP
			Return "Dragdrop"
		Case $UID_PASTE
			Return "Paste"
		Case $UID_TYPING
			Return "Typing"
		Case $UID_UNKNOWN
			Return ""
	EndSwitch
EndFunc   ;==>_GUICtrlRichEdit_UndoID2Text

;====================================================================================================
; Function Name: _GUICtrlRichEdit_GetRedoName
; Description:    Get TypeId of next possible redo action
; Parameters    : $hWnd         - Handle to the control
; Return values : UndoID
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetRedoName($hWnd)
	Return _SendMessage($hWnd, $EM_GETREDONAME, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_GetRedoName

;====================================================================================================
; Function Name: _GUICtrlRichEdit_GetUndoName
; Description:    Get TypeId of next possible undo action
; Parameters    : $hWnd         - Handle to the control
; Return values : UndoID
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_GetUndoName($hWnd)
	Return _SendMessage($hWnd, $EM_GETUNDONAME, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_GetUndoName

;====================================================================================================
; Function Name: _GUICtrlRichEdit_Cut
; Description:    Cut Text
; Parameters    : $hWnd         - Handle to the control
; Return values : UndoID
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_Cut($hWnd)
	Return _SendMessage($hWnd, $WM_CUT, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_Cut

;====================================================================================================
; Function Name: _GUICtrlRichEdit_Copy
; Description:    Copy Text
; Parameters    : $hWnd         - Handle to the control
; Return values : UndoID
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_Copy($hWnd)
	Return _SendMessage($hWnd, $WM_COPY, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_Copy

;====================================================================================================
; Function Name: _GUICtrlRichEdit_Paste
; Description:    Paste Text
; Parameters    : $hWnd         - Handle to the control
; Return values : UndoID
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_Paste($hWnd)
	Return _SendMessage($hWnd, $WM_PASTE, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_Paste

;====================================================================================================
; Function Name: _GUICtrlRichEdit_CanPaste
; Description:    Check, if PASTE is possible
; Parameters    : $hWnd         - Handle to the control
; Return values : True on success, otherwise False
; Author        : Prog@ndy
; Notes         :
;====================================================================================================
;
Func _GUICtrlRichEdit_CanPaste($hWnd)
	Return _SendMessage($hWnd, $EM_CANPASTE, 0, 0)
EndFunc   ;==>_GUICtrlRichEdit_CanPaste

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_PauseRedraw
; Description::    Stops redrawing of the control
; Parameter(s):    $hWnd         - Handle to the control
; Requirement(s):
; Return Value(s): True on success, otherwise False
; Author(s):       KIP, or otherwere from the forum ?
;
;===============================================================================
;
Func _GUICtrlRichEdit_PauseRedraw($hWnd)
	Return _SendMessage($hWnd, $WM_SETREDRAW, False, 0)
EndFunc   ;==>_GUICtrlRichEdit_PauseRedraw

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_PauseRedraw
; Description::    Changes redrawing of the control
; Parameter(s):    $hWnd         - Handle to the control
;                  $Staet        - Should the control redraw be locked or unlocked
; Requirement(s):
; Return Value(s): True on success, otherwise False
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_SetRedraw($hWnd, $State)
	Return _SendMessage($hWnd, $WM_SETREDRAW, $State = True, 0)
EndFunc   ;==>_GUICtrlRichEdit_SetRedraw

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_PauseRedraw
; Description::    Resumes redrawing of the control
; Parameter(s):    $hWnd         - Handle to the control
; Requirement(s):
; Return Value(s): True on success, otherwise False
; Author(s):       KIP, or otherwere from the forum ?
;
;===============================================================================
;
Func _GUICtrlRichEdit_ResumeRedraw($hWnd)
	_SendMessage($hWnd, $WM_SETREDRAW, True, 0)
	Return __GCR_InvalidateRect($hWnd)
EndFunc   ;==>_GUICtrlRichEdit_ResumeRedraw


;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_PauseRedraw
; Description::    Set the distance between Tabstops
; Parameter(s):    $hWnd         - Handle to the control
;                  $aTabStops    - The distance
;                     1 integer: same distance for every tabstop
;                     1D-Array: Each Tabstop in a line with a different distance
; Requirement(s):
; Return Value(s): True on success, otherwise False
; Author(s):       KIP, or otherwere from the forum ?
;
;===============================================================================
;
Func _GUICtrlRichEdit_SetTabStops($hWnd, $aTabStops)

	Local $iNumTabStops, $tTabStops, $sTabStops, $iResult

	If IsArray($aTabStops) Then ; Set every tabstop manually

		$iNumTabStops = UBound($aTabStops)

		For $x = 0 To $iNumTabStops - 1
			$sTabStops &= "int;"
		Next
		$sTabStops = StringTrimRight($sTabStops, 1)
		$tTabStops = DllStructCreate($sTabStops)
		For $x = 0 To $iNumTabStops - 1
			DllStructSetData($tTabStops, $x + 1, $aTabStops[$x])
		Next

	Else ; Set 1 value for all tabstops
		$tTabStops = DllStructCreate("int")
		DllStructSetData($tTabStops, 1, $aTabStops)
		$iNumTabStops = 1
	EndIf

	$iResult = _SendMessage($hWnd, $EM_SETTABSTOPS, $iNumTabStops, DllStructGetPtr($tTabStops), 0, "wparam", "ptr") <> 0
	__GCR_InvalidateRect($hWnd)

	Return $iResult
EndFunc   ;==>_GUICtrlRichEdit_SetTabStops

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_StreamOut
; Description::    Gets the text from a RTF control ( also RTF )
; Parameter(s):    $h_RichEdit   - Handle to the control
;                  $Flags        - The format of the returned text
;                  $StreamStruct - Structure with information for Streaming
; Requirement(s):
; Return Value(s): True on success, otherwise False
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_StreamOut($h_RichEdit,$Flags,ByRef $StreamStruct)
	Local $lpStreamStruct = $StreamStruct
	If IsDllStruct($StreamStruct) Then $lpStreamStruct = DllStructGetPtr($StreamStruct)
	Local $send = _SendMessage($h_RichEdit, $EM_STREAMOUT, $Flags, $lpStreamStruct)
	Return $send
EndFunc

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_StreamIn
; Description::    Sets the text from a RTF control ( also RTF )
; Parameter(s):    $h_RichEdit   - Handle to the control
;                  $Flags        - The format of the text to set
;                  $StreamStruct - Structure with information for Streaming
; Requirement(s):
; Return Value(s): True on success, otherwise False
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_StreamIn($h_RichEdit,$Flags,ByRef $StreamStruct)
	Local $lpStreamStruct = $StreamStruct
	If IsDllStruct($StreamStruct) Then $lpStreamStruct = DllStructGetPtr($StreamStruct)
	Local $send = _SendMessage($h_RichEdit, $EM_STREAMIN, $Flags, $lpStreamStruct)
	Return $send
EndFunc

; Author(s): SmOke_N
;            -modified: Prog@ndy
Func __GCR_ColorConvert($nColor);RGB to BGR or BGR to RGB
	Return _
			BitOR(BitAND($nColor, 0xFF000000), _
			BitShift(BitAND($nColor, 0x000000FF), -16), _
			BitAND($nColor, 0x0000FF00), _
			BitShift(BitAND($nColor, 0x00FF0000), 16))
EndFunc   ;==>__GCR_ColorConvert

; Author(s):         Gary Frost (gafrost (custompcs@charter.net))
Func __GCR_IsBit($dwMask, $bit_check)
	If BitAND($dwMask, $bit_check) = $bit_check Then Return 1
	Return 0
EndFunc   ;==>__GCR_IsBit

; Author(s):         Gary Frost (gafrost (custompcs@charter.net))
Func __GCR_DebugPrint($s_Text)
	ConsoleWrite( _
			"!===========================================================" & @LF & _
			"+===========================================================" & @LF & _
			"-->" & $s_Text & @LF & _
			"+===========================================================" & @LF)
EndFunc   ;==>__GCR_DebugPrint

;===============================================
;    __GCR_GetLastErrorMessage($DisplayMsgBox="")
;    Format the last windows error as a string and return it
;    if $DisplayMsgBox <> "" Then it will display a message box w/ the error
;    Return        Window's error as a string
; Author(s):         Gary Frost (gafrost (custompcs@charter.net))
;===============================================
;
Func __GCR_GetLastErrorMessage($DisplayMsgBox = "")
	Local $ret, $s
	Local $p = DllStructCreate("wchar[4096]")
	Local Const $FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000

	If @error Then Return ""

	$ret = DllCall("Kernel32.dll", "int", "GetLastError")

	$ret = DllCall("kernel32.dll", "int", "FormatMessageW", _
			"int", $FORMAT_MESSAGE_FROM_SYSTEM, _
			"ptr", 0, _
			"int", $ret[0], _
			"int", 0, _
			"ptr", DllStructGetPtr($p), _
			"int", 4096, _
			"ptr", 0)
	$s = DllStructGetData($p, 1)
	If $DisplayMsgBox <> "" Then MsgBox(0, "__GCR_GetLastErrorMessage", $DisplayMsgBox & @CRLF & $s)
	Return $s
EndFunc   ;==>__GCR_GetLastErrorMessage


; Author ........: Paul Campbell (PaulIA)
Func __GCR_InvalidateRect($hWnd, $tRect = 0, $fErase = True)
	Local $pRect, $aResult

	If $tRect <> 0 Then $pRect = DllStructGetPtr($tRect)
	$aResult = DllCall("User32.dll", "int", "InvalidateRect", "hwnd", $hWnd, "ptr", $pRect, "int", $fErase)
	Return $aResult[0] <> 0
EndFunc   ;==>__GCR_InvalidateRect


#include <SendMessage.au3>
; Functions translated from http://www.powerbasic.com/support/pbforums/showpost.php?p=294112&postcount=7
; by Prog@ndy
#include-once
Global $pObj_RichComObject = DllStructCreate("ptr pIntf; dword  Refcount")

Global $pCall_RichCom, $pObj_RichCom
Global $hLib_RichCom_OLE32 = DllOpen("OLE32.DLL")
Global Const $_GCR_S_OK = 0
Global Const $_GCR_E_NOTIMPL = 0x80004001
Global Const $_GCR_E_INVALIDARG = 0x80070057

Global $__RichCom_Object_QueryInterface = DllCallbackRegister("__RichCom_Object_QueryInterface", "long", "ptr;dword;dword")
Global $__RichCom_Object_AddRef = DllCallbackRegister("__RichCom_Object_AddRef", "long", "ptr")
Global $__RichCom_Object_Release = DllCallbackRegister("__RichCom_Object_Release", "long", "ptr")
Global $__RichCom_Object_GetNewStorage = DllCallbackRegister("__RichCom_Object_GetNewStorage", "long", "ptr;ptr")
Global $__RichCom_Object_GetInPlaceContext = DllCallbackRegister("__RichCom_Object_GetInPlaceContext", "long", "ptr;dword;dword;dword")
Global $__RichCom_Object_ShowContainerUI = DllCallbackRegister("__RichCom_Object_ShowContainerUI", "long", "ptr;long")
Global $__RichCom_Object_QueryInsertObject = DllCallbackRegister("__RichCom_Object_QueryInsertObject", "long", "ptr;dword;ptr;long")
Global $__RichCom_Object_DeleteObject = DllCallbackRegister("__RichCom_Object_DeleteObject", "long", "ptr;ptr")
Global $__RichCom_Object_QueryAcceptData = DllCallbackRegister("__RichCom_Object_QueryAcceptData", "long", "ptr;ptr;dword;dword;dword;ptr")
Global $__RichCom_Object_ContextSensitiveHelp = DllCallbackRegister("__RichCom_Object_ContextSensitiveHelp", "long", "ptr;long")
Global $__RichCom_Object_GetClipboardData = DllCallbackRegister("__RichCom_Object_GetClipboardData", "long", "ptr;ptr;dword;ptr")
Global $__RichCom_Object_GetDragDropEffect = DllCallbackRegister("__RichCom_Object_GetDragDropEffect", "long", "ptr;dword;dword;dword")
Global $__RichCom_Object_GetContextMenu = DllCallbackRegister("__RichCom_Object_GetContextMenu", "long", "ptr;short;ptr;ptr;ptr")

;===============================================================================
;
; Function Name:   _GUICtrlRichEdit_SetOLECallback()
; Description:     Sets an OLE Callback-Function, so any OLE-Object can be added ( e.g images )
; Parameter(s):    $h_RichEdit : The RichEditControl
; Requirement(s):  MemoryDLL.au3
; Return Value(s): Success: greater than 0, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _GUICtrlRichEdit_SetOLECallback($hWnd)

	;'// Initialize the OLE part.
	If Not $pObj_RichCom Then

		$pCall_RichCom = DllStructCreate("ptr[20]");  '(With some extra space for the future)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryInterface), 1)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_AddRef), 2)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_Release), 3)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetNewStorage), 4)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetInPlaceContext), 5)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_ShowContainerUI), 6)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryInsertObject), 7)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_DeleteObject), 8)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_QueryAcceptData), 9)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_ContextSensitiveHelp), 10)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetClipboardData), 11)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetDragDropEffect), 12)
		DllStructSetData($pCall_RichCom, 1, DllCallbackGetPtr($__RichCom_Object_GetContextMenu), 13)

		DllStructSetData($pObj_RichComObject, 1, DllStructGetPtr($pCall_RichCom))
		DllStructSetData($pObj_RichComObject, 2, 1)
		$pObj_RichCom = DllStructGetPtr($pObj_RichComObject)


	EndIf
	Local $EM_SETOLECALLBACK = 0x400 + 70
	_SendMessage($hWnd, $EM_SETOLECALLBACK, 0, $pObj_RichCom)

EndFunc   ;==>_GUICtrlRichEdit_SetOLECallback

;~ '/////////////////////////////////////
;~ '// OLE stuff, don't use yourself..
;~ '/////////////////////////////////////

;~ '// Useless procedure, never called..

; INTERNAL USE ONLY
;~ Func __RichCom_Object_QueryInterface( $pObject As Dword, $REFIID As Dword, $ppvObj As Dword ) As Dword
Func __RichCom_Object_QueryInterface($pObject, $REFIID, $ppvObj)
	Return $_GCR_S_OK
EndFunc   ;==>__RichCom_Object_QueryInterface

; INTERNAL USE ONLY
;~ Func __RichCom_Object_AddRef( $pObject As Dword Ptr ) As Dword
Func __RichCom_Object_AddRef($pObject)
;~ Exit Function
	Local $data = DllStructCreate("ptr;dword", $pObject)
	DllStructSetData($data, 2, DllStructGetData($data, 2) + 1)
	Return DllStructGetData($data, 2)
EndFunc   ;==>__RichCom_Object_AddRef

; INTERNAL USE ONLY
;~ Func __RichCom_Object_Release( ByVal pObject As Dword Ptr ) As Dword
Func __RichCom_Object_Release($pObject)
;~ Exit Function
	Local $data = DllStructCreate("ptr;dword", $pObject)
	If DllStructGetData($data, 2) > 0 Then
		DllStructSetData($data, 2, DllStructGetData($data, 2) - 1)
		Return DllStructGetData($data, 2)
	EndIf
;~     If @pObject[1] > 0 Then
;~         Decr @pObject[1]
;~         Func = @pObject[1]
;~     Else
;~         pObject = 0
;~     End If

EndFunc   ;==>__RichCom_Object_Release

; INTERNAL USE ONLY
;~ Func __RichCom_Object_GetInPlaceContext( ByVal pObject As Dword Ptr, lplpFrame As Dword, lplpDoc As Dword, lpFrameInfo As Dword ) As Dword
Func __RichCom_Object_GetInPlaceContext($pObject, $lplpFrame, $lplpDoc, $lpFrameInfo)
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetInPlaceContext

; INTERNAL USE ONLY
;~ Func __RichCom_Object_ShowContainerUI( ByVal pObject As Dword Ptr, fShow As Long ) As Dword
Func __RichCom_Object_ShowContainerUI($pObject, $fShow)
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_ShowContainerUI

; INTERNAL USE ONLY
;~ Func __RichCom_Object_QueryInsertObject( ByVal pObject As Dword Ptr, lpclsid As Dword, ByVal lpstg As Dword Ptr, cp As Long ) As Dword
Func __RichCom_Object_QueryInsertObject($pObject, $lpclsid, $lpstg, $cp)
	Return $_GCR_S_OK
EndFunc   ;==>__RichCom_Object_QueryInsertObject

; INTERNAL USE ONLY
;~ Func __RichCom_Object_DeleteObject( ByVal pObject As Dword Ptr, lpoleobj As Dword ) As Dword
Func __RichCom_Object_DeleteObject($pObject, $lpoleobj)
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_DeleteObject

; INTERNAL USE ONLY
;~ Func __RichCom_Object_QueryAcceptData( ByVal pObject As Dword Ptr, lpdataobj As Dword, lpcfFormat As Dword, reco As Dword, fReally As Long, hMetaPict As Dword ) As Dword
Func __RichCom_Object_QueryAcceptData($pObject, $lpdataobj, $lpcfFormat, $reco, $fReally, $hMetaPict)
	Return $_GCR_S_OK
EndFunc   ;==>__RichCom_Object_QueryAcceptData

; INTERNAL USE ONLY
;~ Func __RichCom_Object_ContextSensitiveHelp( ByVal pObject As Dword Ptr, fEnterMode As Long ) As Dword
Func __RichCom_Object_ContextSensitiveHelp($pObject, $fEnterMode)
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_ContextSensitiveHelp

; INTERNAL USE ONLY
;~ Func __RichCom_Object_GetClipboardData( ByVal pObject As Dword Ptr, lpchrg As Dword, reco As Dword, lplpdataobj As Dword ) As Dword
Func __RichCom_Object_GetClipboardData($pObject, $lpchrg, $reco, $lplpdataobj)
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetClipboardData

; INTERNAL USE ONLY
;~ Func __RichCom_Object_GetDragDropEffect( ByVal pObject As Dword Ptr, fDrag As Long, grfKeyState As Dword, pdwEffect As Dword ) As Dword
Func __RichCom_Object_GetDragDropEffect($pObject, $fDrag, $grfKeyState, $pdwEffect)
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetDragDropEffect

; INTERNAL USE ONLY
;~ Func __RichCom_Object_GetContextMenu( ByVal pObject As Dword Ptr, seltype As Word, lpoleobj As Dword, lpchrg As Dword, lphmenu As Dword ) As Dword
Func __RichCom_Object_GetContextMenu($pObject, $seltype, $lpoleobj, $lpchrg, $lphmenu)
	Return $_GCR_E_NOTIMPL
EndFunc   ;==>__RichCom_Object_GetContextMenu

; INTERNAL USE ONLY
;~ Func __RichCom_Object_GetNewStorage( ByVal pObject As Dword Ptr, lplpstg As Dword ) As Dword
Func __RichCom_Object_GetNewStorage($pObject, $lplpstg)

	Local $sc ; As Dword
	Local $lpLockBytes; As Dword Ptr

;~     If pCall_RichCom_CreateILockBytesOnHGlobal = 0 Or pCall_RichCom_StgCreateDocfileOnILockBytes = 0 Then Exit Function
	Local $sc = DllCall($hLib_RichCom_OLE32, "dword", "CreateILockBytesOnHGlobal", "hwnd", 0, "int", 1, "ptr*", 0)
	$lpLockBytes = $sc[3]
	$sc = $sc[0]
;~     Call Dword pCall_RichCom_CreateILockBytesOnHGlobal Using _
;~         RichCom_CreateILockBytesOnHGlobal( ByVal 0&, ByVal 1&, lpLockBytes ) To sc

	If $sc Then
		Return $sc
	EndIf

	Local $sc = DllCall($hLib_RichCom_OLE32, "dword", "StgCreateDocfileOnILockBytes", "ptr", $lpLockBytes, "dword", BitOR(0x10, 2, 0x1000), "dword", 0, "ptr*", 0)
	Local $lpstg = DllStructCreate("ptr", $lplpstg)
	DllStructSetData($lpstg, 1, $sc[4])
	$sc = $sc[0]
;~     Call Dword pCall_RichCom_StgCreateDocfileOnILockBytes Using _
;~         RichCom_StgCreateDocfileOnILockBytes( _
;~           @lpLockBytes _
;~         , ByVal %STGM_SHARE_EXCLUSIVE Or %STGM_READWRITE Or %STGM_CREATE _
;~         , ByVal 0& _
;~         , lplpstg _
;~         ) To sc
	If $sc Then
		Local $obj = DllStructCreate("ptr",$lpLockBytes)
		Local $iUnknownFuncTable = DllStructCreate("ptr[3]",DllStructGetData($obj,1))
		Local $lpReleaseFunc = DllStructGetData($iUnknownFuncTable,3)
		Call(""&"MemoryFuncCall","long",$lpReleaseFunc,"ptr",$lpLockBytes)
		If @error = 1 Then ConsoleWrite("!> Needs MemoryDLL.au3 for correct release of ILockBytes" & @CRLF)
	EndIf
;~ '   If sc Then Call Dword @@lpLockBytes[2] Using __RichCom_Object_Release( @lpLockBytes )

	Return $sc

EndFunc   ;==>__RichCom_Object_GetNewStorage
