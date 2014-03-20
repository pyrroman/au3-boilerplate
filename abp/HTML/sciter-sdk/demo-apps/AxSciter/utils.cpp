#include "stdafx.h"

json::value VAR2val(const VARIANT& tv)
{
    json::value rv;
    switch(tv.vt)
    {
      case VT_UI1:            { int v = tv.cVal;    rv = json::value(v); } break; 
      case VT_I2:             { int v = tv.iVal;    rv = json::value(v); } break;
      case VT_I4:             { int v = tv.lVal;    rv = json::value(v); } break;
      case VT_UI1 | VT_BYREF: { int v = *tv.pcVal;  rv = json::value(v); } break;
      case VT_I2 | VT_BYREF:  { int v = *tv.piVal;  rv = json::value(v); } break;
      case VT_I4 | VT_BYREF:  { int v = *tv.plVal;  rv = json::value(v); } break;

      case VT_R4:             { double v = tv.fltVal; rv = json::value(v); } break;
      case VT_R4 | VT_BYREF:  { double v = *tv.pfltVal; rv = json::value(v); } break;
      case VT_R8:             { double v = tv.dblVal; rv = json::value(v); } break;
      case VT_R8 | VT_BYREF:  { double v = *tv.pdblVal; rv = json::value(v); } break;

      case VT_BOOL:           { bool v = tv.boolVal != 0; rv = json::value(v); } break;
      case VT_BOOL | VT_BYREF:{ bool v = *tv.pboolVal != 0; rv = json::value(v); } break;

      case VT_BSTR:           { LPCWSTR v = tv.bstrVal; rv = json::value(v); } break;
      case VT_BSTR | VT_BYREF:{ LPCWSTR v = *tv.pbstrVal; rv = json::value(v); } break;

      case VT_BYREF | VT_VARIANT: return VAR2val(*tv.pvarVal);
    }
    return rv;
}

VARIANT val2VAR(const json::value& tv)
{
    VARIANT rv;
    VariantInit(&rv);

    switch(tv.t)
    {
      case T_UNDEFINED:
        break;
      case T_BOOL:
        rv.vt = VT_BOOL;
        rv.boolVal = tv.get(false)?TRUE:FALSE;
        break;
      case T_INT:
        rv.vt = VT_I4;
        rv.lVal = tv.get(0);
        break;
      case T_FLOAT:
        rv.vt = VT_R8;
        rv.dblVal = tv.get(0.0);
        break;
      case T_STRING:
        {
        aux::wchars s = tv.get_chars();
        rv.vt = VT_BSTR;        
        rv.bstrVal = SysAllocStringLen(s.start, s.length);
        } break;
      //case json::value::V_ARRAY:
      //case json::value::V_MAP:
      default: assert(false);
    }
    return rv;
}
