;// ==========================================================
;// FreeImage 3
;//
;// conversion to AutoIt by
;// - Prog@ndy
;//
;// The FreeImage source code is located here:
;// - http://downloads.sourceforge.net/freeimage/FreeImage3150.zip
;//
;// For a helpfile visit
;// - http://downloads.sourceforge.net/freeimage/FreeImage3150.pdf
;// - The function names in this file are prefixed with an underscore
;//   This underscore does not occur in the helpfile.
;//
;// Design and implementation by
;// - Floris van den Berg (flvdberg@wxs.nl)
;// - Hervé Drolon (drolon@infonie.fr)
;//
;// Contributors:
;// - see the source files of FreeImage
;//
;// This file is part of FreeImage 3
;//
;// COVERED CODE IS PROVIDED UNDER THIS LICENSE ON AN "AS IS" BASIS, WITHOUT WARRANTY
;// OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, WITHOUT LIMITATION, WARRANTIES
;// THAT THE COVERED CODE IS FREE OF DEFECTS, MERCHANTABLE, FIT FOR A PARTICULAR PURPOSE
;// OR NON-INFRINGING. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE COVERED
;// CODE IS WITH YOU. SHOULD ANY COVERED CODE PROVE DEFECTIVE IN ANY RESPECT, YOU (NOT
;// THE INITIAL DEVELOPER OR ANY OTHER CONTRIBUTOR) ASSUME THE COST OF ANY NECESSARY
;// SERVICING, REPAIR OR CORRECTION. THIS DISCLAIMER OF WARRANTY CONSTITUTES AN ESSENTIAL
;// PART OF THIS LICENSE. NO USE OF ANY COVERED CODE IS AUTHORIZED HEREUNDER EXCEPT UNDER
;// THIS DISCLAIMER.
;//
;// Use at your own risk!
;// ==========================================================
#include-once
#include <StructureConstants.au3>
If @AutoItX64 Then Exit MsgBox(16, @ScriptName & " - Error", "AutoItv3 is running in 64-bit mode." & @CRLF & "This script uses the FreeImage-UDFs which will work only with a 32-bit AutoIt-Exe." & @CRLF & "Script is Terminating.")
;#ifndef FREEIMAGE_H
;#define FREEIMAGE_H

Func _FI_SIZEOF(Const $tagSTRUCT)
	;Author: Prog@ndy
	Return DllStructGetSize(DllStructCreate($tagSTRUCT, 1))
EndFunc   ;==>_FI_SIZEOF

;// Version information ------------------------------------------------------

Global Const $FREEIMAGE_MAJOR_VERSION = 3
Global Const $FREEIMAGE_MINOR_VERSION = 15
Global Const $FREEIMAGE_RELEASE_SERIAL = 0

;// Compiler options ---------------------------------------------------------

;#include <wchar.h>	// needed for UNICODE functions

;#if defined(FREEIMAGE_LIB)
;	#define DLL_API
;	#define DLL_CALLCONV
;#else
;	#if defined(_WIN32) || defined(__WIN32__)
;		#define DLL_CALLCONV __stdcall
;		// The following ifdef block is the standard way of creating macros which make exporting
;		// from a DLL simpler. All files within this DLL are compiled with the FREEIMAGE_EXPORTS
;		// symbol defined on the command line. this symbol should not be defined on any project
;		// that uses this DLL. This way any other project whose source files include this file see
;		// DLL_API functions as being imported from a DLL, wheras this DLL sees symbols
;		// defined with this macro as being exported.
;		#ifdef FREEIMAGE_EXPORTS
;			#define DLL_API __declspec(dllexport)
;		#else
;			#define DLL_API __declspec(dllimport)
;		#endif // FREEIMAGE_EXPORTS
;	#else
;		// try the gcc visibility support (see http://gcc.gnu.org/wiki/Visibility)
;		#if defined(__GNUC__) && ((__GNUC__ >= 4) || (__GNUC__ == 3 && __GNUC_MINOR__ >= 4))
;			#ifndef GCC_HASCLASSVISIBILITY
;				#define GCC_HASCLASSVISIBILITY
;			#endif
;		#endif // __GNUC__
;		#define DLL_CALLCONV
;		#if defined(GCC_HASCLASSVISIBILITY)
;			#define DLL_API __attribute__ ((visibility("default")))
;		#else
;			#define DLL_API
;		#endif
;	#endif // WIN32 / !WIN32
;#endif // FREEIMAGE_LIB

;// Some versions of gcc may have BYTE_ORDER or __BYTE_ORDER defined
;// If your big endian system isn't being detected, add an OS specific check
;#if (defined(BYTE_ORDER) && BYTE_ORDER==BIG_ENDIAN) || \
;	(defined(__BYTE_ORDER) && __BYTE_ORDER==__BIG_ENDIAN) || \
;	defined(__BIG_ENDIAN__)
;#define FREEIMAGE_BIGENDIAN
;#endif // BYTE_ORDER

;// This really only affects 24 and 32 bit formats, the rest are always RGB order.
Global Const $FREEIMAGE_COLORORDER_BGR = 0
Global Const $FREEIMAGE_COLORORDER_RGB = 1
;#if defined(__APPLE__) || defined(FREEIMAGE_BIGENDIAN)
;#define FREEIMAGE_COLORORDER FREEIMAGE_COLORORDER_RGB
;#else
;#define FREEIMAGE_COLORORDER FREEIMAGE_COLORORDER_BGR
;#endif
Global Const $FREEIMAGE_COLORORDER = $FREEIMAGE_COLORORDER_BGR

;// Ensure 4-byte enums if we're using Borland C++ compilers
;#if defined(__BORLANDC__)
;#pragma option push -b
;#endif

;// For C compatibility --------------------------------------------------------

;~ #ifdef __cplusplus
;~ #define FI_DEFAULT(x)	= x
;~ #define FI_ENUM(x)      enum x
;~ #define FI_STRUCT(x)	struct x
;~ #else
;~ #define FI_DEFAULT(x)
;~ #define FI_ENUM(x)      typedef int x; enum x
;~ #define FI_STRUCT(x)	typedef struct x x; struct x
;~ #endif

;// Bitmap types -------------------------------------------------------------

Global Const $lpFIBITMAP = "ptr"
Global Const $lpFIMULTIBITMAP = "ptr"
Global Const $tagFIBITMAP = "ptr data;"
Global Const $tagFIMULTIBITMAP = "ptr data;"

;// Types used in the library (directly copied from Windows) -----------------

;~ #ifndef _WINDOWS_
;~ #define _WINDOWS_
If Not IsDeclared("NULL") Then Global Const $NULL = 0

If Not IsDeclared("SEEK_SET") Then Global Const $SEEK_SET = 0
If Not IsDeclared("SEEK_CUR") Then Global Const $SEEK_CUR = 1
If Not IsDeclared("SEEK_END") Then Global Const $SEEK_END = 2

If Not IsDeclared("tagRGBQUAD") Then Global Const $tagRGBQUAD = "align 1;BYTE rgbBlue; BYTE rgbGreen; BYTE rgbRed; BYTE rgbReserved;"
;~ typedef struct tagRGBQUAD {
;~ #if FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
;~   BYTE rgbBlue;
;~   BYTE rgbGreen;
;~   BYTE rgbRed;
;~ #else
;~   BYTE rgbRed;
;~   BYTE rgbGreen;
;~   BYTE rgbBlue;
;~ #endif // FREEIMAGE_COLORORDER
;~   BYTE rgbReserved;
;~ } RGBQUAD;

If Not IsDeclared("tagRGBTRIPLE") Then Global Const $tagRGBTRIPLE = "align 1;BYTE rgbBlue; BYTE rgbGreen; BYTE rgbRed"
;~ typedef struct tagRGBTRIPLE {
;~ #if FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
;~   BYTE rgbtBlue;
;~   BYTE rgbtGreen;
;~   BYTE rgbtRed;
;~ #else
;~   BYTE rgbtRed;
;~   BYTE rgbtGreen;
;~   BYTE rgbtBlue;
;~ #endif // FREEIMAGE_COLORORDER
;~ } RGBTRIPLE;

;~ #if (defined(_WIN32) || defined(__WIN32__))
;~ #pragma pack(pop)
;~ #else
;~ #pragma pack()
;~ #endif // WIN32

If Not IsDeclared("tagBITMAPINFOHEADER") Then Global Const $tagBITMAPINFOHEADER = "align 1;" & _
		"DWORD biSize;" & _
		"LONG  biWidth; " & _
		"LONG  biHeight; " & _
		"USHORT  biPlanes; " & _
		"USHORT  biBitCount;" & _
		"DWORD biCompression; " & _
		"DWORD biSizeImage; " & _
		"LONG  biXPelsPerMeter; " & _
		"LONG  biYPelsPerMeter; " & _
		"DWORD biClrUsed; " & _
		"DWORD biClrImportant;"
;~ } BITMAPINFOHEADER, *PBITMAPINFOHEADER;

If Not IsDeclared("tagBITMAPINFOEx") Then Global Const $tagBITMAPINFOEx = "align 1;" & _
		"byte bmiHeader[" & _FI_SIZEOF($tagBITMAPINFOHEADER) & "]; " & _
		"DWORD          bmiColors[1];"
;~ } BITMAPINFO, *PBITMAPINFO;

;~ #endif // _WINDOWS_

;// Types used in the library (specific to FreeImage) ------------------------

;~ #if (defined(_WIN32) || defined(__WIN32__))
;~ #pragma pack(push, 1)
;~ #else
;~ #pragma pack(1)
;~ #endif // WIN32

;~ /** 48-bit RGB
;~ */
Global Const $tagFIRGB16 = "align 1;" & _
		"USHORT red;" & _
		"USHORT green;" & _
		"USHORT blue;"
;~ } FIRGB16;

;~ /** 64-bit RGBA
;~ */
Global Const $tagFIRGBA16 = "align 1;" & _
		"USHORT red;" & _
		"USHORT green;" & _
		"USHORT blue;" & _
		"USHORT alpha;"
;~ } FIRGBA16;

;~ /** 96-bit RGB Float
;~ */
Global Const $tagFIRGBF = "align 1;" & _
		"float red;" & _
		"float green;" & _
		"float blue;"
;~ } FIRGBF;

;~ /** 128-bit RGBA Float
;~ */
Global Const $tagFIRGBAF = "align 1;" & _
		"float red;" & _
		"float green;" & _
		"float blue;" & _
		"float alpha;"
;~ } FIRGBAF;

;~ /** Data structure for COMPLEX type (complex number)
;~ */
Global Const $tagFICOMPLEX = "align 1;" & _
		"double r;" & _ ;/// real part
		"double i;" ;/// imaginary part
;~ } FICOMPLEX;

;~ #if (defined(_WIN32) || defined(__WIN32__))
;~ #pragma pack(pop)
;~ #else
;~ #pragma pack()
;~ #endif // WIN32

;// Indexes for byte arrays, masks and shifts for treating pixels as words ---
;// These coincide with the order of RGBQUAD and RGBTRIPLE -------------------

;~ #ifndef FREEIMAGE_BIGENDIAN
;~ #if FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
;// Little Endian (x86 / MS Windows, Linux) : BGR(A) order
Global Const $FI_RGBA_RED = 2
Global Const $FI_RGBA_GREEN = 1
Global Const $FI_RGBA_BLUE = 0
Global Const $FI_RGBA_ALPHA = 3
Global Const $FI_RGBA_RED_MASK = 0x00FF0000
Global Const $FI_RGBA_GREEN_MASK = 0x0000FF00
Global Const $FI_RGBA_BLUE_MASK = 0x000000FF
Global Const $FI_RGBA_ALPHA_MASK = 0xFF000000
Global Const $FI_RGBA_RED_SHIFT = 16
Global Const $FI_RGBA_GREEN_SHIFT = 8
Global Const $FI_RGBA_BLUE_SHIFT = 0
Global Const $FI_RGBA_ALPHA_SHIFT = 24
;~ #else
;~ ;// Little Endian (x86 / MaxOSX) : RGB(A) order
;~ #define FI_RGBA_RED				0
;~ #define FI_RGBA_GREEN			1
;~ #define FI_RGBA_BLUE			2
;~ #define FI_RGBA_ALPHA			3
;~ #define FI_RGBA_RED_MASK		0x000000FF
;~ #define FI_RGBA_GREEN_MASK		0x0000FF00
;~ #define FI_RGBA_BLUE_MASK		0x00FF0000
;~ #define FI_RGBA_ALPHA_MASK		0xFF000000
;~ #define FI_RGBA_RED_SHIFT		0
;~ #define FI_RGBA_GREEN_SHIFT		8
;~ #define FI_RGBA_BLUE_SHIFT		16
;~ #define FI_RGBA_ALPHA_SHIFT		24
;~ #endif // FREEIMAGE_COLORORDER
;~ #else
;~ #if FREEIMAGE_COLORORDER == FREEIMAGE_COLORORDER_BGR
;~ ;// Big Endian (PPC / none) : BGR(A) order
;~ #define FI_RGBA_RED				2
;~ #define FI_RGBA_GREEN			1
;~ #define FI_RGBA_BLUE			0
;~ #define FI_RGBA_ALPHA			3
;~ #define FI_RGBA_RED_MASK		0x0000FF00
;~ #define FI_RGBA_GREEN_MASK		0x00FF0000
;~ #define FI_RGBA_BLUE_MASK		0xFF000000
;~ #define FI_RGBA_ALPHA_MASK		0x000000FF
;~ #define FI_RGBA_RED_SHIFT		8
;~ #define FI_RGBA_GREEN_SHIFT		16
;~ #define FI_RGBA_BLUE_SHIFT		24
;~ #define FI_RGBA_ALPHA_SHIFT		0
;~ #else
;~ ;// Big Endian (PPC / Linux, MaxOSX) : RGB(A) order
;~ #define FI_RGBA_RED				0
;~ #define FI_RGBA_GREEN			1
;~ #define FI_RGBA_BLUE			2
;~ #define FI_RGBA_ALPHA			3
;~ #define FI_RGBA_RED_MASK		0xFF000000
;~ #define FI_RGBA_GREEN_MASK		0x00FF0000
;~ #define FI_RGBA_BLUE_MASK		0x0000FF00
;~ #define FI_RGBA_ALPHA_MASK		0x000000FF
;~ #define FI_RGBA_RED_SHIFT		24
;~ #define FI_RGBA_GREEN_SHIFT		16
;~ #define FI_RGBA_BLUE_SHIFT		8
;~ #define FI_RGBA_ALPHA_SHIFT		0
;~ #endif // FREEIMAGE_COLORORDER
;~ #endif // FREEIMAGE_BIGENDIAN

Global Const $FI_RGBA_RGB_MASK = BitOR($FI_RGBA_RED_MASK, $FI_RGBA_GREEN_MASK, $FI_RGBA_BLUE_MASK)

;// The 16bit macros only include masks and shifts, since each color element is not byte aligned

Global Const $FI16_555_RED_MASK = 0x7C00
Global Const $FI16_555_GREEN_MASK = 0x03E0
Global Const $FI16_555_BLUE_MASK = 0x001F
Global Const $FI16_555_RED_SHIFT = 10
Global Const $FI16_555_GREEN_SHIFT = 5
Global Const $FI16_555_BLUE_SHIFT = 0
Global Const $FI16_565_RED_MASK = 0xF800
Global Const $FI16_565_GREEN_MASK = 0x07E0
Global Const $FI16_565_BLUE_MASK = 0x001F
Global Const $FI16_565_RED_SHIFT = 11
Global Const $FI16_565_GREEN_SHIFT = 5
Global Const $FI16_565_BLUE_SHIFT = 0

;// ICC profile support ------------------------------------------------------

Global Const $FIICC_DEFAULT = 0x00
Global Const $FIICC_COLOR_IS_CMYK = 0x01

Global Const $tagFIICCPROFILE = _
		"USHORT flags;" & _ ;	// info flag
		"DWORD  size;" & _ ;	// profile's size measured in bytes
		"ptr    data;" ;	// points to a block of contiguous memory containing the profile
;~ };

;// Important enums ----------------------------------------------------------

;~ /** I/O image format identifiers.
;~ */
;~ FI_ENUM(FREE_IMAGE_FORMAT) {
Global Const $FREE_IMAGE_FORMAT = "long"
Global Enum _
		$FIF_UNKNOWN = -1, _
		$FIF_BMP = 0, _
		$FIF_ICO = 1, _
		$FIF_JPEG = 2, _
		$FIF_JNG = 3, _
		$FIF_KOALA = 4, _
		$FIF_LBM = 5, _
		$FIF_IFF = $FIF_LBM, _
		$FIF_MNG = 6, _
		$FIF_PBM = 7, _
		$FIF_PBMRAW = 8, _
		$FIF_PCD = 9, _
		$FIF_PCX = 10, _
		$FIF_PGM = 11, _
		$FIF_PGMRAW = 12, _
		$FIF_PNG = 13, _
		$FIF_PPM = 14, _
		$FIF_PPMRAW = 15, _
		$FIF_RAS = 16, _
		$FIF_TARGA = 17, _
		$FIF_TIFF = 18, _
		$FIF_WBMP = 19, _
		$FIF_PSD = 20, _
		$FIF_CUT = 21, _
		$FIF_XBM = 22, _
		$FIF_XPM = 23, _
		$FIF_DDS = 24, _
		$FIF_GIF = 25, _
		$FIF_HDR = 26, _
		$FIF_FAXG3 = 27, _
		$FIF_SGI = 28, _
		$FIF_EXR = 29, _
		$FIF_J2K = 30, _
		$FIF_JP2 = 31, _
		$FIF_PFM = 32
;~ };

;~ /** Image type used in FreeImage.
;~ */
;~ FI_ENUM(FREE_IMAGE_TYPE) {
Global Const $FREE_IMAGE_TYPE = "dword"
Global Enum _
		$FIT_UNKNOWN = 0, _	;// unknown type
		$FIT_BITMAP = 1, _	;// standard image			: 1-, 4-, 8-, 16-, 24-, 32-bit
		$FIT_UINT16 = 2, _	;// array of unsigned short	: unsigned 16-bit
		$FIT_INT16 = 3, _	;// array of short			: signed 16-bit
		$FIT_UINT32 = 4, _	;// array of unsigned long	: unsigned 32-bit
		$FIT_INT32 = 5, _	;// array of long			: signed 32-bit
		$FIT_FLOAT = 6, _	;// array of float			: 32-bit IEEE floating point
		$FIT_DOUBLE = 7, _	;// array of double			: 64-bit IEEE floating point
		$FIT_COMPLEX = 8, _;// array of FICOMPLEX		: 2 x 64-bit IEEE floating point
		$FIT_RGB16 = 9, _	;// 48-bit RGB image		: 3 x 16-bit
		$FIT_RGBA16 = 10, _	;// 64-bit RGBA image		: 4 x 16-bit
		$FIT_RGBF = 11, _	;// 96-bit RGB float image	: 3 x 32-bit IEEE floating point
		$FIT_RGBAF = 12 ;// 128-bit RGBA float image: 4 x 32-bit IEEE floating point
;~ };

;~ /** Image color type used in FreeImage.
;~ */
;~ FI_ENUM(FREE_IMAGE_COLOR_TYPE) {
Global Const $FREE_IMAGE_COLOR_TYPE = "dword"
Global Enum _
		$FIC_MINISWHITE = 0, _		;// min value is white
		$FIC_MINISBLACK = 1, _		;// min value is black
		$FIC_RGB = 2, _		;// RGB color model
		$FIC_PALETTE = 3, _		;// color map indexed
		$FIC_RGBALPHA = 4, _		;// RGB color model with alpha channel
		$FIC_CMYK = 5 ;// CMYK color model
;~ };

;~ /** Color quantization algorithms.
;~ Constants used in FreeImage_ColorQuantize.
;~ */
;~ FI_ENUM(FREE_IMAGE_QUANTIZE) {
Global Const $FREE_IMAGE_QUANTIZE = "dword"
Global Enum _
		$FIQ_WUQUANT = 0, _		;// Xiaolin Wu color quantization algorithm
		$FIQ_NNQUANT = 1 ;// NeuQuant neural-net quantization algorithm by Anthony Dekker
;~ };

;~ /** Dithering algorithms.
;~ Constants used in FreeImage_Dither.
;~ */
;~ FI_ENUM(FREE_IMAGE_DITHER) {
Global Const $FREE_IMAGE_DITHER = "dword"
Global Enum _
		$FID_FS = 0, _	;// Floyd & Steinberg error diffusion
		$FID_BAYER4x4 = 1, _	;// Bayer ordered dispersed dot dithering (order 2 dithering matrix)
		$FID_BAYER8x8 = 2, _	;// Bayer ordered dispersed dot dithering (order 3 dithering matrix)
		$FID_CLUSTER6x6 = 3, _	;// Ordered clustered dot dithering (order 3 - 6x6 matrix)
		$FID_CLUSTER8x8 = 4, _	;// Ordered clustered dot dithering (order 4 - 8x8 matrix)
		$FID_CLUSTER16x16 = 5, _	;// Ordered clustered dot dithering (order 8 - 16x16 matrix)
		$FID_BAYER16x16 = 6 ;// Bayer ordered dispersed dot dithering (order 4 dithering matrix)
;~ };

;~ /** Lossless JPEG transformations
;~ Constants used in FreeImage_JPEGTransform
;~ */
;~ FI_ENUM(FREE_IMAGE_JPEG_OPERATION) {
Global Const $FREE_IMAGE_JPEG_OPERATION = "dword"
Global Enum _
		$FIJPEG_OP_NONE = 0, _	;// no transformation
		$FIJPEG_OP_FLIP_H = 1, _	;// horizontal flip
		$FIJPEG_OP_FLIP_V = 2, _	;// vertical flip
		$FIJPEG_OP_TRANSPOSE = 3, _	;// transpose across UL-to-LR axis
		$FIJPEG_OP_TRANSVERSE = 4, _	;// transpose across UR-to-LL axis
		$FIJPEG_OP_ROTATE_90 = 5, _	;// 90-degree clockwise rotation
		$FIJPEG_OP_ROTATE_180 = 6, _	;// 180-degree rotation
		$FIJPEG_OP_ROTATE_270 = 7 ;// 270-degree clockwise (or 90 ccw)
;~ };

;~ /** Tone mapping operators.
;~ Constants used in FreeImage_ToneMapping.
;~ */
;~ FI_ENUM(FREE_IMAGE_TMO) {
Global Const $FREE_IMAGE_TMO = "dword"
Global Enum _
		$FITMO_DRAGO03 = 0, _	;// Adaptive logarithmic mapping (F. Drago, 2003)
		$FITMO_REINHARD05 = 1, _	;// Dynamic range reduction inspired by photoreceptor physiology (E. Reinhard, 2005)
		$FITMO_FATTAL02 = 2 ;// Gradient domain high dynamic range compression (R. Fattal, 2002)
;~ };

;~ /** Upsampling / downsampling filters.
;~ Constants used in FreeImage_Rescale.
;~ */
;~ FI_ENUM(FREE_IMAGE_FILTER) {
Global Const $FREE_IMAGE_FILTER = "dword"
Global Enum _
		$FILTER_BOX = 0, _	;// Box, pulse, Fourier window, 1st order (constant) b-spline
		$FILTER_BICUBIC = 1, _	;// Mitchell & Netravali's two-param cubic filter
		$FILTER_BILINEAR = 2, _	;// Bilinear filter
		$FILTER_BSPLINE = 3, _	;// 4th order (cubic) b-spline
		$FILTER_CATMULLROM = 4, _	;// Catmull-Rom spline, Overhauser spline
		$FILTER_LANCZOS3 = 5 ;// Lanczos3 filter
;~ };

;~ /** Color channels.
;~ Constants used in color manipulation routines.
;~ */
;~ FI_ENUM(FREE_IMAGE_COLOR_CHANNEL) {
Global Const $FREE_IMAGE_COLOR_CHANNEL = "dword"
Global Enum _
		$FICC_RGB = 0, _	;// Use red, green and blue channels
		$FICC_RED = 1, _	;// Use red channel
		$FICC_GREEN = 2, _	;// Use green channel
		$FICC_BLUE = 3, _	;// Use blue channel
		$FICC_ALPHA = 4, _	;// Use alpha channel
		$FICC_BLACK = 5, _	;// Use black channel
		$FICC_REAL = 6, _	;// Complex images: use real part
		$FICC_IMAG = 7, _	;// Complex images: use imaginary part
		$FICC_MAG = 8, _	;// Complex images: use magnitude
		$FICC_PHASE = 9 ;// Complex images: use phase
;~ };

;// Metadata support ---------------------------------------------------------

;~ /**
;~   Tag data type information (based on TIFF specifications)

;~   Note: RATIONALs are the ratio of two 32-bit integer values.
;~ */
;~ FI_ENUM(FREE_IMAGE_MDTYPE) {
Global Const $FREE_IMAGE_MDTYPE = "dword"
Global Enum _
		$FIDT_NOTYPE = 0, _	;// placeholder
		$FIDT_BYTE = 1, _	;// 8-bit unsigned integer
		$FIDT_ASCII = 2, _	;// 8-bit bytes w/ last byte null
		$FIDT_SHORT = 3, _	;// 16-bit unsigned integer
		$FIDT_LONG = 4, _	;// 32-bit unsigned integer
		$FIDT_RATIONAL = 5, _	;// 64-bit unsigned fraction
		$FIDT_SBYTE = 6, _	;// 8-bit signed integer
		$FIDT_UNDEFINED = 7, _	;// 8-bit untyped data
		$FIDT_SSHORT = 8, _	;// 16-bit signed integer
		$FIDT_SLONG = 9, _	;// 32-bit signed integer
		$FIDT_SRATIONAL = 10, _	;// 64-bit signed fraction
		$FIDT_FLOAT = 11, _	;// 32-bit IEEE floating point
		$FIDT_DOUBLE = 12, _	;// 64-bit IEEE floating point
		$FIDT_IFD = 13, _	;// 32-bit unsigned integer (offset)
		$FIDT_PALETTE = 14 ;// 32-bit RGBQUAD
;~ };

;~ /**
;~   Metadata models supported by FreeImage
;~ */
;~ FI_ENUM(FREE_IMAGE_MDMODEL) {
Global Const $FREE_IMAGE_MDMODEL = "dword"
Global Enum _
		$FIMD_NODATA = -1, _
		$FIMD_COMMENTS = 0, _	;// single comment or keywords
		$FIMD_EXIF_MAIN = 1, _	;// Exif-TIFF metadata
		$FIMD_EXIF_EXIF = 2, _	;// Exif-specific metadata
		$FIMD_EXIF_GPS = 3, _	;// Exif GPS metadata
		$FIMD_EXIF_MAKERNOTE = 4, _	;// Exif maker note metadata
		$FIMD_EXIF_INTEROP = 5, _	;// Exif interoperability metadata
		$FIMD_IPTC = 6, _	;// IPTC/NAA metadata
		$FIMD_XMP = 7, _	;// Abobe XMP metadata
		$FIMD_GEOTIFF = 8, _	;// GeoTIFF metadata
		$FIMD_ANIMATION = 9, _	;// Animation metadata
		$FIMD_CUSTOM = 10, _ ;// Used to attach other metadata types to a dib
		$FIMD_EXIF_RAW = 11 ;// Exif metadata as a raw buffer
;~ };

;~ /**
;~   Handle to a metadata model
;~ */
Global Const $tagFIMETADATA = "ptr data;"

;~ /**
;~   Handle to a FreeImage tag
;~ */
Global Const $tagFITAG = "ptr data;"

;// File IO routines ---------------------------------------------------------
Global Const $fi_handle = "ptr";
#cs
	#ifndef FREEIMAGE_IO
	#define FREEIMAGE_IO

	typedef unsigned (DLL_CALLCONV *FI_ReadProc) (void *buffer, unsigned size, unsigned count, fi_handle handle);
	typedef unsigned (DLL_CALLCONV *FI_WriteProc) (void *buffer, unsigned size, unsigned count, fi_handle handle);
	typedef int (DLL_CALLCONV *FI_SeekProc) (fi_handle handle, long offset, int origin);
	typedef long (DLL_CALLCONV *FI_TellProc) (fi_handle handle);

	#if (defined(_WIN32) || defined(__WIN32__))
	#pragma pack(push, 1)
	#else
	#pragma pack(1)
	#endif // WIN32
#ce
;~ 	FI_STRUCT(FreeImageIO) {
;~ 	FI_ReadProc  read_proc;     // pointer to the function used to read data
;~ 	FI_WriteProc write_proc;    // pointer to the function used to write data
;~ 	FI_SeekProc  seek_proc;     // pointer to the function used to seek
;~ 	FI_TellProc  tell_proc;     // pointer to the function used to aquire the current position
;~ 	};
Global Const $tagFreeimageIO = "ptr readProc; ptr writeProc; ptr seekProc; ptr tellProc;"
#cs
	#if (defined(_WIN32) || defined(__WIN32__))
	#pragma pack(pop)
	#else
	#pragma pack()
	#endif // WIN32

	/**
	Handle to a memory I/O stream
	*/
	FI_STRUCT (FIMEMORY) { void *data; };

	#endif // FREEIMAGE_IO
#ce

;// Plugin routines ----------------------------------------------------------
#cs
	#ifndef PLUGINS
	#define PLUGINS

	typedef const char *(DLL_CALLCONV *FI_FormatProc) ();
	typedef const char *(DLL_CALLCONV *FI_DescriptionProc) ();
	typedef const char *(DLL_CALLCONV *FI_ExtensionListProc) ();
	typedef const char *(DLL_CALLCONV *FI_RegExprProc) ();
	typedef void *(DLL_CALLCONV *FI_OpenProc)(FreeImageIO *io, fi_handle handle, BOOL read);
	typedef void (DLL_CALLCONV *FI_CloseProc)(FreeImageIO *io, fi_handle handle, void *data);
	typedef int (DLL_CALLCONV *FI_PageCountProc)(FreeImageIO *io, fi_handle handle, void *data);
	typedef int (DLL_CALLCONV *FI_PageCapabilityProc)(FreeImageIO *io, fi_handle handle, void *data);
	typedef FIBITMAP *(DLL_CALLCONV *FI_LoadProc)(FreeImageIO *io, fi_handle handle, int page, int flags, void *data);
	typedef BOOL (DLL_CALLCONV *FI_SaveProc)(FreeImageIO *io, FIBITMAP *dib, fi_handle handle, int page, int flags, void *data);
	typedef BOOL (DLL_CALLCONV *FI_ValidateProc)(FreeImageIO *io, fi_handle handle);
	typedef const char *(DLL_CALLCONV *FI_MimeProc) ();
	typedef BOOL (DLL_CALLCONV *FI_SupportsExportBPPProc)(int bpp);
	typedef BOOL (DLL_CALLCONV *FI_SupportsExportTypeProc)(FREE_IMAGE_TYPE type);
	typedef BOOL (DLL_CALLCONV *FI_SupportsICCProfilesProc)();
	typedef BOOL (DLL_CALLCONV *FI_SupportsNoPixelsProc)(void);

	FI_STRUCT (Plugin) {
	FI_FormatProc format_proc;
	FI_DescriptionProc description_proc;
	FI_ExtensionListProc extension_proc;
	FI_RegExprProc regexpr_proc;
	FI_OpenProc open_proc;
	FI_CloseProc close_proc;
	FI_PageCountProc pagecount_proc;
	FI_PageCapabilityProc pagecapability_proc;
	FI_LoadProc load_proc;
	FI_SaveProc save_proc;
	FI_ValidateProc validate_proc;
	FI_MimeProc mime_proc;
	FI_SupportsExportBPPProc supports_export_bpp_proc;
	FI_SupportsExportTypeProc supports_export_type_proc;
	FI_SupportsICCProfilesProc supports_icc_profiles_proc;
	FI_SupportsNoPixelsProc supports_no_pixels_proc;
	};

	typedef void (DLL_CALLCONV *FI_InitProc)(Plugin *plugin, int format_id);

	#endif // PLUGINS
#ce
Global Const $tagPlugin = "ptr  formatProc; ptr descriptionProc; ptr extensionProc; " & _
		"ptr regexprProc; ptr openProc; ptr closeProc; ptr pagecountProc; ptr pagecapabilityProc; " & _
		"ptr  loadProc; ptr saveProc; ptr validateProc; ptr mimeProc; ptr supportsExportBppProc; " & _
		"ptr supportsExportTypeProc; ptr supportsIccProfilesProc;"

;// Load / Save flag constants -----------------------------------------------

Global Const $FIF_LOAD_NOPIXELS = 0x8000 ;// loading: load the image header only (not supported by all plugins)

Global Const $BMP_DEFAULT = 0
Global Const $BMP_SAVE_RLE = 1
Global Const $CUT_DEFAULT = 0
Global Const $DDS_DEFAULT = 0
Global Const $EXR_DEFAULT = 0 ;// save data as half with piz-based wavelet compression
Global Const $EXR_FLOAT = 0x0001 ;// save data as float instead of as half (not recommended)
Global Const $EXR_NONE = 0x0002 ;// save with no compression
Global Const $EXR_ZIP = 0x0004 ;// save with zlib compression, in blocks of 16 scan lines
Global Const $EXR_PIZ = 0x0008 ;// save with piz-based wavelet compression
Global Const $EXR_PXR24 = 0x0010 ;// save with lossy 24-bit float compression
Global Const $EXR_B44 = 0x0020 ;// save with lossy 44% float compression - goes to 22% when combined with EXR_LC
Global Const $EXR_LC = 0x0040 ;// save images with one luminance and two chroma channels, rather than as RGB (lossy compression)
Global Const $FAXG3_DEFAULT = 0
Global Const $GIF_DEFAULT = 0
Global Const $GIF_LOAD256 = 1 ;// Load the image as a 256 color image with ununsed palette entries, if it's 16 or 2 color
Global Const $GIF_PLAYBACK = 2 ;// 'Play' the GIF to generate each frame (as 32bpp) instead of returning raw frame data when loading
Global Const $HDR_DEFAULT = 0
Global Const $ICO_DEFAULT = 0
Global Const $ICO_MAKEALPHA = 1 ;// convert to 32bpp and create an alpha channel from the AND-mask when loading
Global Const $IFF_DEFAULT = 0
Global Const $J2K_DEFAULT = 0 ;// save with a 16:1 rate
Global Const $JP2_DEFAULT = 0 ;// save with a 16:1 rate
Global Const $JPEG_DEFAULT = 0 ;// loading (see JPEG_FAST); saving (see JPEG_QUALITYGOOD|JPEG_SUBSAMPLING_420)
Global Const $JPEG_FAST = 0x0001 ;// load the file as fast as possible, sacrificing some quality
Global Const $JPEG_ACCURATE = 0x0002 ;// load the file with the best quality, sacrificing some speed
Global Const $JPEG_CMYK = 0x0004 ;// load separated CMYK "as is" (use | to combine with other load flags)
Global Const $JPEG_EXIFROTATE = 0x0008 ;// load and rotate according to Exif 'Orientation' tag if available
Global Const $JPEG_QUALITYSUPERB = 0x80 ;// save with superb quality (100:1)
Global Const $JPEG_QUALITYGOOD = 0x0100 ;// save with good quality (75:1)
Global Const $JPEG_QUALITYNORMAL = 0x0200 ;// save with normal quality (50:1)
Global Const $JPEG_QUALITYAVERAGE = 0x0400 ;// save with average quality (25:1)
Global Const $JPEG_QUALITYBAD = 0x0800 ;// save with bad quality (10:1)
Global Const $JPEG_PROGRESSIVE = 0x2000 ;// save as a progressive-JPEG (use | to combine with other save flags)
Global Const $JPEG_SUBSAMPLING_411 = 0x1000 ;// save with high 4x1 chroma subsampling (4:1:1)
Global Const $JPEG_SUBSAMPLING_420 = 0x4000 ;// save with medium 2x2 medium chroma subsampling (4:2:0) - default value
Global Const $JPEG_SUBSAMPLING_422 = 0x8000 ;// save with low 2x1 chroma subsampling (4:2:2)
Global Const $JPEG_SUBSAMPLING_444 = 0x10000 ;// save with no chroma subsampling (4:4:4)
Global Const $JPEG_OPTIMIZE = 0x20000 ;// on saving, compute optimal Huffman coding tables(can reduce a few percent of file size)
Global Const $JPEG_BASELINE = 0x40000 ;// save basic JPEG, without metadata Or any markers
Global Const $KOALA_DEFAULT = 0
Global Const $LBM_DEFAULT = 0
Global Const $MNG_DEFAULT = 0
Global Const $PCD_DEFAULT = 0
Global Const $PCD_BASE = 1 ;// load the bitmap sized 768 x 512
Global Const $PCD_BASEDIV4 = 2 ;// load the bitmap sized 384 x 256
Global Const $PCD_BASEDIV16 = 3 ;// load the bitmap sized 192 x 128
Global Const $PCX_DEFAULT = 0
Global Const $PFM_DEFAULT = 0
Global Const $PNG_DEFAULT = 0
Global Const $PNG_IGNOREGAMMA = 1 ;// loading: avoid gamma correction
Global Const $PNG_Z_BEST_SPEED = 0x0001 ;// save using ZLib level 1 compression flag (default value is 6)
Global Const $PNG_Z_DEFAULT_COMPRESSION = 0x0006 ;// save using ZLib level 6 compression flag (default recommended value)
Global Const $PNG_Z_BEST_COMPRESSION = 0x0009 ;// save using ZLib level 9 compression flag (default value is 6)
Global Const $PNG_Z_NO_COMPRESSION = 0x0100 ;// save without ZLib compression
Global Const $PNG_INTERLACED = 0x0200 ;// save using Adam7 interlacing (use | to combine with other save flags)
Global Const $PNM_DEFAULT = 0
Global Const $PNM_SAVE_RAW = 0 ;// If set the writer saves in RAW format (i.e. P4, P5 or P6)
Global Const $PNM_SAVE_ASCII = 1 ;// If set the writer saves in ASCII format (i.e. P1, P2 or P3)
Global Const $PSD_DEFAULT = 0
Global Const $PSD_CMYK = 1 ;// reads tags for separated CMYK (default is conversion to RGB)
Global Const $PSD_LAB = 2 ;// reads tags for CIELab (default is conversion to RGB)
Global Const $RAS_DEFAULT = 0
Global Const $RAW_DEFAULT = 0 ;// load the file as linear RGB 48-bit
Global Const $RAW_PREVIEW = 1 ;// try to load the embedded JPEG preview with included Exif Data or default to RGB 24-bit
Global Const $RAW_DISPLAY = 2 ;// load the file as RGB 24-bit
Global Const $SGI_DEFAULT = 0
Global Const $TARGA_DEFAULT = 0
Global Const $TARGA_LOAD_RGB888 = 1 ;// If set the loader converts RGB555 and ARGB8888 -> RGB888.
Global Const $TARGA_SAVE_RLE = 2 ;// If set, the writer saves with RLE compression
Global Const $TIFF_DEFAULT = 0
Global Const $TIFF_CMYK = 0x0001 ;// reads/stores tags for separated CMYK (use | to combine with compression flags)
Global Const $TIFF_PACKBITS = 0x0100 ;// save using PACKBITS compression
Global Const $TIFF_DEFLATE = 0x0200 ;// save using DEFLATE compression (a.k.a. ZLIB compression)
Global Const $TIFF_ADOBE_DEFLATE = 0x0400 ;// save using ADOBE DEFLATE compression
Global Const $TIFF_NONE = 0x0800 ;// save without any compression
Global Const $TIFF_CCITTFAX3 = 0x1000 ;// save using CCITT Group 3 fax encoding
Global Const $TIFF_CCITTFAX4 = 0x2000 ;// save using CCITT Group 4 fax encoding
Global Const $TIFF_LZW = 0x4000 ;// save using LZW compression
Global Const $TIFF_JPEG = 0x8000 ;// save using JPEG compression
Global Const $TIFF_LOGLUV = 0x10000 ;// save using LogLuv compression
Global Const $WBMP_DEFAULT = 0
Global Const $XBM_DEFAULT = 0
Global Const $XPM_DEFAULT = 0


;~ #ifdef __cplusplus
;~ extern "C" {
;~ #endif

;// Init / Error routines ----------------------------------------------------
Global $__g_hFREEIMAGEDLL = -1, $__g_hFREEIMAGEDLL_RefCount = 0

Func _FreeImage_LoadDLL($sFreeImageDll = "FreeImage.dll")
	;Author: Prog@ndy
	If $__g_hFREEIMAGEDLL_RefCount > 0 Then
		$__g_hFREEIMAGEDLL_RefCount += 1
		Return SetExtended(1, True)
	EndIf
	If IsString($sFreeImageDll) And $sFreeImageDll <> "" Then
		$__g_hFREEIMAGEDLL = DllOpen($sFreeImageDll)
		If $__g_hFREEIMAGEDLL > -1 Then
			$__g_hFREEIMAGEDLL_RefCount += 1
			Return True
		EndIf
	EndIf
	Return SetError(1, 0, False)
EndFunc   ;==>_FreeImage_LoadDLL

Func _FreeImage_UnLoadDLL()
	;Author: Prog@ndy
	If $__g_hFREEIMAGEDLL_RefCount > 0 Then
		$__g_hFREEIMAGEDLL_RefCount -= 1
		If $__g_hFREEIMAGEDLL_RefCount = 0 Then
			DllClose($__g_hFREEIMAGEDLL)
			Return SetExtended(1, True)
		EndIf
		Return True
	EndIf
	Return False
EndFunc   ;==>_FreeImage_UnLoadDLL

;~ DLL_API void DLL_CALLCONV FreeImage_Initialise(BOOL load_local_plugins_only FI_DEFAULT(FALSE));
Func _FreeImage_Initialise($load_local_plugins_only = False)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_Initialise@4", "int", $load_local_plugins_only)
	If @error Then Return SetError(1, @error)
	Return True
EndFunc   ;==>_FreeImage_Initialise
;~ DLL_API void DLL_CALLCONV FreeImage_DeInitialise(void);
Func _FreeImage_DeInitialise()
	;Author: Prog@ndy
	DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_DeInitialise@0")
	If @error Then Return SetError(1, @error)
EndFunc   ;==>_FreeImage_DeInitialise

;// Version routines ---------------------------------------------------------

;~ DLL_API const char *DLL_CALLCONV FreeImage_GetVersion(void);
Func _FreeImage_GetVersion()
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetVersion@0")
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetVersion
;~ DLL_API const char *DLL_CALLCONV FreeImage_GetCopyrightMessage(void);
Func _FreeImage_GetCopyrightMessage()
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetCopyrightMessage@0")
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetCopyrightMessage

;~ #cs
;// Message output functions -------------------------------------------------

;~ typedef void (*FreeImage_OutputMessageFunction)(FREE_IMAGE_FORMAT fif, const char *msg);
;~ DllCallbackRegister("FreeImage_OutputMessageFunction", "none:cdecl", "DWORD;str") ; you should use the STDCALL from next line
;~ typedef void (DLL_CALLCONV *FreeImage_OutputMessageFunctionStdCall)(FREE_IMAGE_FORMAT fif, const char *msg);
;~ DllCallbackRegister("FreeImage_OutputMessageFunctionStdCall", "none" , "DWORD;str")

;~ DLL_API void DLL_CALLCONV FreeImage_SetOutputMessageStdCall(FreeImage_OutputMessageFunctionStdCall omf);
Func _FreeImage_SetOutputMessageStdCall($FreeImage_OutputMessageFunctionStdCall)
	;Author: Prog@ndy
	DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_SetOutputMessageStdCall@4", "ptr", $FreeImage_OutputMessageFunctionStdCall)
	If @error Then Return SetError(1, @error)
EndFunc   ;==>_FreeImage_SetOutputMessageStdCall

;~ DLL_API void DLL_CALLCONV FreeImage_SetOutputMessage(FreeImage_OutputMessageFunction omf); CDELC is not good for Autoit, use STDCALL above
Func _FreeImage_SetOutputMessage($FreeImage_OutputMessageFunction)
	;Author: Prog@ndy
	DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_SetOutputMessage@4", "ptr", $FreeImage_OutputMessageFunction)
	If @error Then Return SetError(1, @error)
EndFunc   ;==>_FreeImage_SetOutputMessage
;~ DLL_API void DLL_CALLCONV FreeImage_OutputMessageProc(int fif, const char *fmt, ...);

;// Allocate / Clone / Unload routines ---------------------------------------

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_Allocate(int width, int height, int bpp, unsigned red_mask FI_DEFAULT(0), unsigned green_mask FI_DEFAULT(0), unsigned blue_mask FI_DEFAULT(0));
Func _FreeImage_Allocate($width, $height, $bpp, $red_mask = 0, $green_mask = 0, $blue_mask = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Allocate@24", "int", $width, "int", $height, "int", $bpp, "uint", $red_mask, "uint", $green_mask, "uint", $blue_mask);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Allocate
;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_AllocateT(FREE_IMAGE_TYPE type, int width, int height, int bpp FI_DEFAULT(8), unsigned red_mask FI_DEFAULT(0), unsigned green_mask FI_DEFAULT(0), unsigned blue_mask FI_DEFAULT(0));
Func _FreeImage_AllocateT($type, $width, $height, $bpp, $red_mask = 0, $green_mask = 0, $blue_mask = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_AllocateT@28", "dword", $type, "int", $width, "int", $height, "int", $bpp, "uint", $red_mask, "uint", $green_mask, "uint", $blue_mask);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AllocateT
;~ DLL_API FIBITMAP * DLL_CALLCONV FreeImage_Clone(FIBITMAP *dib);
Func _FreeImage_Clone($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Clone@4", "ptr", $pDIB);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Clone

;~ DLL_API void DLL_CALLCONV FreeImage_Unload(FIBITMAP *dib);
Func _FreeImage_Unload($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_Unload@4", "ptr", $pDIB);
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_Unload

; // Header loading routines ------------------------------------------------
;~ DLL_API BOOL DLL_CALLCONV FreeImage_HasPixels(FIBITMAP *dib)
Func _FreeImage_HasPixels($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "bool", "_FreeImage_HasPixels@4", "ptr", $pDIB);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_HasPixels

;// Load / Save routines -----------------------------------------------------

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_Load(FREE_IMAGE_FORMAT fif, const char *filename, int flags FI_DEFAULT(0));
Func _FreeImage_Load($fif, $sFileName, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Load@12", $FREE_IMAGE_FORMAT, $fif, "str", $sFileName, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Load

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_LoadU(FREE_IMAGE_FORMAT fif, const wchar_t *filename, int flags FI_DEFAULT(0));
Func _FreeImage_LoadU($fif, $sFileName, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_LoadU@12", $FREE_IMAGE_FORMAT, $fif, "wstr", $sFileName, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_LoadU

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_LoadFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags FI_DEFAULT(0));
Func _FreeImage_LoadFromHandle($fif, $pIO, $handle, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_LoadFromHandle@16", $FREE_IMAGE_FORMAT, $fif, "ptr", $pIO, $fi_handle, $handle, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_LoadFromHandle

;~ DLL_API BOOL DLL_CALLCONV FreeImage_Save(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const char *filename, int flags FI_DEFAULT(0));
Func _FreeImage_Save($fif, $pDIB, $sFileName, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_Save@16", $FREE_IMAGE_FORMAT, $fif, "ptr", $pDIB, "str", $sFileName, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Save

;~ DLL_API BOOL DLL_CALLCONV FreeImage_SaveU(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, const wchar_t *filename, int flags FI_DEFAULT(0));
Func _FreeImage_SaveU($fif, $pDIB, $sFileName, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SaveU@16", $FREE_IMAGE_FORMAT, $fif, "ptr", $pDIB, "wstr", $sFileName, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SaveU


;~ DLL_API BOOL DLL_CALLCONV FreeImage_SaveToHandle(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FreeImageIO *io, fi_handle handle, int flags FI_DEFAULT(0));
Func _FreeImage_SaveToHandle($fif, $pDIB, $pIO, $handle, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SaveToHandle@20", $FREE_IMAGE_FORMAT, $fif, "ptr", $pDIB, "ptr", $pIO, $fi_handle, $handle, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SaveToHandle

;// Memory I/O stream routines -----------------------------------------------
;~ #cs
;	DLL_API FIMEMORY *DLL_CALLCONV FreeImage_OpenMemory(BYTE *data FI_DEFAULT(0), DWORD size_in_bytes FI_DEFAULT(0));
Func _FreeImage_OpenMemory($data, $size_in_bytes)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_OpenMemory@8", "ptr", $data, "dword", $size_in_bytes);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_OpenMemory
;	DLL_API void DLL_CALLCONV FreeImage_CloseMemory(FIMEMORY *stream);
Func _FreeImage_CloseMemory($stream)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_CloseMemory@4", "ptr", $stream);
	If @error Then Return SetError(1, @error)
EndFunc   ;==>_FreeImage_CloseMemory
;	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_LoadFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags FI_DEFAULT(0));
Func _FreeImage_LoadFromMemory($fif, $stream, $flags)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_LoadFromMemory@12", $FREE_IMAGE_FORMAT, $fif, "ptr", $stream, "int", $flags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_LoadFromMemory
;	DLL_API BOOL DLL_CALLCONV FreeImage_SaveToMemory(FREE_IMAGE_FORMAT fif, FIBITMAP *dib, FIMEMORY *stream, int flags FI_DEFAULT(0));
Func _FreeImage_SaveToMemory($fif, $dib, $stream, $flags)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SaveToMemory@16", $FREE_IMAGE_FORMAT, $fif, "ptr", $dib, "ptr", $stream, "int", $flags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SaveToMemory
;	DLL_API long DLL_CALLCONV FreeImage_TellMemory(FIMEMORY *stream);
Func _FreeImage_TellMemory($stream)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "long", "_FreeImage_TellMemory@4", "ptr", $stream);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_TellMemory
;	DLL_API BOOL DLL_CALLCONV FreeImage_SeekMemory(FIMEMORY *stream, long offset, int origin);
Func _FreeImage_SeekMemory($stream, $offset, $origin)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SeekMemory@12", "ptr", $stream, "long", $offset, "int", $origin);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SeekMemory
;	DLL_API BOOL DLL_CALLCONV FreeImage_AcquireMemory(FIMEMORY *stream, BYTE **data, DWORD *size_in_bytes);
Func _FreeImage_AcquireMemory($stream, ByRef $pData, ByRef $size_in_bytes)
	;Author: Prog@ndy
	$pData = 0
	$size_in_bytes = 0
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_AcquireMemory@12", "ptr", $stream, "ptr*", $pData, "dword*", $size_in_bytes);
	If @error Then Return SetError(1, @error, 0)
	$pData = $result[2]
	$size_in_bytes = $result[3]
	Return $result[0]
EndFunc   ;==>_FreeImage_AcquireMemory
;	DLL_API unsigned DLL_CALLCONV FreeImage_ReadMemory(void *buffer, unsigned size, unsigned count, FIMEMORY *stream);
Func _FreeImage_ReadMemory($buffer, $size, $count, $stream)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ulong", "_FreeImage_ReadMemory@16", "ptr", $buffer, "ulong", $size, "ulong", $count, "ptr", $stream);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ReadMemory
;	DLL_API unsigned DLL_CALLCONV FreeImage_WriteMemory(const void *buffer, unsigned size, unsigned count, FIMEMORY *stream);
Func _FreeImage_WriteMemory($buffer, $size, $count, $stream)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ulong", "_FreeImage_WriteMemory@16", "ptr", $buffer, "ulong", $size, "ulong", $count, "ptr", $stream);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_WriteMemory
;	DLL_API FIMULTIBITMAP *DLL_CALLCONV FreeImage_LoadMultiBitmapFromMemory(FREE_IMAGE_FORMAT fif, FIMEMORY *stream, int flags FI_DEFAULT(0));
Func _FreeImage_LoadMultiBitmapFromMemory($fif, $stream, $flags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_LoadMultiBitmapFromMemory@12", $FREE_IMAGE_FORMAT, $fif, "ptr", $stream, "int", $flags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_LoadMultiBitmapFromMemory
;~ DLL_API BOOL DLL_CALLCONV FreeImage_SaveMultiBitmapToMemory(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FIMEMORY *stream, int flags);
Func _FreeImage_SaveMultiBitmapToMemory($fif, $bitmap, $stream, $flags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "bool", "_FreeImage_SaveMultiBitmapToMemory@16", $FREE_IMAGE_FORMAT, $fif, "ptr", $bitmap, "ptr", $stream, "int", $flags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SaveMultiBitmapToMemory
;~ #ce

;// Plugin Interface ---------------------------------------------------------
;~ #cs
;~ 	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_RegisterLocalPlugin(FI_InitProc proc_address, const char *format FI_DEFAULT(0), const char *description FI_DEFAULT(0), const char *extension FI_DEFAULT(0), const char *regexpr FI_DEFAULT(0));
Func _FreeImage_RegisterLocalPlugin($proc_address, $sFormat = 0, $sDescription = 0, $sExtension = 0, $sRegexpr = 0)
	;Author: Prog@ndy
	Local $tFType = "str", $tDType = "str", $tEType = "str", $tRType = "str"
	If $sFormat = "" Then $tFType = "ptr"
	If $sDescription = "" Then $tDType = "ptr"
	If $sExtension = "" Then $tEType = "ptr"
	If $sRegexpr = "" Then $tRType = "ptr"
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_RegisterLocalPlugin@20", "ptr", $proc_address, $tFType, $sFormat, $tDType, $sDescription, $tEType, $sExtension, $tRType, $sRegexpr)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_RegisterLocalPlugin

;~ 	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_RegisterExternalPlugin(const char *path, const char *format FI_DEFAULT(0), const char *description FI_DEFAULT(0), const char *extension FI_DEFAULT(0), const char *regexpr FI_DEFAULT(0));
Func _FreeImage_RegisterExternalPlugin($sPath, $sFormat = 0, $sDescription = 0, $sExtension = 0, $sRegexpr = 0)
	;Author: Prog@ndy
	Local $tFType = "str", $tDType = "str", $tEType = "str", $tRType = "str"
	If $sFormat = "" Then $tFType = "ptr"
	If $sDescription = "" Then $tDType = "ptr"
	If $sExtension = "" Then $tEType = "ptr"
	If $sRegexpr = "" Then $tRType = "ptr"
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_RegisterExternalPlugin@20", "str", $sPath, $tFType, $sFormat, $tDType, $sDescription, $tEType, $sExtension, $tRType, $sRegexpr)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_RegisterExternalPlugin

;~ 	DLL_API int DLL_CALLCONV FreeImage_GetFIFCount(void);
Func _FreeImage_GetFIFCount()
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetFIFCount@0")
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFCount

;~ 	DLL_API int DLL_CALLCONV FreeImage_SetPluginEnabled(FREE_IMAGE_FORMAT fif, BOOL enable);
Func _FreeImage_SetPluginEnabled($fif, $enable)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetPluginEnabled@8", $FREE_IMAGE_FORMAT, $fif, "int", $enable)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetPluginEnabled

;~ 	DLL_API int DLL_CALLCONV FreeImage_IsPluginEnabled(FREE_IMAGE_FORMAT fif);
Func _FreeImage_IsPluginEnabled($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_IsPluginEnabled@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_IsPluginEnabled

;~ 	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFIFFromFormat(const char *format);
Func _FreeImage_GetFIFFromFormat($sFormat)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFIFFromFormat@4", "str", $sFormat)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFFromFormat

;~ 	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFIFFromMime(const char *mime);
Func _FreeImage_GetFIFFromMime($sMime)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFIFFromMime@4", "str", $sMime)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFFromMime

;~ 	DLL_API const char *DLL_CALLCONV FreeImage_GetFormatFromFIF(FREE_IMAGE_FORMAT fif);
Func _FreeImage_GetFormatFromFIF($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetFormatFromFIF@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFormatFromFIF

;~ 	DLL_API const char *DLL_CALLCONV FreeImage_GetFIFExtensionList(FREE_IMAGE_FORMAT fif);
Func _FreeImage_GetFIFExtensionList($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetFIFExtensionList@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFExtensionList

;~ 	DLL_API const char *DLL_CALLCONV FreeImage_GetFIFDescription(FREE_IMAGE_FORMAT fif);
Func _FreeImage_GetFIFDescription($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetFIFDescription@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFDescription

;~ 	DLL_API const char *DLL_CALLCONV FreeImage_GetFIFRegExpr(FREE_IMAGE_FORMAT fif);
Func _FreeImage_GetFIFRegExpr($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetFIFRegExpr@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFRegExpr

;~ 	DLL_API const char *DLL_CALLCONV FreeImage_GetFIFMimeType(FREE_IMAGE_FORMAT fif);
Func _FreeImage_GetFIFMimeType($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetFIFMimeType@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFMimeType

;~ 	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFIFFromFilename(const char *filename);
Func _FreeImage_GetFIFFromFilename($sFileName)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFIFFromFilename@4", "str", $sFileName)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFFromFilename

;~ 	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFIFFromFilenameU(const wchar_t *filename);
Func _FreeImage_GetFIFFromFilenameU($sFileName)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFIFFromFilenameU@4", "wstr", $sFileName)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFIFFromFilenameU

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FIFSupportsReading(FREE_IMAGE_FORMAT fif);
Func _FreeImage_FIFSupportsReading($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FIFSupportsReading@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FIFSupportsReading

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FIFSupportsWriting(FREE_IMAGE_FORMAT fif);
Func _FreeImage_FIFSupportsWriting($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FIFSupportsWriting@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FIFSupportsWriting

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FIFSupportsExportBPP(FREE_IMAGE_FORMAT fif, int bpp);
Func _FreeImage_FIFSupportsExportBPP($fif, $iBPP)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FIFSupportsExportBPP@8", $FREE_IMAGE_FORMAT, $fif, "int", $iBPP)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FIFSupportsExportBPP

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FIFSupportsExportType(FREE_IMAGE_FORMAT fif, FREE_IMAGE_TYPE type);
Func _FreeImage_FIFSupportsExportType($fif, $type)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FIFSupportsExportType@8", $FREE_IMAGE_FORMAT, $fif, "dword", $type)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FIFSupportsExportType

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FIFSupportsICCProfiles(FREE_IMAGE_FORMAT fif);
Func _FreeImage_FIFSupportsICCProfiles($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FIFSupportsICCProfiles@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FIFSupportsICCProfiles

;~ DLL_API BOOL DLL_CALLCONV FreeImage_FIFSupportsNoPixels(FREE_IMAGE_FORMAT fif)
Func _FreeImage_FIFSupportsNoPixels($fif)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FIFSupportsNoPixels@4", $FREE_IMAGE_FORMAT, $fif)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FIFSupportsNoPixels

;~ #ce

;// Multipaging interface ----------------------------------------------------

;~ 	DLL_API FIMULTIBITMAP * DLL_CALLCONV FreeImage_OpenMultiBitmap(FREE_IMAGE_FORMAT fif, const char *filename, BOOL create_new, BOOL read_only, BOOL keep_cache_in_memory FI_DEFAULT(FALSE), int flags FI_DEFAULT(0));
Func _FreeImage_OpenMultiBitmap($fif, $sFileName, $fCreate_New, $fRead_Only, $fKeep_cache_in_memory = False, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $lpFIMULTIBITMAP, "_FreeImage_OpenMultiBitmap@24", $FREE_IMAGE_FORMAT, $fif, "str", $sFileName, "int", $fCreate_New, "int", $fRead_Only, "int", $fKeep_cache_in_memory, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_OpenMultiBitmap
;~ DLL_API FIMULTIBITMAP * DLL_CALLCONV FreeImage_OpenMultiBitmapFromHandle(FREE_IMAGE_FORMAT fif, FreeImageIO *io, fi_handle handle, int flags FI_DEFAULT(0));
Func _FreeImage_OpenMultiBitmapFromHandle($fif, $io, $handle, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $lpFIMULTIBITMAP, "_FreeImage_OpenMultiBitmapFromHandle@16", $FREE_IMAGE_FORMAT, $fif, "ptr", $io, "handle", $handle, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_OpenMultiBitmapFromHandle
;~ DLL_API BOOL DLL_CALLCONV FreeImage_SaveMultiBitmapToHandle(FREE_IMAGE_FORMAT fif, FIMULTIBITMAP *bitmap, FreeImageIO *io, fi_handle handle, int flags FI_DEFAULT(0));
Func _FreeImage_SaveMultiBitmapToHandle($fif, $bitmap, $io, $handle, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $lpFIMULTIBITMAP, "_FreeImage_SaveMultiBitmapToHandle@20", $FREE_IMAGE_FORMAT, $fif, "ptr", $bitmap, "ptr", $io, "handle", $handle, "int", $iFlags);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SaveMultiBitmapToHandle
;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_CloseMultiBitmap(FIMULTIBITMAP *bitmap, int flags FI_DEFAULT(0));
Func _FreeImage_CloseMultiBitmap($pBitmap, $iFlags = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_CloseMultiBitmap@8", $lpFIMULTIBITMAP, $pBitmap, "int", $iFlags)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_CloseMultiBitmap
;~ 	DLL_API int DLL_CALLCONV FreeImage_GetPageCount(FIMULTIBITMAP *bitmap);
Func _FreeImage_GetPageCount($pBitmap)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetPageCount@4", $lpFIMULTIBITMAP, $pBitmap)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetPageCount
;~ 	DLL_API void DLL_CALLCONV FreeImage_AppendPage(FIMULTIBITMAP *bitmap, FIBITMAP *data);
Func _FreeImage_AppendPage($pBitmap, $pData)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_AppendPage@8", $lpFIMULTIBITMAP, $pBitmap, $lpFIBITMAP, $pData)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_AppendPage
;~ 	DLL_API void DLL_CALLCONV FreeImage_InsertPage(FIMULTIBITMAP *bitmap, int page, FIBITMAP *data);
Func _FreeImage_InsertPage($pBitmap, $iPage, $pData)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_InsertPage@12", $lpFIMULTIBITMAP, $pBitmap, "int", $iPage, $lpFIBITMAP, $pData)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_InsertPage
;~ 	DLL_API void DLL_CALLCONV FreeImage_DeletePage(FIMULTIBITMAP *bitmap, int page);
Func _FreeImage_DeletePage($pBitmap, $iPage)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_DeletePage@8", $lpFIMULTIBITMAP, $pBitmap, "int", $iPage)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_DeletePage
;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_LockPage(FIMULTIBITMAP *bitmap, int page);
Func _FreeImage_LockPage($pBitmap, $iPage)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $lpFIBITMAP, "_FreeImage_LockPage@8", $lpFIMULTIBITMAP, $pBitmap, "int", $iPage)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_LockPage
;~ 	DLL_API void DLL_CALLCONV FreeImage_UnlockPage(FIMULTIBITMAP *bitmap, FIBITMAP *data, BOOL changed);
Func _FreeImage_UnlockPage($pBitmap, $pData, $fChanged)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_UnlockPage@12", $lpFIMULTIBITMAP, $pBitmap, $lpFIBITMAP, $pData, "int", $fChanged)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_UnlockPage
;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_MovePage(FIMULTIBITMAP *bitmap, int target, int source);
Func _FreeImage_MovePage($pBitmap, $iTarget, $iSource)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_MovePage@12", $lpFIMULTIBITMAP, $pBitmap, "int", $iTarget, "int", $iSource)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_MovePage
;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_GetLockedPageNumbers(FIMULTIBITMAP *bitmap, int *pages, int *count);
Func _FreeImage_GetLockedPageNumbers($pBitmap, $p_aiPages, ByRef $iCount)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetLockedPageNumbers@12", $lpFIMULTIBITMAP, $pBitmap, "ptr", $p_aiPages, "int*", $iCount)
	If @error Then Return SetError(1, @error, 0)
	$iCount = $result[3]
	Return $result[0]
EndFunc   ;==>_FreeImage_GetLockedPageNumbers

;// Filetype request routines ------------------------------------------------
;~ #CS
;~    	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFileType(const char *filename, int size FI_DEFAULT(0));
Func _FreeImage_GetFileType($sFileName, $iSize = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFileType@8", "str", $sFileName, "int", $iSize)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFileType
;~    	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFileTypeU(const wchar_t *filename, int size FI_DEFAULT(0));
Func _FreeImage_GetFileTypeU($sFileName, $iSize = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFileTypeU@8", "str", $sFileName, "int", $iSize)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFileTypeU
;~    	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFileTypeFromHandle(FreeImageIO *io, fi_handle handle, int size FI_DEFAULT(0));
Func _FreeImage_GetFileTypeFromHandle($pIO, $handle, $iSize = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFileTypeFromHandle@12", "ptr", $pIO, $fi_handle, $handle, "int", $iSize)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFileTypeFromHandle
;~    	DLL_API FREE_IMAGE_FORMAT DLL_CALLCONV FreeImage_GetFileTypeFromMemory(FIMEMORY *stream, int size FI_DEFAULT(0));
Func _FreeImage_GetFileTypeFromMemory($pStream, $iSize = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_FORMAT, "_FreeImage_GetFileTypeFromMemory@8", "ptr", $pStream, "int", $iSize)
	If @error Then Return SetError(1, @error, $FIF_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetFileTypeFromMemory
;~ #CE

;// Image type request routine -----------------------------------------------
;~    	DLL_API FREE_IMAGE_TYPE DLL_CALLCONV FreeImage_GetImageType(FIBITMAP *dib);
Func _FreeImage_GetImageType($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_TYPE, "_FreeImage_GetImageType@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, $FIT_UNKNOWN)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetImageType


;// FreeImage helper routines ------------------------------------------------
;~ #CS
;~    	DLL_API BOOL DLL_CALLCONV FreeImage_IsLittleEndian(void);
Func _FreeImage_IsLittleEndian()
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_IsLittleEndian@0")
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_IsLittleEndian

;~    	DLL_API BOOL DLL_CALLCONV FreeImage_LookupX11Color(const char *szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);
Func _FreeImage_LookupX11Color($sColor, ByRef $nRed, ByRef $nGreen, ByRef $nBlue)
	;Author: Prog@ndy
	$nRed = 0
	$nGreen = 0
	$nBlue = 0
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_LookupX11Color@16", "str", $sColor, "ubyte*", 0, "ubyte*", 0, "ubyte*", 0)
	If @error Then Return SetError(1, @error, 0)
	$nRed = $result[2]
	$nGreen = $result[3]
	$nBlue = $result[4]
	Return $result[0]
EndFunc   ;==>_FreeImage_LookupX11Color

;~    	DLL_API BOOL DLL_CALLCONV FreeImage_LookupSVGColor(const char *szColor, BYTE *nRed, BYTE *nGreen, BYTE *nBlue);
Func _FreeImage_LookupSVGColor($sColor, ByRef $nRed, ByRef $nGreen, ByRef $nBlue)
	;Author: Prog@ndy
	$nRed = 0
	$nGreen = 0
	$nBlue = 0
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_LookupSVGColor@16", "str", $sColor, "ubyte*", 0, "ubyte*", 0, "ubyte*", 0)
	If @error Then Return SetError(1, @error, 0)
	$nRed = $result[2]
	$nGreen = $result[3]
	$nBlue = $result[4]
	Return $result[0]
EndFunc   ;==>_FreeImage_LookupSVGColor

;~ #CE

;// Pixel access routines ----------------------------------------------------
;~ #CS
;~    	DLL_API BYTE *DLL_CALLCONV FreeImage_GetBits(FIBITMAP *dib);
Func _FreeImage_GetBits($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetBits@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetBits

;~    	DLL_API BYTE *DLL_CALLCONV FreeImage_GetScanLine(FIBITMAP *dib, int scanline);
Func _FreeImage_GetScanLine($pDIB, $iScanline)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetScanLine@8", $lpFIBITMAP, $pDIB, "int", $iScanline)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetScanLine

;~    	DLL_API BOOL DLL_CALLCONV FreeImage_GetPixelIndex(FIBITMAP *dib, unsigned x, unsigned y, BYTE *value);
Func _FreeImage_GetPixelIndex($pDIB, $X, $Y, ByRef $Value)
	;Author: Prog@ndy
	$Value = 0
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetPixelIndex@16", $lpFIBITMAP, $pDIB, "uint", $X, "uint", $Y, "byte*", 0)
	If @error Then Return SetError(1, @error, 0)
	$Value = $result[4]
	Return $result[0]
EndFunc   ;==>_FreeImage_GetPixelIndex

;~    	DLL_API BOOL DLL_CALLCONV FreeImage_GetPixelColor(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value);
Func _FreeImage_GetPixelColor($pDIB, $X, $Y, ByRef $RGBQUAD, $fDWORD = False)
	;Author: Prog@ndy
	If $fDWORD Then
		Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetPixelColor@16", $lpFIBITMAP, $pDIB, "uint", $X, "uint", $Y, "dword*", 0)
		If @error Then Return SetError(1, @error, 0)
		$RGBQUAD = $result[4]
		Return $result[0]
	EndIf
	$RGBQUAD = DllStructCreate($tagRGBQUAD)
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetPixelColor@16", $lpFIBITMAP, $pDIB, "uint", $X, "uint", $Y, "ptr", DllStructGetPtr($RGBQUAD))
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetPixelColor

;~    	DLL_API BOOL DLL_CALLCONV FreeImage_SetPixelIndex(FIBITMAP *dib, unsigned x, unsigned y, BYTE *value);
Func _FreeImage_SetPixelIndex($pDIB, $X, $Y, $Value)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetPixelIndex@16", $lpFIBITMAP, $pDIB, "uint", $X, "uint", $Y, "byte*", $Value)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetPixelIndex

;~    	DLL_API BOOL DLL_CALLCONV FreeImage_SetPixelColor(FIBITMAP *dib, unsigned x, unsigned y, RGBQUAD *value);
Func _FreeImage_SetPixelColor($pDIB, $X, $Y, ByRef $RGBQUAD, $fDWORD = False)
	;Author: Prog@ndy
	If $fDWORD Then
		Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetPixelColor@16", $lpFIBITMAP, $pDIB, "uint", $X, "uint", $Y, "dword*", $RGBQUAD)
		If @error Then Return SetError(1, @error, 0)
		Return $result[0]
	EndIf
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetPixelColor@16", $lpFIBITMAP, $pDIB, "uint", $X, "uint", $Y, "ptr", DllStructGetPtr($RGBQUAD))
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetPixelColor
;~
;~ #CE

;// DIB info routines --------------------------------------------------------

;~ #CS
;~  	DLL_API unsigned DLL_CALLCONV FreeImage_GetColorsUsed(FIBITMAP *dib);
Func _FreeImage_GetColorsUsed($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetColorsUsed@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetColorsUsed

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetBPP(FIBITMAP *dib);
Func _FreeImage_GetBPP($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetBPP@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetBPP

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetWidth(FIBITMAP *dib);
Func _FreeImage_GetWidth($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetWidth@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetWidth

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetHeight(FIBITMAP *dib);
Func _FreeImage_GetHeight($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetHeight@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetHeight

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetLine(FIBITMAP *dib);
Func _FreeImage_GetLine($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetLine@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetLine

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetPitch(FIBITMAP *dib);
Func _FreeImage_GetPitch($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetPitch@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetPitch

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetDIBSize(FIBITMAP *dib);
Func _FreeImage_GetDIBSize($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetDIBSize@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetDIBSize

;~    	DLL_API RGBQUAD *DLL_CALLCONV FreeImage_GetPalette(FIBITMAP *dib);
Func _FreeImage_GetPalette($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetPalette@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetPalette


;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetDotsPerMeterX(FIBITMAP *dib);
Func _FreeImage_GetDotsPerMeterX($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetDotsPerMeterX@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetDotsPerMeterX

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetDotsPerMeterY(FIBITMAP *dib);
Func _FreeImage_GetDotsPerMeterY($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetDotsPerMeterY@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetDotsPerMeterY

;~    	DLL_API void DLL_CALLCONV FreeImage_SetDotsPerMeterX(FIBITMAP *dib, unsigned res);
Func _FreeImage_SetDotsPerMeterX($pDIB, $iRes)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_SetDotsPerMeterX@4", $lpFIBITMAP, $pDIB, "uint", $iRes)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_SetDotsPerMeterX

;~    	DLL_API void DLL_CALLCONV FreeImage_SetDotsPerMeterY(FIBITMAP *dib, unsigned res);
Func _FreeImage_SetDotsPerMeterY($pDIB, $iRes)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_SetDotsPerMeterY@4", $lpFIBITMAP, $pDIB, "uint", $iRes)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_SetDotsPerMeterY

;~    	DLL_API BITMAPINFOHEADER *DLL_CALLCONV FreeImage_GetInfoHeader(FIBITMAP *dib);
Func _FreeImage_GetInfoHeader($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetInfoHeader@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetInfoHeader

;~    	DLL_API BITMAPINFO *DLL_CALLCONV FreeImage_GetInfo(FIBITMAP *dib);
Func _FreeImage_GetInfo($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetInfo@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetInfo

;~    	DLL_API FREE_IMAGE_COLOR_TYPE DLL_CALLCONV FreeImage_GetColorType(FIBITMAP *dib);
Func _FreeImage_GetColorType($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetColorType@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetColorType

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetRedMask(FIBITMAP *dib);
Func _FreeImage_GetRedMask($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetRedMask@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetRedMask

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetGreenMask(FIBITMAP *dib);
Func _FreeImage_GetGreenMask($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetGreenMask@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetGreenMask

;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetBlueMask(FIBITMAP *dib);
Func _FreeImage_GetBlueMask($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetBlueMask@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetBlueMask


;~    	DLL_API unsigned DLL_CALLCONV FreeImage_GetTransparencyCount(FIBITMAP *dib);
Func _FreeImage_GetTransparencyCount($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetTransparencyCount@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTransparencyCount

;~    	DLL_API BYTE * DLL_CALLCONV FreeImage_GetTransparencyTable(FIBITMAP *dib);
Func _FreeImage_GetTransparencyTable($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetTransparencyTable@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTransparencyTable

;   	DLL_API void DLL_CALLCONV FreeImage_SetTransparent(FIBITMAP *dib, BOOL enabled);
Func _FreeImage_SetTransparent($pDIB, $enabled)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_SetTransparent@8", $lpFIBITMAP, $pDIB, "int", $enabled)
	If @error Then Return SetError(1, @error)
EndFunc   ;==>_FreeImage_SetTransparent

;   	DLL_API void DLL_CALLCONV FreeImage_SetTransparencyTable(FIBITMAP *dib, BYTE *table, int count);
Func _FreeImage_SetTransparencyTable($pDIB, $table, $count)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_SetTransparencyTable@12", $lpFIBITMAP, $pDIB, "ptr", $table, "int", $count)
	If @error Then Return SetError(1, @error)
EndFunc   ;==>_FreeImage_SetTransparencyTable

;   	DLL_API BOOL DLL_CALLCONV FreeImage_IsTransparent(FIBITMAP *dib);
Func _FreeImage_IsTransparent($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_IsTransparent@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_IsTransparent

;   	DLL_API void DLL_CALLCONV FreeImage_SetTransparentIndex(FIBITMAP *dib, int index);
Func _FreeImage_SetTransparentIndex($pDIB, $index)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_SetTransparentIndex@8", $lpFIBITMAP, $pDIB, "int", $index)
	If @error Then Return SetError(1, @error)
EndFunc   ;==>_FreeImage_SetTransparentIndex

;   	DLL_API int DLL_CALLCONV FreeImage_GetTransparentIndex(FIBITMAP *dib);
Func _FreeImage_GetTransparentIndex($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetTransparentIndex@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTransparentIndex

;   	DLL_API BOOL DLL_CALLCONV FreeImage_HasBackgroundColor(FIBITMAP *dib);
Func _FreeImage_HasBackgroundColor($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_HasBackgroundColor@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_HasBackgroundColor

;   	DLL_API BOOL DLL_CALLCONV FreeImage_GetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);
Func _FreeImage_GetBackgroundColor($pDIB, $bkcolor)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetBackgroundColor@8", $lpFIBITMAP, $pDIB, "ptr", $bkcolor)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetBackgroundColor

;   	DLL_API BOOL DLL_CALLCONV FreeImage_SetBackgroundColor(FIBITMAP *dib, RGBQUAD *bkcolor);
Func _FreeImage_SetBackgroundColor($pDIB, $bkcolor)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetBackgroundColor@8", $lpFIBITMAP, $pDIB, "ptr", $bkcolor)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetBackgroundColor

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_GetThumbnail(FIBITMAP *dib);
Func _FreeImage_GetThumbnail($pDIB, $bkcolor)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetThumbnail@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetThumbnail

;~ DLL_API BOOL DLL_CALLCONV FreeImage_SetThumbnail(FIBITMAP *dib, FIBITMAP *thumbnail);
Func _FreeImage_SetThumbnail($pDIB, $thumbnail)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetThumbnail@8", $lpFIBITMAP, $pDIB, "ptr", $thumbnail)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetThumbnail

;~ #CE


;// ICC profile routines -----------------------------------------------------

;~ #CS
; 	DLL_API FIICCPROFILE *DLL_CALLCONV FreeImage_GetICCProfile(FIBITMAP *dib);
Func _FreeImage_GetICCProfile($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetICCProfile@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetICCProfile
;   	DLL_API FIICCPROFILE *DLL_CALLCONV FreeImage_CreateICCProfile(FIBITMAP *dib, void *data, long size);
Func _FreeImage_CreateICCProfile($pDIB, $data, $size)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_CreateICCProfile@12", $lpFIBITMAP, $pDIB, "ptr", $data, "long", $size)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_CreateICCProfile
;   	DLL_API void DLL_CALLCONV FreeImage_DestroyICCProfile(FIBITMAP *dib);
Func _FreeImage_DestroyICCProfile($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_DestroyICCProfile@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_DestroyICCProfile
;~ #CE

;// Line conversion routines -------------------------------------------------
;~ #CS
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine1To4(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine1To4($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine1To4@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine1To4
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine8To4(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine8To4($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine8To4@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine8To4
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To4_555(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To4_555($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To4_555@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To4_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To4_565(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To4_565($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To4_565@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To4_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine24To4(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine24To4($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine24To4@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine24To4
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine32To4(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine32To4($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine32To4@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine32To4
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine1To8(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine1To8($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine1To8@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine1To8
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine4To8(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine4To8($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine4To8@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine4To8
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To8_555(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To8_555($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To8_555@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To8_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To8_565(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To8_565($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To8_565@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To8_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine24To8(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine24To8($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine24To8@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine24To8
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine32To8(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine32To8($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine32To8@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine32To8
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine1To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine1To16_555($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine1To16_555@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine1To16_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine4To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine4To16_555($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine4To16_555@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine4To16_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine8To16_555(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine8To16_555($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine8To16_555@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine8To16_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16_565_To16_555(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16_565_To16_555($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16_565_To16_555@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16_565_To16_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine24To16_555(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine24To16_555($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine24To16_555@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine24To16_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine32To16_555(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine32To16_555($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine32To16_555@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine32To16_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine1To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine1To16_565($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine1To16_565@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine1To16_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine4To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine4To16_565($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine4To16_565@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine4To16_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine8To16_565(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine8To16_565($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine8To16_565@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine8To16_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16_555_To16_565(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16_555_To16_565($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16_555_To16_565@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16_555_To16_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine24To16_565(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine24To16_565($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine24To16_565@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine24To16_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine32To16_565(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine32To16_565($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine32To16_565@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine32To16_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine1To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine1To24($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine1To24@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine1To24
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine4To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine4To24($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine4To24@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine4To24
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine8To24(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine8To24($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine8To24@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine8To24
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To24_555(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To24_555($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To24_555@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To24_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To24_565(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To24_565($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To24_565@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To24_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine32To24(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine32To24($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine32To24@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine32To24
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine1To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine1To32($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine1To32@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine1To32
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine4To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine4To32($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine4To32@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine4To32
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine8To32(BYTE *target, BYTE *source, int width_in_pixels, RGBQUAD *palette);
Func _FreeImage_ConvertLine8To32($target, $source, $width_in_pixels, $palette)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine8To32@16", "ptr", $target, "ptr", $source, "int", $width_in_pixels, "ptr", $palette)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine8To32
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To32_555(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To32_555($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To32_555@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To32_555
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine16To32_565(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine16To32_565($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine16To32_565@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine16To32_565
;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertLine24To32(BYTE *target, BYTE *source, int width_in_pixels);
Func _FreeImage_ConvertLine24To32($target, $source, $width_in_pixels)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertLine24To32@12", "ptr", $target, "ptr", $source, "int", $width_in_pixels)
	If @error Then Return SetError(1, @error, 0)
EndFunc   ;==>_FreeImage_ConvertLine24To32

;~ #CE

;// Smart conversion routines ------------------------------------------------
;~ #CS
;   	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertTo4Bits(FIBITMAP *dib);
Func _FreeImage_ConvertTo4Bits($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertTo4Bits@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertTo4Bits

;   	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertTo8Bits(FIBITMAP *dib);
Func _FreeImage_ConvertTo8Bits($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertTo8Bits@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertTo8Bits

;   	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertToGreyscale(FIBITMAP *dib);
Func _FreeImage_ConvertToGreyscale($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertToGreyscale@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertToGreyscale

;   	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertTo16Bits555(FIBITMAP *dib);
Func _FreeImage_ConvertTo16Bits555($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertTo16Bits555@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertTo16Bits555

;   	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertTo16Bits565(FIBITMAP *dib);
Func _FreeImage_ConvertTo16Bits565($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertTo16Bits565@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertTo16Bits565

;   	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertTo24Bits(FIBITMAP *dib);
Func _FreeImage_ConvertTo24Bits($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertTo24Bits@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertTo24Bits

; DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ConvertTo32Bits(FIBITMAP * dib);
Func _FreeImage_ConvertTo32Bits($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertTo32Bits@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertTo32Bits

;	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ColorQuantize(FIBITMAP * dib, FREE_IMAGE_QUANTIZE quantize);
Func _FreeImage_ColorQuantize($pDIB, $quantize)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ColorQuantize@8", $lpFIBITMAP, $pDIB, $FREE_IMAGE_QUANTIZE, $quantize)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ColorQuantize

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ColorQuantizeEx(FIBITMAP * dib, FREE_IMAGE_QUANTIZE quantize FI_DEFAULT(FIQ_WUQUANT), int PaletteSize FI_DEFAULT(256), int ReserveSize FI_DEFAULT(0), RGBQUAD * ReservePalette FI_DEFAULT(NULL));
Func _FreeImage_ColorQuantizeEx($pDIB, $quantize = $FIQ_WUQUANT, $PaletteSize = 256, $ReserveSize = 0, $pReservePalette = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ColorQuantizeEx@20", $lpFIBITMAP, $pDIB, $FREE_IMAGE_QUANTIZE, $quantize, "int", $PaletteSize, "int", $ReserveSize, "ptr", $pReservePalette)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ColorQuantizeEx

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_Threshold(FIBITMAP * dib, BYTE T);
Func _FreeImage_Threshold($pDIB, $T)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Threshold@8", $lpFIBITMAP, $pDIB, "byte", $T)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Threshold

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_Dither(FIBITMAP * dib, FREE_IMAGE_DITHER algorithm);
Func _FreeImage_Dither($pDIB, $algorithm)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Dither@8", $lpFIBITMAP, $pDIB, $FREE_IMAGE_DITHER, $algorithm)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Dither

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ConvertFromRawBits(BYTE * bits, int width, int height, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown FI_DEFAULT(False));
Func _FreeImage_ConvertFromRawBits($bits, $width, $height, $pitch, $bpp, $red_mask, $green_mask, $blue_mask, $topdown = False)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertFromRawBits@36", "ptr", $bits, "int", $width, "int", $height, "int", $pitch, "uint", $bpp, "uint", $red_mask, "uint", $green_mask, "uint", $blue_mask, "int", $topdown);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertFromRawBits

;~ 	DLL_API void DLL_CALLCONV FreeImage_ConvertToRawBits(BYTE * bits, FIBITMAP * dib, int pitch, unsigned bpp, unsigned red_mask, unsigned green_mask, unsigned blue_mask, BOOL topdown FI_DEFAULT(False));
Func _FreeImage_ConvertToRawBits($bits, $pDIB, $pitch, $bpp, $red_mask, $green_mask, $blue_mask, $topdown = False)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_ConvertToRawBits@32", "ptr", $bits, $lpFIBITMAP, $pDIB, "int", $pitch, "uint", $bpp, "uint", $red_mask, "uint", $green_mask, "uint", $blue_mask, "int", $topdown);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertToRawBits

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertToFloat(FIBITMAP *dib);
Func _FreeImage_ConvertToFloat($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertToFloat@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertToFloat
;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ConvertToRGBF(FIBITMAP * dib);
Func _FreeImage_ConvertToRGBF($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertToRGBF@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertToRGBF
;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_ConvertToUINT16(FIBITMAP *dib);
Func _FreeImage_ConvertToUINT16($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertToUINT16@4", $lpFIBITMAP, $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertToUINT16

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ConvertToStandardType(FIBITMAP * src, BOOL scale_linear FI_DEFAULT(True));
Func _FreeImage_ConvertToStandardType($pDIB, $scale_linear = True)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertToStandardType@8", $lpFIBITMAP, $pDIB, "int", $scale_linear)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertToStandardType

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ConvertToType(FIBITMAP * src, FREE_IMAGE_TYPE dst_type, BOOL scale_linear FI_DEFAULT(True));
Func _FreeImage_ConvertToType($pDIB, $dst_type, $scale_linear = True)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ConvertToType@12", $lpFIBITMAP, $pDIB, $FREE_IMAGE_TYPE, $dst_type, "int", $scale_linear)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ConvertToType


;// tone mapping operators
;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_ToneMapping(FIBITMAP * dib, FREE_IMAGE_TMO tmo, double first_param FI_DEFAULT(0), double second_param FI_DEFAULT(0));
Func _FreeImage_ToneMapping($pDIB, $tmo, $first_param = 0, $second_param = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_ToneMapping@24", $lpFIBITMAP, $pDIB, $FREE_IMAGE_TMO, $tmo, "double", $first_param, "double", $second_param)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ToneMapping

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_TmoDrago03(FIBITMAP * src, double gamma FI_DEFAULT(2.2), double exposure FI_DEFAULT(0));
Func _FreeImage_TmoDrago03($pDIB, $gamma = 2.2, $exposure = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_TmoDrago03@20", $lpFIBITMAP, $pDIB, "double", $gamma, "double", $exposure)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_TmoDrago03

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_TmoReinhard05(FIBITMAP * src, double intensity FI_DEFAULT(0), double contrast FI_DEFAULT(0));
Func _FreeImage_TmoReinhard05($pDIB, $intensity = 0, $contrast = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_TmoReinhard05@20", $lpFIBITMAP, $pDIB, "double", $intensity, "double", $contrast)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_TmoReinhard05

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_TmoReinhard05Ex(FIBITMAP *src, double intensity FI_DEFAULT(0), double contrast FI_DEFAULT(0), double adaptation FI_DEFAULT(1), double color_correction FI_DEFAULT(0));
Func _FreeImage_TmoReinhard05Ex($pDIB, $intensity = 0, $contrast = 0, $adaption = 1, $color_correction = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_TmoReinhard05Ex@36", $lpFIBITMAP, $pDIB, "double", $intensity, "double", $contrast, "double", $adaption, "double", $color_correction)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_TmoReinhard05Ex

;~ 	DLL_API FIBITMAP * DLL_CALLCONV FreeImage_TmoFattal02(FIBITMAP * src, double color_saturation FI_DEFAULT(0.5), double attenuation FI_DEFAULT(0.85));
Func _FreeImage_TmoFattal02($pDIB, $color_saturation = 0.5, $attenuation = 0.85)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_TmoFattal02@20", $lpFIBITMAP, $pDIB, "double", $color_saturation, "double", $attenuation)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_TmoFattal02

;// ZLib interface -----------------------------------------------------------
;~ #CS
;~ 	DLL_API DWORD DLL_CALLCONV FreeImage_ZLibCompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
Func _FreeImage_ZLibCompress($pTarget, $target_size, $pSource, $source_size)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "dword", "_FreeImage_ZLibCompress@16", "ptr", $pTarget, "dword", $target_size, "ptr", $pSource, "dword", $source_size)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ZLibCompress

;~ 	DLL_API DWORD DLL_CALLCONV FreeImage_ZLibUncompress(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
Func _FreeImage_ZLibUncompress($pTarget, $target_size, $pSource, $source_size)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "dword", "_FreeImage_ZLibUncompress@16", "ptr", $pTarget, "dword", $target_size, "ptr", $pSource, "dword", $source_size)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ZLibUncompress

;~ 	DLL_API DWORD DLL_CALLCONV FreeImage_ZLibGZip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
Func _FreeImage_ZLibGZip($pTarget, $target_size, $pSource, $source_size)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "dword", "_FreeImage_ZLibGZip@16", "ptr", $pTarget, "dword", $target_size, "ptr", $pSource, "dword", $source_size)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ZLibGZip

;~ 	DLL_API DWORD DLL_CALLCONV FreeImage_ZLibGUnzip(BYTE *target, DWORD target_size, BYTE *source, DWORD source_size);
Func _FreeImage_ZLibGUnzip($pTarget, $target_size, $pSource, $source_size)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "dword", "_FreeImage_ZLibGUnzip@16", "ptr", $pTarget, "dword", $target_size, "ptr", $pSource, "dword", $source_size)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ZLibGUnzip

;~ 	DLL_API DWORD DLL_CALLCONV FreeImage_ZLibCRC32(DWORD crc, BYTE *source, DWORD source_size);
Func _FreeImage_ZLibCRC32($crc, $pSource, $source_size)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "dword", "_FreeImage_ZLibCRC32@12", "dword", $crc, "ptr", $pSource, "dword", $source_size)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ZLibCRC32

;// --------------------------------------------------------------------------
;// Metadata routines --------------------------------------------------------
;// --------------------------------------------------------------------------

;// tag creation / destruction
;~ 	DLL_API FITAG *DLL_CALLCONV FreeImage_CreateTag();
Func _FreeImage_CreateTag()
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_CreateTag@0")
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_CreateTag

;~ 	DLL_API void DLL_CALLCONV FreeImage_DeleteTag(FITAG *tag);
Func _FreeImage_DeleteTag($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "none", "_FreeImage_DeleteTag@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_DeleteTag

;~ 	DLL_API FITAG *DLL_CALLCONV FreeImage_CloneTag(FITAG *tag);
Func _FreeImage_CloneTag($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_CloneTag@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_CloneTag


;// tag getters and setters
;~ 	DLL_API const char *DLL_CALLCONV FreeImage_GetTagKey(FITAG *tag);
Func _FreeImage_GetTagKey($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetTagKey@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTagKey

;~ 	DLL_API const char *DLL_CALLCONV FreeImage_GetTagDescription(FITAG *tag);
Func _FreeImage_GetTagDescription($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_GetTagDescription@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTagDescription

;~ 	DLL_API WORD DLL_CALLCONV FreeImage_GetTagID(FITAG *tag);
Func _FreeImage_GetTagID($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ushort", "_FreeImage_GetTagID@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTagID

;~ 	DLL_API FREE_IMAGE_MDTYPE DLL_CALLCONV FreeImage_GetTagType(FITAG *tag);
Func _FreeImage_GetTagType($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, $FREE_IMAGE_MDTYPE, "_FreeImage_GetTagType@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTagType

;~ 	DLL_API DWORD DLL_CALLCONV FreeImage_GetTagCount(FITAG *tag);
Func _FreeImage_GetTagCount($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "dword", "_FreeImage_GetTagCount@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTagCount

;~ 	DLL_API DWORD DLL_CALLCONV FreeImage_GetTagLength(FITAG *tag);
Func _FreeImage_GetTagLength($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "dword", "_FreeImage_GetTagLength@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTagLength

;~ 	DLL_API const void *DLL_CALLCONV FreeImage_GetTagValue(FITAG *tag);
Func _FreeImage_GetTagValue($pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetTagValue@4", "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetTagValue


;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetTagKey(FITAG *tag, const char *key);
Func _FreeImage_SetTagKey($pTag, $key)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetTagKey@8", "ptr", $pTag, "str", $key)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetTagKey

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetTagDescription(FITAG *tag, const char *description);
Func _FreeImage_SetTagDescription($pTag, $description)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetTagDescription@8", "ptr", $pTag, "str", $description)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetTagDescription

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetTagID(FITAG *tag, WORD id);
Func _FreeImage_SetTagID($pTag, $id)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetTagID@8", "ptr", $pTag, "ushort", $id)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetTagID

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetTagType(FITAG *tag, FREE_IMAGE_MDTYPE type);
Func _FreeImage_SetTagType($pTag, $type)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetTagType@8", "ptr", $pTag, $FREE_IMAGE_MDTYPE, $type)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetTagType

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetTagCount(FITAG *tag, DWORD count);
Func _FreeImage_SetTagCount($pTag, $count)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetTagCount@8", "ptr", $pTag, "dword", $count)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetTagCount

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetTagLength(FITAG *tag, DWORD length);
Func _FreeImage_SetTagLength($pTag, $length)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetTagLength@8", "ptr", $pTag, "dword", $length)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetTagLength

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetTagValue(FITAG *tag, const void *value);
Func _FreeImage_SetTagValue($pTag, $pValue)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetTagValue@8", "ptr", $pTag, "ptr", $pValue)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetTagValue


;// iterator
;~ 	DLL_API FIMETADATA *DLL_CALLCONV FreeImage_FindFirstMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, FITAG **tag);
Func _FreeImage_FindFirstMetadata($model, $pDIB, ByRef $pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_FindFirstMetadata@12", $FREE_IMAGE_MDMODEL, $model, "ptr", $pDIB, "ptr*", $pTag)
	If @error Then Return SetError(1, @error, 0)
	$pTag = $result[3]
	Return $result[0]
EndFunc   ;==>_FreeImage_FindFirstMetadata

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FindNextMetadata(FIMETADATA *mdhandle, FITAG **tag);
Func _FreeImage_FindNextMetadata($mdhandle, ByRef $pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FindNextMetadata@8", "ptr", $mdhandle, "ptr*", $pTag)
	If @error Then Return SetError(1, @error, 0)
	$pTag = $result[2]
	Return $result[0]
EndFunc   ;==>_FreeImage_FindNextMetadata

;~ 	DLL_API void DLL_CALLCONV FreeImage_FindCloseMetadata(FIMETADATA *mdhandle);
Func _FreeImage_FindCloseMetadata($mdhandle)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FindCloseMetadata@4", "ptr", $mdhandle)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FindCloseMetadata


;// metadata setter and getter
;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const char *key, FITAG *tag);
Func _FreeImage_SetMetadata($model, $pDIB, $key, $pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FindCloseMetadata@16", $FREE_IMAGE_MDMODEL, $model, "ptr", $pDIB, "str", $key, "ptr", $pTag)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetMetadata

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_GetMetadata(FREE_IMAGE_MDMODEL model, FIBITMAP *dib, const char *key, FITAG **tag);
Func _FreeImage_GetMetadata($model, $pDIB, $key, ByRef $pTag)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_GetMetadata@16", $FREE_IMAGE_MDMODEL, $model, "ptr", $pDIB, "str", $key, "ptr*", $pTag)
	If @error Then Return SetError(1, @error, 0)
	$pTag = $result[4]
	Return $result[0]
EndFunc   ;==>_FreeImage_GetMetadata


;// helpers
;~ 	DLL_API unsigned DLL_CALLCONV FreeImage_GetMetadataCount(FREE_IMAGE_MDMODEL model, FIBITMAP *dib);
Func _FreeImage_GetMetadataCount($model, $pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_GetMetadataCount@8", $FREE_IMAGE_MDMODEL, $model, "ptr", $pDIB)
	If @error Then Return SetError(1, @error, 0)
	$pTag = $result[4]
	Return $result[0]
EndFunc   ;==>_FreeImage_GetMetadataCount
;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_CloneMetadata(FIBITMAP *dst, FIBITMAP *src);
Func _FreeImage_CloneMetadata($pDst, $pSrc)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_CloneMetadata@8", "ptr", $pDst, "ptr", $pSrc)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_CloneMetadata

;// tag to C string conversion
;~ 	DLL_API const char* DLL_CALLCONV FreeImage_TagToString(FREE_IMAGE_MDMODEL model, FITAG *tag, char *Make FI_DEFAULT(NULL));
Func _FreeImage_TagToString($model, $pTag, $make = 0)
	;Author: Prog@ndy
	Local $type = "ptr"
	If $make Then $type = "str"
	Local $result = DllCall($__g_hFREEIMAGEDLL, "str", "_FreeImage_TagToString@12", $FREE_IMAGE_MDMODEL, $model, "ptr", $pTag, $type, $make)
	If @error Then Return SetError(1, @error, "")
	Return $result[0]
EndFunc   ;==>_FreeImage_TagToString

;// --------------------------------------------------------------------------
;// Image manipulation toolkit -----------------------------------------------
;// --------------------------------------------------------------------------

;// rotation and flipping
;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_RotateClassic(FIBITMAP *dib, double angle);
Func _FreeImage_RotateClassic($pDIB, $angle)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_RotateClassic@12", "ptr", $pDIB, "double", $angle)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_RotateClassic

;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_Rotate(FIBITMAP *dib, double angle, const void *bkcolor FI_DEFAULT(NULL));
Func _FreeImage_Rotate($pDIB, $angle, $bkcolor = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Rotate@16", "ptr", $pDIB, "double", $angle, "ptr", $bkcolor)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Rotate

;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_RotateEx(FIBITMAP *dib, double angle, double x_shift, double y_shift, double x_origin, double y_origin, BOOL use_mask);
Func _FreeImage_RotateEx($pDIB, $angle, $x_shift, $y_shift, $x_origin, $y_origin, $use_mask)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_RotateEx@48", "ptr", $pDIB, "double", $angle, "double", $x_shift, "double ", $y_shift, "double", $x_origin, "double", $y_origin, "int", $use_mask)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_RotateEx

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FlipHorizontal(FIBITMAP *dib);
Func _FreeImage_FlipHorizontal($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FlipHorizontal@4", "ptr", $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FlipHorizontal

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_FlipVertical(FIBITMAP *dib);
Func _FreeImage_FlipVertical($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FlipVertical@4", "ptr", $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FlipVertical

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_JPEGTransform(const char *src_file, const char *dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect FI_DEFAULT(FALSE));
Func _FreeImage_JPEGTransform($src_file, $dst_file, $operation, $perfect = False);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_JPEGTransform@16", "str", $src_file, "str", $dst_file, $FREE_IMAGE_JPEG_OPERATION, $operation, "int", $perfect)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_JPEGTransform

;~ DLL_API BOOL DLL_CALLCONV FreeImage_JPEGTransformU(const wchar_t *src_file, const wchar_t *dst_file, FREE_IMAGE_JPEG_OPERATION operation, BOOL perfect FI_DEFAULT(FALSE));
Func _FreeImage_JPEGTransformU($src_file, $dst_file, $operation, $perfect = False);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_JPEGTransformU@16", "wstr", $src_file, "wstr", $dst_file, $FREE_IMAGE_JPEG_OPERATION, $operation, "int", $perfect)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_JPEGTransformU

;// upsampling / downsampling
;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_Rescale(FIBITMAP *dib, int dst_width, int dst_height, FREE_IMAGE_FILTER filter);
Func _FreeImage_Rescale($pDIB, $dst_width, $dst_height, $filter)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Rescale@16", "ptr", $pDIB, "int", $dst_width, "int", $dst_height, $FREE_IMAGE_FILTER, $filter)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Rescale

;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_MakeThumbnail(FIBITMAP *dib, int max_pixel_size, BOOL convert FI_DEFAULT(TRUE));
Func _FreeImage_MakeThumbnail($pDIB, $max_pixel_size, $convert = True)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_MakeThumbnail@12", "ptr", $pDIB, "int", $max_pixel_size, "int", $convert)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_MakeThumbnail


;// color manipulation routines (point operations)
;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_AdjustCurve(FIBITMAP *dib, BYTE *LUT, FREE_IMAGE_COLOR_CHANNEL channel);
Func _FreeImage_AdjustCurve($pDIB, $pLUT, $channel)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_AdjustCurve@12", "ptr", $pDIB, "ptr", $pLUT, $FREE_IMAGE_COLOR_CHANNEL, $channel)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AdjustCurve

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_AdjustGamma(FIBITMAP *dib, double gamma);
Func _FreeImage_AdjustGamma($pDIB, $gamma)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_AdjustGamma@12", "ptr", $pDIB, "double", $gamma)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AdjustGamma

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_AdjustBrightness(FIBITMAP *dib, double percentage);
Func _FreeImage_AdjustBrightness($pDIB, $percentage)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_AdjustBrightness@12", "ptr", $pDIB, "double", $percentage)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AdjustBrightness

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_AdjustContrast(FIBITMAP *dib, double percentage);
Func _FreeImage_AdjustContrast($pDIB, $percentage)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_AdjustContrast@12", "ptr", $pDIB, "double", $percentage)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AdjustContrast

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_Invert(FIBITMAP *dib);
Func _FreeImage_Invert($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_Invert@4", "ptr", $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Invert

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_GetHistogram(FIBITMAP *dib, DWORD *histo, FREE_IMAGE_COLOR_CHANNEL channel FI_DEFAULT(FICC_BLACK));
Func _FreeImage_GetHistogram($pDIB, $histo, $channel = $FICC_BLACK)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_Invert@12", "ptr", $pDIB, "ptr", $histo, $FREE_IMAGE_COLOR_CHANNEL, $channel)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetHistogram

;~ 	DLL_API int DLL_CALLCONV FreeImage_GetAdjustColorsLookupTable(BYTE *LUT, double brightness, double contrast, double gamma, BOOL invert);
Func _FreeImage_GetAdjustColorsLookupTable($pLUT, $brightness, $contrast, $gamma, $invert)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_Invert@32", "ptr", $pLUT, "double", $brightness, "double", $contrast, "double", $gamma, "int", $invert)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetAdjustColorsLookupTable

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_AdjustColors(FIBITMAP *dib, double brightness, double contrast, double gamma, BOOL invert FI_DEFAULT(FALSE));
Func _FreeImage_AdjustColors($pDIB, $brightness, $contrast, $gamma, $invert = False)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_AdjustColors@32", "ptr", $pDIB, "double", $brightness, "double", $contrast, "double", $gamma, "int", $invert)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AdjustColors

;~ 	DLL_API unsigned DLL_CALLCONV FreeImage_ApplyColorMapping(FIBITMAP *dib, RGBQUAD *srccolors, RGBQUAD *dstcolors, unsigned count, BOOL ignore_alpha, BOOL swap);
Func _FreeImage_ApplyColorMapping($pDIB, $srccolors, $dstcolors, $count, $ignore_alpha, $swap);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_AdjustColors@24", "ptr", $pDIB, "ptr", $srccolors, "ptr", $dstcolors, "uint", $count, "int", $ignore_alpha, "int", $swap);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ApplyColorMapping

;~ 	DLL_API unsigned DLL_CALLCONV FreeImage_SwapColors(FIBITMAP *dib, RGBQUAD *color_a, RGBQUAD *color_b, BOOL ignore_alpha);
Func _FreeImage_SwapColors($pDIB, $color_a, $color_b, $ignore_alpha)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_SwapColors@16", "ptr", $pDIB, "ptr", $color_a, "ptr", $color_b, "int", $ignore_alpha);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SwapColors

;~ 	DLL_API unsigned DLL_CALLCONV FreeImage_ApplyPaletteIndexMapping(FIBITMAP *dib, BYTE *srcindices,	BYTE *dstindices, unsigned count, BOOL swap);
Func _FreeImage_ApplyPaletteIndexMapping($pDIB, $srcindices, $dstindices, $count, $swap);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_ApplyPaletteIndexMapping@20", "ptr", $pDIB, "ptr", $srcindices, "ptr", $dstindices, "uint", $count, "int", $swap);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_ApplyPaletteIndexMapping

;~ 	DLL_API unsigned DLL_CALLCONV FreeImage_SwapPaletteIndices(FIBITMAP *dib, BYTE *index_a, BYTE *index_b);
Func _FreeImage_SwapPaletteIndices($pDIB, $index_a, $index_b);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "uint", "_FreeImage_ApplyPaletteIndexMapping@12", "ptr", $pDIB, "byte*", $index_a, "byte*", $index_b);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SwapPaletteIndices


;// channel processing routines
;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_GetChannel(FIBITMAP *dib, FREE_IMAGE_COLOR_CHANNEL channel);
Func _FreeImage_GetChannel($pDIB, $channel);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetChannel@8", "ptr", $pDIB, $FREE_IMAGE_COLOR_CHANNEL, $channel);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetChannel

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetChannel(FIBITMAP *dib, FIBITMAP *dib8, FREE_IMAGE_COLOR_CHANNEL channel);
Func _FreeImage_SetChannel($pDIB, $pDIB8, $channel);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetChannel@12", "ptr", $pDIB, "ptr", $pDIB8, $FREE_IMAGE_COLOR_CHANNEL, $channel);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetChannel

;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_GetComplexChannel(FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
Func _FreeImage_GetComplexChannel($pDIB, $channel);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_GetComplexChannel@8", "ptr", $pDIB, $FREE_IMAGE_COLOR_CHANNEL, $channel);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_GetComplexChannel

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_SetComplexChannel(FIBITMAP *dst, FIBITMAP *src, FREE_IMAGE_COLOR_CHANNEL channel);
Func _FreeImage_SetComplexChannel($pDst, $pSrc, $channel);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_SetComplexChannel@12", "ptr", $pDst, "ptr", $pSrc, $FREE_IMAGE_COLOR_CHANNEL, $channel);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_SetComplexChannel


;// copy / paste / composite routines
;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_Copy(FIBITMAP *dib, int left, int top, int right, int bottom);
Func _FreeImage_Copy($pDIB, $left, $top, $right, $bottom);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Copy@20", "ptr", $pDIB, "int", $left, "int", $top, "int", $right, "int", $bottom);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Copy

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_Paste(FIBITMAP *dst, FIBITMAP *src, int left, int top, int alpha);
Func _FreeImage_Paste($pDst, $pSrc, $left, $top, $alpha);
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Paste@20", "ptr", $pDst, "ptr", $pSrc, "int", $left, "int", $top, "int", $alpha);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Paste

;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_Composite(FIBITMAP *fg, BOOL useFileBkg FI_DEFAULT(FALSE), RGBQUAD *appBkColor FI_DEFAULT(NULL), FIBITMAP *bg FI_DEFAULT(NULL));
Func _FreeImage_Composite($pFg, $useFileBkg = False, $appBkColor = 0, $pBg = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_Composite@16", "ptr", $pFg, "int", $useFileBkg, "ptr", $appBkColor, "ptr", $pBg);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_Composite

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_JPEGCrop(const char *src_file, const char *dst_file, int left, int top, int right, int bottom);
Func _FreeImage_JPEGCrop($src_file, $dst_file, $left, $top, $right, $bottom)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_JPEGCrop@24", "str", $src_file, "str", $dst_file, "int", $left, "int", $top, "int", $right, "int", $bottom);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_JPEGCrop

;~ DLL_API BOOL DLL_CALLCONV FreeImage_JPEGCropU(const wchar_t *src_file, const wchar_t *dst_file, int left, int top, int right, int bottom);
Func _FreeImage_JPEGCropU($src_file, $dst_file, $left, $top, $right, $bottom)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_JPEGCropU@24", "wstr", $src_file, "wstr", $dst_file, "int", $left, "int", $top, "int", $right, "int", $bottom);
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_JPEGCropU

;~ 	DLL_API BOOL DLL_CALLCONV FreeImage_PreMultiplyWithAlpha(FIBITMAP *dib);
Func _FreeImage_PreMultiplyWithAlpha($pDIB)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_PreMultiplyWithAlpha@4", "ptr", $pDIB)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_PreMultiplyWithAlpha


;~ // background filling routines
;~ #CS
;~ DLL_API BOOL DLL_CALLCONV FreeImage_FillBackground(FIBITMAP *dib, const void *color, int options FI_DEFAULT(0));
Func _FreeImage_FillBackground($pDIB, $color, $options = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "int", "_FreeImage_FillBackground@12", "ptr", $pDIB, "ptr", $color, "int", $options)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_FillBackground
;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_EnlargeCanvas(FIBITMAP *src, int left, int top, int right, int bottom, const void *color, int options FI_DEFAULT(0));
Func _FreeImage_EnlargeCanvas($pDIB, $left, $top, $right, $bottom, $color, $options = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_EnlargeCanvas@28", "ptr", $pDIB, "int", $left, "int", $top, "int", $right, "int", $bottom, "ptr", $color, "int", $options)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_EnlargeCanvas
;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_AllocateEx(int width, int height, int bpp, const RGBQUAD *color, int options FI_DEFAULT(0), const RGBQUAD *palette FI_DEFAULT(NULL), unsigned red_mask FI_DEFAULT(0), unsigned green_mask FI_DEFAULT(0), unsigned blue_mask FI_DEFAULT(0));
Func _FreeImage_AllocateEx($width, $height, $bpp, $color, $options = 0, $palette = 0, $red_mask = 0, $green_mask = 0, $blue_mask = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_AllocateEx@36", "int", $width, "int", $height, "int", $bpp, "ptr", $color, "int", $options, "ptr", $palette, "uint", $red_mask, "uint", $green_mask, "uint", $blue_mask)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AllocateEx
;~ DLL_API FIBITMAP *DLL_CALLCONV FreeImage_AllocateExT(FREE_IMAGE_TYPE type, int width, int height, int bpp, const void *color, int options FI_DEFAULT(0), const RGBQUAD *palette FI_DEFAULT(NULL), unsigned red_mask FI_DEFAULT(0), unsigned green_mask FI_DEFAULT(0), unsigned blue_mask FI_DEFAULT(0));
Func _FreeImage_AllocateExT($type, $width, $height, $bpp, $color, $options = 0, $palette = 0, $red_mask = 0, $green_mask = 0, $blue_mask = 0)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_AllocateExT@40", $FREE_IMAGE_TYPE, $type, "int", $width, "int", $height, "int", $bpp, "ptr", $color, "int", $options, "ptr", $palette, "uint", $red_mask, "uint", $green_mask, "uint", $blue_mask)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_AllocateExT
;~ #CE


;// miscellaneous algorithms
;~ 	DLL_API FIBITMAP *DLL_CALLCONV FreeImage_MultigridPoissonSolver(FIBITMAP *Laplacian, int ncycle FI_DEFAULT(3));
Func _FreeImage_MultigridPoissonSolver($pDIB, $ncycle = 3)
	;Author: Prog@ndy
	Local $result = DllCall($__g_hFREEIMAGEDLL, "ptr", "_FreeImage_MultigridPoissonSolver@8", "ptr", $pDIB, "int", $ncycle)
	If @error Then Return SetError(1, @error, 0)
	Return $result[0]
EndFunc   ;==>_FreeImage_MultigridPoissonSolver

;~ ;// restore the borland-specific enum size option
;~ #if defined(__BORLANDC__)
;~ #pragma option pop
;~ #endif

;~ #ifdef __cplusplus
;~ }
;~ #endif

;~ #endif // FREEIMAGE_H