#include "stdafx.h"

#include "tiscript.hpp"
#include "thread_object.h"

// This file defines [worker] Thread object for the script.

const char *CLASSNAME = "Thread";

using namespace tiscript;

extern worker_thread* worker_thread_factory(const std::wstring& task_name);

inline worker_thread * self(value obj)
{
  return (worker_thread*) get_native_data(obj);
}

// Thread.create - threead factory
// Thread.create(name:string, args.. )
value Thread_create(VM* vm)
{
  std::wstring     thread_name;
  value            klass;
  try
  {
    args(vm) >> klass // 'class'
             >> args::skip // skip 'super'
             >> thread_name;
  } 
  catch (args::error &e) { throw_error(vm, e.msg()); return v_null(); }

  worker_thread* pth = worker_thread_factory(thread_name);
  if(!pth)
  {
    throw_error(vm, L"cannot create task with such name");
    return v_null();
  }
  value obj = create_object(vm,klass);
  set_native_data(obj,pth);
  pth->name(thread_name);
  pth->attach(vm,obj);
  return obj;
}

// thread.start(argv..) 
value Thread_start(VM* vm)
{
  value obj;
  
  args arguments(vm);

  arguments >> obj;       // 'this' variable. 

  worker_thread* pth = self(obj);
  if(!pth)
    return v_bool(false);

  std::vector<json::value> argv;

  for( int n = 2; n < arguments.length(); ++n )
  {
    json::value v = sciter::v2v(vm,arguments.get(n)) ;
    argv.push_back( v );
  }
  pth->start(argv);
  return v_bool(true);
}


// thread.stop() request
value Thread_stop(VM* vm)
{
  value obj;
  
  args(vm) >>  obj;       // 'this' variable. 

  worker_thread* pth = self(obj);
  if(pth)
    pth->stop();
 
  return v_undefined();
}

static value Thread_get_valid(VM *vm, value obj)
{
  worker_thread* pth = self(obj);
  return v_bool( pth != 0 );
}

static value Thread_get_state(VM *vm, value obj)
{
  worker_thread* pth = self(obj);
  if(pth)
    return pth->running()? v_symbol("running"):v_symbol("stopped");
  return v_undefined();
}

static value Thread_get_name(VM *vm, value obj)
{
  worker_thread* pth = self(obj);
  if(pth)
    return v_string(vm,pth->name().c_str());
  return v_undefined();
}

void  TISAPI Thread_on_gc_copy(void* instance_data, tiscript_value new_self)
{
  worker_thread* pth = (worker_thread*)instance_data;
  pth->on_gc(new_self);
}

void  TISAPI Thread_finalize(tiscript_VM *c,tiscript_value obj)
{
  worker_thread* pth = self(obj);
  //normally we should call delete pth; here
  if( pth )
  {
    pth->finalize();
  }
}


void init_Thread_class( VM *vm )
{
  static method_def methods[] = 
  {
    method_def("create", Thread_create),
    method_def("start",  Thread_start),
    method_def("stop",   Thread_stop),
    method_def() // zero terminated
  };
  
  static prop_def properties[] = 
  {
    prop_def("state",    Thread_get_state, 0),
    prop_def("valid",    Thread_get_valid, 0),
    prop_def("name",     Thread_get_name, 0),
    prop_def()  // zero terminated
  };
  
  static const_def consts[] =
  {
    const_def() // zero terminated
  };

  static class_def clazz = 
  {
    CLASSNAME,
    methods,
    properties,
    consts,
    0,
    0,
    Thread_finalize,
    0,
    Thread_on_gc_copy,
  };
  define_class(vm, &clazz, get_current_ns(vm) );
}

