#ifndef __SCITER_QUEUE_H__
#define __SCITER_QUEUE_H__

/*
 * The Sciter Engine
 * http://terrainformatica.com/sciter
 * 
 * Asynchronous GUI Task Queue.
 * Use these primitives when you need to run code in GUI thread.
 * 
 * The code and information provided "as-is" without
 * warranty of any kind, either expressed or implied.
 * 
 * 
 * (C) 2003-2006, Andrew Fedoniouk (andrew@terrainformatica.com)
 */

/*!\file
\brief Asynchronous GUI Task Queue
*/
#include <windows.h>
#include <stdio.h>
#include <assert.h>

#if defined(__cplusplus) && !defined( PLAIN_API_ONLY )

namespace sciter 
{
  class mutex 
  { 
    CRITICAL_SECTION cs;
 public:
    void lock()     { EnterCriticalSection(&cs); } 
    void unlock()   { LeaveCriticalSection(&cs); } 
    mutex()         { InitializeCriticalSection(&cs); }   
    ~mutex()        { DeleteCriticalSection(&cs); }
  };
  
  class critical_section { 
    mutex& m;
  public:
    critical_section(mutex& guard) : m(guard) { m.lock(); }
    ~critical_section() { m.unlock(); }
  };

  struct event
  {
    HANDLE h;
    event()       { h = CreateEvent(NULL, FALSE, FALSE, NULL);  }
    ~event()      { CloseHandle(h); }
    void signal() { SetEvent(h); }
    void wait()   { WaitForSingleObject(h, INFINITE); }
  };

  inline void yield() { Sleep(0); }

  template <typename BASE> class queue;

  // derive your own tasks from this and implement your own exec()
template <typename BASE>
  class gui_task 
  {
    template <typename BASE> friend class queue;
  protected:
    gui_task* next;
  public:
    gui_task(): next(0) {}
    virtual ~gui_task() {}
    virtual void exec(BASE* pb) = 0; // override it 
  };

  // main window of each thread should be derived from this
  
template <typename BASE>
  class queue
  { 
    gui_task<BASE>* head;
    gui_task<BASE>* tail;
    mutex           guard;
  
  public:
    queue():head(0),tail(0) {}
    ~queue() { clear(); }
    void push( gui_task<BASE>* new_task ) { _push(new_task); }
    // Place execute() call inside WM_NULL handler of the WndProc.
    void execute() { _execute(); }
    void clear() { _clear(); }
    bool is_empty() { return _is_empty(); }

  private:

    void _push( gui_task<BASE>* new_task )
    {
      assert(new_task);
      bool pending = false;
      {
        critical_section cs(guard);
        if( tail )
        {
          tail->next = new_task;
          pending = true;
        }
        else
          head = new_task;
        tail = new_task;
      }
      if(!pending)
        PostMessage(static_cast< BASE* >(this)->get_hwnd(), WM_NULL, 0,0);
    }
        
    // Place this call after GetMessage()/PeekMessage() in main loop
    void _execute()
    {
      gui_task<BASE>* next;
      while(next = pop())
      {
        next->exec(static_cast< BASE* >(this)); // do it
        delete next;
      }
    }
    
    void _clear()
    {
      gui_task<BASE>* next;
      while(next = pop())
        delete next;
    }
    bool _is_empty() const
    { 
      return head == 0; 
    }

    gui_task<BASE>* pop()
    {
      critical_section cs(guard);
      if( !head ) return 0;
      
      gui_task<BASE>* t = head; 
      head = head->next;
      if( !head ) tail = 0;
      return t;
    }
  
  };
}

#endif // __cplusplus

#endif // __SCITER_QUEUE_H__
