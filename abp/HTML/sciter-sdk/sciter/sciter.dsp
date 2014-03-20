# Microsoft Developer Studio Project File - Name="sciter" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=sciter - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "sciter.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "sciter.mak" CFG="sciter - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "sciter - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "sciter - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "sciter - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /c
# ADD CPP /nologo /MT /W3 /GX /O1 /I "../api/" /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_UNICODE" /D "STRICT" /Yu"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x1009 /d "NDEBUG"
# ADD RSC /l 0x1009 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386
# ADD LINK32 sciter-x.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /machine:I386 /out:"../sciter.exe" /libpath:"../api/"

!ELSEIF  "$(CFG)" == "sciter - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /Yu"stdafx.h" /FD /GZ /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /I "../api/" /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_UNICODE" /D "STRICT" /Yu"stdafx.h" /FD /GZ /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x1009 /d "_DEBUG"
# ADD RSC /l 0x1009 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /pdbtype:sept
# ADD LINK32 sciter-x.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /debug /machine:I386 /out:"../sciter.exe" /pdbtype:sept /libpath:"../api/"

!ENDIF 

# Begin Target

# Name "sciter - Win32 Release"
# Name "sciter - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=..\api\behaviors\behavior_tabs.cpp
# End Source File
# Begin Source File

SOURCE=.\native.cpp
# End Source File
# Begin Source File

SOURCE=.\sciter.cpp
# End Source File
# Begin Source File

SOURCE=.\sciter.rc
# End Source File
# Begin Source File

SOURCE=.\stdafx.cpp
# ADD CPP /Yc"stdafx.h"
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\aboutdlg.h
# End Source File
# Begin Source File

SOURCE="..\api\aux-cvt.h"
# End Source File
# Begin Source File

SOURCE="..\api\aux-slice.h"
# End Source File
# Begin Source File

SOURCE=.\mainfrm.h
# End Source File
# Begin Source File

SOURCE=.\resource.h
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-aux.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-behavior.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-dom.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-host-callback.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-lite.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-queue.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-script.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x-value.h"
# End Source File
# Begin Source File

SOURCE="..\api\sciter-x.h"
# End Source File
# Begin Source File

SOURCE=.\stdafx.h
# End Source File
# Begin Source File

SOURCE="..\api\tiscript-streams.hpp"
# End Source File
# Begin Source File

SOURCE=..\api\tiscript.h
# End Source File
# Begin Source File

SOURCE=..\..\tiscript\SDK\include\tiscript.hpp
# End Source File
# Begin Source File

SOURCE=..\api\value.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\res\sciter.exe.manifest
# End Source File
# Begin Source File

SOURCE=.\res\sciter.ico
# End Source File
# Begin Source File

SOURCE=.\res\toolbar.bmp
# End Source File
# End Group
# Begin Source File

SOURCE=.\res\default.htm
# End Source File
# Begin Source File

SOURCE=".\res\dom-inspector.htm"
# End Source File
# Begin Source File

SOURCE=.\res\inspector.css
# End Source File
# Begin Source File

SOURCE=.\res\inspector.tis
# End Source File
# Begin Source File

SOURCE=.\res\new.png
# End Source File
# Begin Source File

SOURCE=.\res\refresh.png
# End Source File
# Begin Source File

SOURCE=".\res\sys-info.htm"
# End Source File
# End Target
# End Project
