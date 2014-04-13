#ifndef __tiscript_streams_hpp__
#define __tiscript_streams_hpp__

#include "tiscript.h"
#include <string>

namespace tiscript 
{

  class stream: public tiscript_stream 
  {
    public:
      stream() 
      { 
        static tiscript_stream_vtbl methods = { _stream_input, _stream_output, _stream_name, _stream_close };
        _vtbl = &methods;
      }
      virtual ~stream()       { close(); } 

      // these need to be overrided 
      virtual const wchar_t* stream_name() { return L""; }
      virtual int  get()      { return -1; }
      virtual bool put(int v) { v; return false; }
      virtual void close()    {} 
      
    protected:
      inline static bool TISAPI _stream_input(tiscript_stream* tag, int* pv)
        { *pv = static_cast<stream*>(tag)->get(); return *pv >= 0; }
      inline static bool TISAPI _stream_output(tiscript_stream* tag, int v)
        { return static_cast<stream*>(tag)->put(v); }
      inline static const wchar* TISAPI _stream_name(tiscript_stream* tag)
        { return static_cast<stream*>(tag)->stream_name(); }
      inline static void TISAPI _stream_close(tiscript_stream* tag)
        { static_cast<stream*>(tag)->close(); }
  };    
  
  // various stream implementations
  class string_istream: public stream
  {
    const wchar* _pos;  const wchar* _end;
  public:
    string_istream(const wchar* str, unsigned length = 0): _pos(str),_end(str) { if(length == 0) length = (unsigned int)wcslen(str); _end = _pos + length; }
    virtual int get() { return (*_pos && _pos < _end)? *_pos++ : -1; }
  };
  
  class string_ostream: public stream
  {
    wchar *_str, *_p, *_end;
  public:
    string_ostream() { _p = _str = (wchar*)malloc( 128 * sizeof(wchar) ); _end = _str + 128; }
    virtual bool put(int v) 
    {
      if( _p >= _end )
      {
        size_t sz = _end - _str; size_t nsz = (sz * 2) / 3; if( nsz < 128 ) nsz = 128;
        wchar *nstr = (wchar*)realloc(_str, nsz * sizeof(wchar));
        if(!nstr) return false;
        _str = nstr; _p = _str + sz; _end = _str + nsz;
      }
      *_p++ = v;
      return true; 
    }
    const wchar *c_str() { put(0); --_p; return _str; }    
    virtual void close() { if(_str) { free(_str); _str = _p = _end = 0; } }     
  };  
  
  // simple file input stream. 
  class file_istream: public stream
  {
    FILE*        _file;  
    std::wstring _name;
  public:
    file_istream(const wchar_t* filename) {  _file = _wfopen(filename,L"rb"); _name = filename; }
    virtual void close() { if(_file) {fclose(_file);_file = 0;} }

    virtual const wchar_t* stream_name() { return _name.c_str(); }

    virtual int get() 
    { 
      if(!_file || feof(_file)) return -1;
      return fgetc(_file);
    }
    bool is_valid() const { return _file != 0; }
  };

  inline wchar oem2wchar(char c)
  {
    wchar wc = '?';
    MultiByteToWideChar(CP_OEMCP,0,&c,1,&wc,1);
    return wc;
  }
  inline char wchar2oem(wchar wc)
  {
    char c = '?';
    WideCharToMultiByte(CP_OEMCP,0,&wc,1,&c,1,0,0);
    return c;
  }
  class console: public stream 
  {
  public:
    virtual int  get() { int c = getchar(); return c != EOF? oem2wchar(c) : -1; }      
    virtual bool put(int v) 
    { 
      return putchar( wchar2oem(v) ) != EOF; 
    }
  };
  
  
}


#endif