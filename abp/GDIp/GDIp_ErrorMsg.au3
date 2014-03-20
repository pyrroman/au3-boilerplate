#include-once
#include <GDIPlusConstants.au3>
 #include <WinAPIDiag.au3>

; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GDIPlus_ErrorMsg
; Description ...: Returns a string describing the error code.
; Syntax ........: __GDIPlus_ErrorMsg($iErrorCode)
; Parameters ....: $iErrorCode          - An integer value.
; Return values .: A string describing the error code.
; Author ........: rindeal
; Modified ......:
; Version .......: 2014-02-07
; ===============================================================================================================================
Func __GDIPlus_ErrorMsg($iErrorCode)
	Switch $iErrorCode
		Case $GDIP_ERROK
			Return "Method call was successful"
		Case $GDIP_ERRGENERICERROR
			Return "Generic method call error"
		Case $GDIP_ERRINVALIDPARAMETER
			Return "One of the arguments passed to the method was not valid"
		Case $GDIP_ERROUTOFMEMORY
			Return "The operating system is out of memory"
		Case $GDIP_ERROBJECTBUSY
			Return "One of the arguments in the call is already in use"
		Case $GDIP_ERRINSUFFICIENTBUFFER
			Return "A buffer is not large enough"
		Case $GDIP_ERRNOTIMPLEMENTED
			Return "The method is not implemented"
		Case $GDIP_ERRWIN32ERROR
			Return "The method generated a Microsoft Win32 error"
		Case $GDIP_ERRWRONGSTATE
			Return "The object is in an invalid state to satisfy the API call"
		Case $GDIP_ERRABORTED
			Return "The method was aborted"
		Case $GDIP_ERRFILENOTFOUND
			Return "The specified image file or metafile cannot be found"
		Case $GDIP_ERRVALUEOVERFLOW
			Return "The method produced a numeric overflow"
		Case $GDIP_ERRACCESSDENIED
			Return "A write operation is not allowed on the specified file"
		Case $GDIP_ERRUNKNOWNIMAGEFORMAT
			Return "The specified image file format is not known"
		Case $GDIP_ERRFONTFAMILYNOTFOUND
			Return "The specified font family cannot be found"
		Case $GDIP_ERRFONTSTYLENOTFOUND
			Return "The specified style is not available for the specified font"
		Case $GDIP_ERRNOTTRUETYPEFONT
			Return "The font retrieved is not a TrueType font"
		Case $GDIP_ERRUNSUPPORTEDGDIVERSION
			Return "The installed GDI+ version is incompatible"
		Case $GDIP_ERRGDIPLUSNOTINITIALIZED
			Return "The GDI+ API is not in an initialized state"
		Case $GDIP_ERRPROPERTYNOTFOUND
			Return "The specified property does not exist in the image"
		Case $GDIP_ERRPROPERTYNOTSUPPORTED
			Return "The specified property is not supported"
		Case Else
			Return "An unknown error code"
	EndSwitch
EndFunc   ;==>__GDIPlus_ErrorMsg