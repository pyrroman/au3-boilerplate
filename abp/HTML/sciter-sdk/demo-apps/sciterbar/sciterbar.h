#ifndef __sciterbar_h__
#define __sciterbar_h__

#include "sciter-x-script.h"
#include "sciterbarhook.h"

extern  void      SetBarSide(DOCK_SIDE side);
extern  DOCK_SIDE GetBarSide();

extern  void          SetBarAnimationTime(unsigned int milliseconds);
extern  unsigned int  GetBarAnimationTime();

#endif
