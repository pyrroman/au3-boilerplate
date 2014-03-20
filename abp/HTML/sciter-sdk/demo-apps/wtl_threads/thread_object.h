
#pragma once

#include <vector>
#include "tiscript.hpp"
#include "sciter-x-script.h"
#include "sciter-x-queue.h" // for the event, mutex, etc.

// Worker thread capsule
class worker_thread
{
protected:
  friend class async_call;

  std::wstring              task_name; // name of the thread used for reporting purposes
  std::vector<json::value>  argv; // vector of initial thread parameters, thread safe
  volatile bool             stop_rq; 
  volatile bool             stopped; 
  volatile tiscript::value  self;
  tiscript::VM*             vm;

  void                      run() { exec(); stopped = true; }
  static DWORD WINAPI       _thread_proc( LPVOID pparam ){ static_cast<worker_thread*>(pparam)->run(); return 0; }

public:
  worker_thread(): 
    self(0), vm(0),
    stop_rq(false),
    stopped(true) 
    {
    }

  void attach(tiscript::VM* pvm, tiscript::value thread_obj)
  {
    self = thread_obj;
      vm = pvm;
  }

  virtual ~worker_thread() { finalize();  }
  virtual void finalize() 
  {
     vm = 0;
     self = 0;
     stop();
  }

  void on_gc(tiscript::value new_self) { self = new_self; }

  bool start( std::vector<json::value>& argv );
  void stop() { if(!stopped) { stop_rq = true; sciter::yield(); } }

  bool         running() const { return !stopped; }
  std::wstring name() const { return task_name; }
  void         name(std::wstring n) { task_name = n; }

  bool is_alive() const { return (!stop_rq) && vm && self; }
  
  virtual void exec() = 0;

  // asynchronous callback, fire-n-forget, called from worker thread.
  void        post( const std::string& method, unsigned argc = 0,const json::value* argv = 0 );
  // synchronous callback, fire-n-wait-until-processed, called from worker thread.
  json::value send( const std::string& method, unsigned argc = 0,const json::value* argv = 0 );
};

class async_call
{
public:
   worker_thread*            wthread;
   std::string               method_name;
   std::vector<json::value>  argv;
   json::value               retval;
   
   async_call(worker_thread* wt, const std::string& method, unsigned argc = 0,const json::value* args = 0)
   {
     wthread = wt;
     method_name = method;
     for( unsigned n = 0; n < argc; ++n )
       argv.push_back(args[n]);
   }
   virtual void done() { delete this; }

   static void TISAPI callback(tiscript::VM *vm,void* prm) // executed in context of VM thread
   {
     async_call* call = static_cast<async_call*>(prm);
     if( call->argv.size() )
       SciterCall_V(vm, call->wthread->self, call->method_name.c_str(), &call->argv[0], call->argv.size(), &call->retval);
     else
       SciterCall_V(vm, call->wthread->self, call->method_name.c_str(), 0, 0, &call->retval);
     /*else
       assert! not found!*/
     call->done();
   }
};

class sync_call: public async_call
{
  sciter::event is_done;
public:
  sync_call(worker_thread* wt, const std::string& method, unsigned argc = 0,const json::value* args = 0):
      async_call(wt, method, argc,args) {}

  virtual void done() { is_done.signal(); }
  void wait()         { is_done.wait(); }
};

inline void  worker_thread::post( const std::string& method, unsigned argc, const json::value* argv )
{
  if(!vm)
    return;
  async_call* nc = new async_call(this,method,argc,argv);
  tiscript::post(vm, async_call::callback, nc);
  sciter::yield(); 
}

inline json::value worker_thread::send( const std::string& method, unsigned argc, const json::value* argv )
{
  if(!vm)
    return json::value();
  sync_call* nc = new sync_call(this,method,argc,argv);
  tiscript::post(vm, async_call::callback, (async_call*)nc);
  nc->wait();
  json::value rv = nc->retval;
  delete nc;
  return rv;
}

inline bool worker_thread::start(std::vector<json::value>& argv)
{
  if( !stopped )
    return false;

  this->argv.clear();
  this->argv.swap(argv);
  
  HANDLE h = CreateThread(NULL,0,_thread_proc,this,CREATE_SUSPENDED,0);
  if( h )
  {
    stopped = false;
    stop_rq = false;
    ResumeThread(h);
    return true;
  }
  return false;
}
