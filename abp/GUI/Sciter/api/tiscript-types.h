#ifndef __tis_types_hpp__
#define __tis_types_hpp__

#include <wchar.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#ifdef WIN64
  #define X64BITS
#endif

#ifdef __GNUC__
  typedef unsigned short      word;
  typedef unsigned long       dword;
  typedef unsigned long long  qword;
  typedef wchar_t             wchar;
  typedef long long           int64;
  typedef unsigned long long  uint64;
#else
  typedef unsigned __int16    word;
  typedef unsigned __int32    dword;
  typedef unsigned __int64    qword;
  typedef wchar_t             wchar;
  typedef __int64             int64;
  typedef unsigned __int64    uint64;
#endif

  typedef long                int32;
  typedef unsigned long       uint32;
  typedef float               float32;
  typedef signed char         int8;
  typedef short               int16;
  typedef unsigned short      uint16;
  typedef double              float64;

  typedef unsigned char       byte;
  typedef unsigned int        uint;
  typedef unsigned short      ushort;

#if defined(X64BITS)
  typedef uint64              uint_ptr;
  typedef int64               int_ptr;
#else
  typedef unsigned int        uint_ptr;
  typedef int                 int_ptr;
#endif


namespace cvt
{
  // helper convertor objects wchar_t to ACP and vice versa
  class w2a
  {
    char* buffer;
  public:
    explicit w2a(const wchar_t* wstr):buffer(0)
    {
      if(wstr)
      {
        size_t nu = wcslen(wstr);
        size_t n = wcstombs(0,wstr,nu);
        buffer = new char[n+1];
        wcstombs(buffer,wstr,nu);
        buffer[n] = 0;
      }
    }
    ~w2a() {  delete[] buffer;  }
    operator const char*() { return buffer; }
  };

  class a2w
  {
    wchar_t* buffer;
  public:
    explicit a2w(const char* str):buffer(0)
    {
      if(str)
      {
        size_t n = strlen(str);
        size_t nu = mbstowcs(0,str,n);
        buffer = new wchar_t[n+1];
        mbstowcs(buffer,str,n);
        buffer[nu] = 0;
      }
    }
    ~a2w() {  delete[] buffer;  }
    operator const wchar_t*() { return buffer; }

  };


  /** Integer to string converter.
      Use it as ostream << itoa(234)
  **/
  class itoa
  {
    char buffer[38];
  public:
    itoa(int n, int radix = 10)
    {
#if defined(WIN32) || defined(WINCE)
      _itoa( n, buffer, radix );
#else 
      sprintf(buffer, "%d",n);
#endif
    }
    operator const char*() { return buffer; }
  };

  /** Integer to wstring converter.
      Use it as wostream << itow(234)
  **/

  class itow
  {
    wchar_t buffer[38];
  public:
    itow(int n, int radix = 10)
    {
#if defined(WIN32) || defined(UNDER_CE)
      _itow( n, buffer, radix );
#else 
      swprintf(buffer, 38, L"%d",n);
#endif
    }
    operator const wchar_t*() { return buffer; }
  };

  /** Float to string converter.
      Use it as ostream << ftoa(234.1); or
      Use it as ostream << ftoa(234.1,"pt"); or
  **/
  class ftoa
  {
    char buffer[64];
  public:
    ftoa(double d, const char* units = "", int fractional_digits = 1)
    {
      sprintf(buffer, "%.*f%s", fractional_digits, d, units );
      buffer[63] = 0;
    }
    operator const char*() { return buffer; }
  };

  /** Float to wstring converter.
      Use it as wostream << ftow(234.1); or
      Use it as wostream << ftow(234.1,"pt"); or
  **/
  class ftow
  {
    wchar_t buffer[64];
  public:
    ftow(double d, const wchar_t* units = L"", int fractional_digits = 1)
    {
#if defined(WIN32) || defined(UNDER_CE)
      _snwprintf(buffer, 64, L"%.*f%s", fractional_digits, d, units );
#else
      swprintf(buffer, 64, L"%.*f%s", fractional_digits, d, units );
#endif
      buffer[63] = 0;
    }
    operator const wchar_t*() { return buffer; }
  };

 /** wstring to integer parser.
  **/
  inline int wtoi(const wchar_t *s, int default_value = 0)
  {
    if( !s ) return default_value;
    wchar_t *lastptr;
    long i = wcstol( s, &lastptr, 10 );
    return (lastptr != s)? (int)i : default_value;
  }

/** string to integer parser.
  **/
   inline int atoi(const char *s, int default_value = 0)
  {
    if( !s ) return default_value;
    char *lastptr;
    long i = strtol( s, &lastptr, 10 );
    return (lastptr != s)? (int)i : default_value;
  }
}

#endif
