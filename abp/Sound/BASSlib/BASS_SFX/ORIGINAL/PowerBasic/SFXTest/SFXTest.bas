#COMPILE EXE
#DIM ALL
'------------------------------------------------
%USEMACROS = 1
#INCLUDE "WIN32API.INC"
#INCLUDE "bass_sfx.inc"

%VISUAL_TIMER           = 1
GLOBAL hMain       AS LONG
GLOBAL hStream     AS DWORD

GLOBAL hVisWnd1    AS LONG
GLOBAL hSFX        AS DWORD
GLOBAL hVisDC      AS DWORD

GLOBAL hVisWnd2    AS LONG
GLOBAL hSFX2        AS DWORD
GLOBAL hVisDC2      AS DWORD

GLOBAL hVisWnd3    AS LONG
GLOBAL hSFX3        AS DWORD
GLOBAL hVisDC3      AS DWORD

GLOBAL info AS BASS_SFX_PLUGININFO


DECLARE FUNCTION BASS_Init LIB "bass.dll" ALIAS "BASS_Init" (BYVAL device AS LONG, BYVAL freq AS DWORD, BYVAL flags AS DWORD, BYVAL win AS DWORD, BYVAL dsguid AS DWORD) AS LONG
DECLARE FUNCTION BASS_ChannelGetLevel LIB "bass.dll" ALIAS "BASS_ChannelGetLevel" (BYVAL nChannel AS DWORD) AS DWORD
DECLARE FUNCTION BASS_ChannelPlay LIB "bass.dll" ALIAS "BASS_ChannelPlay" (BYVAL nChannel AS DWORD, BYVAL restart AS LONG) AS LONG
DECLARE FUNCTION BASS_ChannelStop LIB "bass.dll" ALIAS "BASS_ChannelStop" (BYVAL nChannel AS DWORD) AS LONG
DECLARE FUNCTION BASS_ChannelPause LIB "bass.dll" ALIAS "BASS_ChannelPause" (BYVAL nChannel AS DWORD) AS LONG
DECLARE FUNCTION BASS_Free LIB "bass.dll" ALIAS "BASS_Free" () AS LONG
DECLARE FUNCTION BASS_StreamCreateFile LIB "bass.dll" ALIAS "BASS_StreamCreateFile" (BYVAL mem AS LONG, file AS ASCIIZ, BYVAL offset AS QUAD, BYVAL length AS QUAD, BYVAL flags AS DWORD) AS LONG
DECLARE FUNCTION BASS_MusicLoad LIB "bass.dll" ALIAS "BASS_MusicLoad" (BYVAL mem AS LONG, file AS ASCIIZ, BYVAL offset AS QUAD, BYVAL length AS DWORD, BYVAL flags AS DWORD, BYVAL freq AS DWORD) AS LONG
DECLARE FUNCTION BASS_StreamFree LIB "bass.dll" ALIAS "BASS_StreamFree" (BYVAL nChannel AS DWORD) AS LONG
DECLARE FUNCTION BASS_MusicFree LIB "bass.dll" ALIAS "BASS_MusicFree" (BYVAL nChannel AS DWORD) AS LONG
DECLARE FUNCTION BASS_ChannelSetSync LIB "bass.dll" ALIAS "BASS_ChannelSetSync" (BYVAL nChannel AS DWORD, BYVAL pbType AS LONG, BYVAL param AS QUAD, BYVAL proc AS LONG, BYVAL USER AS LONG) AS LONG
DECLARE FUNCTION BASS_SetVolume LIB "bass.dll" ALIAS "BASS_SetVolume" (BYVAL UseVolume AS SINGLE) AS LONG

DECLARE FUNCTION BASS_ChannelGetPosition LIB "bass.dll" ALIAS "BASS_ChannelGetPosition" (BYVAL nChannel AS DWORD, BYVAL nMode AS DWORD) AS DWORD
DECLARE FUNCTION BASS_ChannelSetPosition LIB "bass.dll" ALIAS "BASS_ChannelSetPosition" (BYVAL nChannel AS DWORD, BYVAL nPos AS QUAD) AS LONG
DECLARE FUNCTION BASS_ChannelGetLength LIB "bass.dll" ALIAS "BASS_ChannelGetLength" (BYVAL nChannel AS DWORD, BYVAL nMode AS DWORD) AS DWORD

DECLARE FUNCTION BASS_MusicGetOrders LIB "bass.dll" ALIAS "BASS_MusicGetOrders" (BYVAL nChannel AS DWORD) AS DWORD
DECLARE FUNCTION BASS_ErrorGetCode LIB "bass.dll" ALIAS "BASS_ErrorGetCode"() AS LONG
DECLARE FUNCTION BASS_ChannelGetData LIB "bass.dll" ALIAS "BASS_ChannelGetData" (BYVAL nChannel AS DWORD, BYVAL buffer AS DWORD, BYVAL nlength AS LONG) AS LONG
DECLARE FUNCTION BASS_StreamCreateURL LIB "bass.dll" ALIAS "BASS_StreamCreateURL" (zUrl AS ASCIIZ, BYVAL offset AS DWORD, BYVAL flags AS DWORD, BYVAL ptrDOWNLOADPROC AS DWORD, BYVAL USER AS DWORD) AS DWORD

DECLARE FUNCTION BASS_WMA_StreamCreateFile LIB "basswma.dll" ALIAS "BASS_WMA_StreamCreateFile" (BYVAL mem AS LONG, file AS ASCIIZ, BYVAL offset AS DWORD, BYVAL length AS DWORD, BYVAL flags AS DWORD) AS LONG
DECLARE FUNCTION BASS_WMA_StreamCreateFileAuth LIB "basswma.dll" ALIAS "BASS_WMA_StreamCreateFileAuth" (BYVAL mem AS LONG, file AS ASCIIZ, BYVAL offset AS DWORD, BYVAL length AS DWORD, BYVAL flags AS DWORD, zUser AS ASCIIZ, zPath AS ASCIIZ) AS LONG
DECLARE FUNCTION TAGS_Read LIB "BassTags.dll" ALIAS "TAGS_Read" (BYVAL nChannel AS DWORD, zFmt AS ASCIIZ) AS LONG

DECLARE FUNCTION BASS_CD_StreamCreateFile LIB "basscd.dll" ALIAS "BASS_CD_StreamCreateFile" (file AS ASCIIZ, BYVAL flags AS DWORD) AS LONG

DECLARE FUNCTION BASS_ChannelBytes2Seconds LIB "bass.dll" ALIAS "BASS_ChannelBytes2Seconds" (BYVAL nChannel AS DWORD, BYVAL nPos AS QUAD) AS DOUBLE
DECLARE FUNCTION BASS_ChannelSetAttribute LIB "bass.dll" ALIAS "BASS_ChannelSetAttribute" (BYVAL nChannel AS DWORD, BYVAL nAtteib AS DWORD, BYVAL nValue AS SINGLE) AS LONG
DECLARE FUNCTION BASS_ChannelIsActive LIB "bass.dll" ALIAS "BASS_ChannelIsActive" (BYVAL nChannel AS DWORD) AS DWORD

TYPE BASS_DEVICEINFO
   NAME   AS ASCIIZ PTR   ' const char *name   // description
   driver AS ASCIIZ PTR   ' const char *driver // driver
   flags  AS DWORD        ' DWORD flags
END TYPE

DECLARE FUNCTION BASS_GetDeviceInfo LIB "bass.dll" ALIAS "BASS_GetDeviceInfo" ( _
   BYVAL DWORD _                              ' DWORD device
 , BYREF BASS_DEVICEINFO _                    ' BASS_DEVICEINFO *info
 ) AS LONG


FUNCTION WndProc(BYVAL hWnd AS LONG, BYVAL Msg AS LONG, BYVAL wParam AS LONG, BYVAL lParam AS LONG) EXPORT AS LONG
    IF Msg = %WM_CLOSE  THEN
        DestroyWindow(hWnd)
    ELSEIF Msg = %WM_DESTROY THEN
        PostQuitMessage(0)
    ELSEIF Msg = %WM_TIMER THEN
         IF wParam = %VISUAL_TIMER THEN
          IF hSFX <> -1   THEN
            BASS_SFX_PluginRender(hSFX, hStream, hVisDC)
          END IF
           IF hSFX2 <> -1   THEN
            BASS_SFX_PluginRender(hSFX2, hStream, hVisDC2)
          END IF
           IF hSFX3 <> -1   THEN
            BASS_SFX_PluginRender(hSFX3, hStream, hVisDC3)
          END IF
         END IF
    END IF

FUNCTION = DefWindowProc(hWnd, Msg, wParam, lParam)
END FUNCTION


FUNCTION WINMAIN (BYVAL hInstance     AS LONG, _
                  BYVAL hPrevInstance AS LONG, _
                  BYVAL lpCmdLine     AS ASCIIZ PTR, _
                  BYVAL iCmdShow      AS LONG) AS LONG

    LOCAL Msg         AS tagMsg
    LOCAL wc          AS WndClassEx
    LOCAL zClass      AS ASCIIZ * 80
    LOCAL dwExStyle   AS DWORD
    LOCAL dwStyle     AS DWORD
    LOCAL rc          AS RECT
    LOCAL x           AS LONG
    LOCAL y           AS LONG
    LOCAL IsInitialized        AS LONG
    LOCAL hCtrl                AS LONG
    LOCAL bdinfo  AS BASS_DEVICEINFO


    zClass = "SFXTest"


       wc.cbSize        = SIZEOF(wc)
       wc.style         = %CS_HREDRAW OR %CS_VREDRAW OR %CS_DBLCLKS ' OR %CS_DROPSHADOW
       wc.lpfnWndProc   = CODEPTR(WndProc)
       wc.cbClsExtra    = 0
       wc.hInstance     = hInstance
       wc.hIcon         = LoadIcon(wc.hInstance, "PROGRAM")
       wc.hCursor       = LoadCursor(%NULL, BYVAL %IDC_ARROW)
       wc.hbrBackground = %NULL
       wc.lpszMenuName  = %NULL
       wc.lpszClassName = VARPTR(zClass)
       wc.hIconSm       = wc.hIcon
       RegisterClassEx(wc)



       dwExStyle = %WS_EX_CLIENTEDGE
       dwStyle = %WS_POPUP OR %WS_SYSMENU OR  %WS_CAPTION OR %WS_CLIPCHILDREN OR %WS_CLIPSIBLINGS

     ' Create The Window
       hMain = CreateWindowEx(dwExStyle, _            ' Extended Style For The Window
                              zClass, _               ' Class Name
                              ("SFXTest"), _           ' Window Title
                              dwStyle, _              ' Defined Window Style
                              50, 50, _                 ' Window Position
                              640, _ ' Calculate Window Width
                              320, _ ' Calculate Window Height
                              %NULL, _                ' No Parent Window
                              %NULL, _                ' No Menu
                              wc.hInstance, _         ' Instance
                              BYVAL %NULL)            ' Dont Pass Anything To WM_CREATE

'
       IF hMain THEN

       hVisWnd1 = CreateWindow("static", "visone", %WS_CHILD OR %WS_VISIBLE, 2, 2, 200, 200, hMain, 0, hInstance, 0)
       hVisWnd2 = CreateWindow("static", "vistwo", %WS_CHILD OR %WS_VISIBLE, 204, 2, 200, 200, hMain, 0, hInstance, 0)
       hVisWnd3 = CreateWindow("static", "visthree", %WS_CHILD OR %WS_VISIBLE, 408, 2, 200, 200, hMain, 0, hInstance, 0)

       hVisDC = GetDC(hVisWnd1)
       hVisDC2 = GetDC(hVisWnd2)
       hVisDC3 = GetDC(hVisWnd3)

       BASS_Init(-1, 44100, 0, hMain, 0)
       BASS_SFX_Init(hMain, hInstance)


       hSFX = BASS_SFX_PluginCreate("plugins\sphere.svp", hVisWnd1, 200, 200, 0)
       hSFX2 = BASS_SFX_PluginCreate("plugins\blaze.dll", hVisWnd2, 200, 200, 0)
       hSFX3 = BASS_SFX_PluginCreate("BBPlugin\oscillo.dll", hVisWnd3, 200, 200, 0)

       hStream= BASS_StreamCreateFile(0, "music\matrix.mp3", 0,0,0)

       BASS_ChannelPlay(hStream, 0)

       BASS_SFX_PluginStart(hSFX)
       BASS_SFX_PluginStart(hSFX2)
       BASS_SFX_PluginStart(hSFX3)

       CALL SetTimer(hMain, %VISUAL_TIMER, 27, %NULL)

        ShowWindow(hMain, %SW_SHOW)
        UpdateWindow(hMain)

          WHILE GetMessage(Msg, %NULL, 0, 0)
                IF IsDialogMessage(hMain, Msg) = %FALSE THEN
                   CALL TranslateMessage(Msg)
                   CALL DispatchMessage(Msg)
                END IF
          WEND
          KillTimer(hMain, %VISUAL_TIMER)
          SLEEP(27)
          ReleaseDC(hVisWnd1, hVisDC)
          ReleaseDC(hVisWnd2, hVisDC2)
          ReleaseDC(hVisWnd3, hVisDC3)
          BASS_ChannelStop(hStream)
          BASS_StreamFree(hStream)
          BASS_SFX_Free()
          BASS_Free
          FUNCTION = msg.wParam
       END IF

END FUNCTION
