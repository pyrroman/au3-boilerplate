#include '7Zip.au3'
#include <Array.au3>

$sArcName = 'ZipExample.zip'

$aFlist = _7ZipGetFilesList(0, $sArcName)
_ArrayDisplay($aFlist)
