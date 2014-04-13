#include <GUIConstantsEx.au3>
#include <Sciter-UDF.au3>

_StStartup()

$Gui = GUICreate("Form1", 800, 600, -1, -1)
GUISetState(@SW_SHOW)
$ST = _StincGui($Gui,0,0,500,600)
$ST2 = _StincGui($Gui,510,0,280,200)
_StLoadHtml($ST,'<html><body><h1>Exemple</h1><p>this is an exemple of functions in Sciter-UDF</p><ul class="list"><li>list item</li><li>list item2</li></ul></body><html>')
_StLoadHtml($ST2,'<html><body><h1>2nd windows</h1><p>you can include most of one windows</p></body><html>')
$root = _StGetRootElement($ST)

$sHtml = _StGetElementHtml($root)
MsgBox(0,"Root html",$sHtml)

$aEl = _StSelectElements($root,"body p") ; get all p element in body
$p = $aEl[1] ; get first p element
MsgBox(0,"Info","Click ok for add link in p element")
_StSetElementHtml($p,'<br><a href="#">AutoIt</a>',2) ; add link in $p element

$stxt = _StGetElementText($p)
MsgBox(0,"Txt of p element",$stxt)

$aEl = _StSelectElements($root,".list")
$ul = $aEl[1]
$count = _StGetChildrenCount($ul)
MsgBox(0,"Children Count","There are " & $count & " Childrens in ul element")

MsgBox(0,"Info","Click ok for set color attribute of p element in red")
_StSetStyleAttribute($p,"color","red")




While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
	EndSwitch
WEnd