#include "stdafx.h"
#include "thread_object.h"

// factory that creates worker threads for us  
worker_thread* worker_thread_factory(const std::wstring& task_name);

class find_file_thread: public worker_thread
{
public:

  virtual void exec()
  {
    post("started"); // notify the UI that we are up and running
    if( argv.size() >= 1 && argv[0].is_string() )
      scan_folder(argv[0].get(L""),argv[1].get(L"*.*"));
    post("done"); // notify the UI that we have done with this
  }

  void notify_ui(const wchar_t* folder_path, const WIN32_FIND_DATA& ffd) 
  {
    json::value v; 
    v["path"]       = json::value( folder_path );
    v["name"]       = json::value( ffd.cFileName );
    v["attributes"] = json::value( (int)ffd.dwFileAttributes );
    v["sizeLow"]    = json::value( (int)ffd.nFileSizeLow );
    v["sizeHigh"]   = json::value( (int)ffd.nFileSizeHigh );
    v["created"]    = json::value::date( ffd.ftCreationTime );
    v["accessed"]   = json::value::date( ffd.ftLastAccessTime );
    v["modified"]   = json::value::date( ffd.ftLastWriteTime );
    // all above is pretty depressing way of saying just this:
    //   v = { path:string, name: string, ... };
    send("found",1,&v); // send this stuff to our UI, this will end up in a call of thread.found() method in script.
  }
  void scan_folder( const wchar_t* path, const wchar_t* mask)
  {
    WIN32_FIND_DATAW ffd;
    std::wstring to_scan = path;
    if(to_scan.length() && to_scan[to_scan.length() - 1] != '\\')
      to_scan += L"\\";
    to_scan += mask;
    HANDLE h = FindFirstFileW(to_scan.c_str(),&ffd);
    if( h == INVALID_HANDLE_VALUE ) return;
    do 
    {
      if( !is_alive() )
        break; // got stop rq or object was GCed
      notify_ui(path,ffd);
      if( ffd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY )
      {
        if(wcscmp(ffd.cFileName, L".") != 0 &&
           wcscmp(ffd.cFileName, L"..") != 0)
        {
          std::wstring np = path;
          np += L"\\";
          np += ffd.cFileName;
          scan_folder(np.c_str(), mask);
        }
      }
    } while(FindNextFileW(h,&ffd));
  }
};

worker_thread* worker_thread_factory(const std::wstring& task_name)
{
  if( task_name == L"find-file" )
    return new find_file_thread();
  return 0;
}


