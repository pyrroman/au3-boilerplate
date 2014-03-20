#ifndef __sciterbarhook_h__
#define __sciterbarhook_h__

enum DOCK_SIDE
{
  DOCK_LEFT, 
  DOCK_RIGHT,
  DOCK_SIDE_MAX,
};

#define WM_REPAINT (WM_APP + 0)
#define WM_SHOW_SIDEBAR (WM_APP + 2)
#define WM_HIDE_SIDEBAR (WM_APP + 3)

typedef BOOL (*SetHookFunc)(HWND hwnd, DOCK_SIDE side);
typedef VOID (*SetSideFunc)(DOCK_SIDE side);


#endif