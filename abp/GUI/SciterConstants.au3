#include-once

#Region EVENT_GROUPS
	Global Const $HANDLE_INITIALIZATION = 0 ; attached/detached
	Global Const $HANDLE_MOUSE = 1 ; mouse events
	Global Const $HANDLE_KEY = 2 ; key events
	Global Const $HANDLE_FOCUS = 4 ; focus events, if this flag is set it also means that element it attached to is focusable
	Global Const $HANDLE_SCROLL = 8 ; scroll events
	Global Const $HANDLE_TIMER = 16 ; timer event
	Global Const $HANDLE_SIZE = 32 ; size changed event
	Global Const $HANDLE_DRAW = 64 ; drawing request (event)
	Global Const $HANDLE_DATA_ARRIVED = 128 ; requested data () has been delivered
	Global Const $HANDLE_BEHAVIOR_EVENT = 256 ; secondary, synthetic events:
	Global Const $HANDLE_METHOD_CALL = 512 ; behavior specific methods
	Global Const $HANDLE_SCRIPTING_METHOD_CALL = 1024 ; behavior specific methods
	Global Const $HANDLE_TISCRIPT_METHOD_CALL = 2048 ; behavior specific methods using direct tiscript::value's
	Global Const $HANDLE_ALL = 4095 ; all of them
#EndRegion


#Region MOUSE_BUTTONS
	Global Const $MAIN_MOUSE_BUTTON = 1 ;aka left button
	Global Const $PROP_MOUSE_BUTTON = 2 ;aka right button
	Global Const $MIDDLE_MOUSE_BUTTON = 4
#EndRegion


#Region KEYBOARD_STATES
	Global Const $CONTROL_KEY_PRESSED = 0x1
	Global Const $SHIFT_KEY_PRESSED = 0x2
	Global Const $ALT_KEY_PRESSED = 0x4
#EndRegion


#Region DRAGGING_TYPE
	Global Const $NO_DRAGGING = 0
	Global Const $DRAGGING_MOVE = 1
	Global Const $DRAGGING_COPY = 2
#EndRegion


#Region MOUSE_EVENTS
	Global Const $MOUSE_ENTER = 0
	Global Const $MOUSE_LEAVE = 1
	Global Const $MOUSE_MOVE = 2
	Global Const $MOUSE_UP = 3
	Global Const $MOUSE_DOWN = 4
	Global Const $MOUSE_DCLICK = 5
	Global Const $MOUSE_WHEEL = 6
	Global Const $MOUSE_TICK = 7 ; mouse pressed ticks
	Global Const $MOUSE_IDLE = 8 ; mouse stay idle for some time

	Global Const $DROP = 9 ; item dropped, target is that dropped item
	Global Const $DRAG_ENTER = 0xA ; drag arrived to the target element that is one of current drop targets.
	Global Const $DRAG_LEAVE = 0xB ; drag left one of current drop targets. target is the drop target element.
	Global Const $DRAG_REQUEST = 0xC ; drag src notification before drag start. To cancel - return true from handler.

	Global Const $DRAGGING = 0x100 ; This flag is 'ORed' with MOUSE_ENTER..MOUSE_DOWN codes if dragging operation is in effect.
	; E.g. event DRAGGING | MOUSE_MOVE is sent to underlying DOM elements while dragging.
#EndRegion


#Region CURSOR_TYPE
	Global Enum $CURSOR_ARROW, _;= 0
			$CURSOR_IBEAM, _ 		;= 1
			$CURSOR_WAIT, _ 		;= 2
			$CURSOR_CROSS, _ 		;= 3
			$CURSOR_UPARROW, _	;= 4
			$CURSOR_SIZENWSE, _ 	;= 5
			$CURSOR_SIZENESW, _ 	;= 6
			$CURSOR_SIZEWE, _   	;= 7
			$CURSOR_SIZENS, _   	;= 8
			$CURSOR_SIZEALL, _  	;= 9
			$CURSOR_NO, _      	;= 10
			$CURSOR_APPSTARTING, _;= 11
			$CURSOR_HELP, _       ;= 12
			$CURSOR_HAND, _      ;= 13
			$CURSOR_DRAG_MOVE, _  ;= 14
			$CURSOR_DRAG_COPY ;= 15
#EndRegion



#Region KEY_EVENTS
	Global Const $KEY_DOWN = 0
	Global Const $KEY_UP = 1
	Global Const $KEY_CHAR = 2
#EndRegion


#Region FOCUS_EVENTS
	Global Const $FOCUS_LOST = 0
	Global Const $FOCUS_GOT = 1
#EndRegion

#Region FOCUS_CAUSE
	Global Const $BY_CODE = 0
	Global Const $BY_MOUSE = 1
	Global Const $BY_KEY_NEXT = 2
	Global Const $BY_KEY_PREV = 3
#EndRegion


#Region SCROLL_EVENTS

	Global Const $SCROLL_HOME = 0
	Global Const $SCROLL_END = 1
	Global Const $SCROLL_STEP_PLUS = 2
	Global Const $SCROLL_STEP_MINUS = 3
	Global Const $SCROLL_PAGE_PLUS = 4
	Global Const $SCROLL_PAGE_MINUS = 5
	Global Const $SCROLL_POS = 6
	Global Const $SCROLL_SLIDER_RELEASED = 7
#EndRegion


#Region DRAW_EVENTS
	Global Const $DRAW_BACKGROUND = 0
	Global Const $DRAW_CONTENT = 1
	Global Const $DRAW_FOREGROUND = 2
#EndRegion


#Region EXCHANGE_EVENTS
	Global Const $SYS_DRAG_ENTER = 0
	Global Const $SYS_DRAG_LEAVE = 1
	Global Const $SYS_DRAG = 2
	Global Const $SYS_DROP = 3
#EndRegion


#Region EXCHANGE_DATA_TYPE
	Global Const $EXF_UNDEFINED = 0
	Global Const $EXF_TEXT = 0x01
	Global Const $EXF_HTML = 0x02
	Global Const $EXF_HYPERLINK = 0x04
	Global Const $EXF_JSON = 0x08
	Global Const $EXF_FILE = 0x10
#EndRegion


#Region BEHAVIOR_EVENTS
	Global Const $BUTTON_CLICK = 0 ; click on button
	Global Const $BUTTON_PRESS = 1 ; mouse down or key down in button
	Global Const $BUTTON_STATE_CHANGED = 2 ; checkbox/radio/slider changed its state/value
	Global Const $EDIT_VALUE_CHANGING = 3 ; before text change
	Global Const $EDIT_VALUE_CHANGED = 4 ; after text change
	Global Const $SELECT_SELECTION_CHANGED = 5 ; selection in <select> changed
	Global Const $SELECT_STATE_CHANGED = 6 ; node in select expanded/collapsed, heTarget is the node

	Global Const $POPUP_REQUEST = 7 ; request to show popup just received,
	; 		here DOM of popup element can be modifed.
	Global Const $POPUP_READY = 8 ; popup element has been measured and ready to be shown on screen,
	; here you can use functions like ScrollToView.
	Global Const $POPUP_DISMISSED = 9 ; popup element is closed,
	;    here DOM of popup element can be modifed again - e.g. some items can be removed
	;    to free memory.

	Global Const $MENU_ITEM_ACTIVE = 10 ; menu item activated by mouse hover or by keyboard,
	Global Const $MENU_ITEM_CLICK = 11 ; menu item click,
	;   BEHAVIOR_EVENT_PARAMS structure layout
	;   BEHAVIOR_EVENT_PARAMS.cmd - MENU_ITEM_CLICK/MENU_ITEM_ACTIVE
	;   BEHAVIOR_EVENT_PARAMS.heTarget - the menu item, presumably <li> element
	;   BEHAVIOR_EVENT_PARAMS.reason - BY_MOUSE_CLICK | BY_KEY_CLICK

	Global Const $CONTEXT_MENU_SETUP = 15 ; evt.he is a menu dom element that is about to be shown. You can disable/enable items in it.
	Global Const $CONTEXT_MENU_REQUEST = 16 ; "right-click", BEHAVIOR_EVENT_PARAMS::he is current popup menu HELEMENT being processed or NULL.
	; application can provide its own HELEMENT here (if it is NULL) or modify current menu element.

	Global Const $VISIUAL_STATUS_CHANGED = 17 ; broadcast notification, sent to all elements of some container being shown or hidden


	; "grey" event codes  - notifications from behaviors from this SDK
	Global Const $HYPERLINK_CLICK = 128 ; hyperlink click
	Global Const $TABLE_HEADER_CLICK = 129 ; click on some cell in table header,
	;     target   the cell,
	;     reason   index of the cell (column number, = 0..n)
	Global Const $TABLE_ROW_CLICK = 130 ; click on data row in the table, target is the row
	;     target   the row,
	;     reason   index of the row (fixed_rows..n)
	Global Const $TABLE_ROW_DBL_CLICK = 131 ; mouse dbl click on data row in the table, target is the row
	;     target   the row,
	;     reason   index of the row (fixed_rows..n)

	Global Const $ELEMENT_COLLAPSED = 144 ; element was collapsed, so far only behavior:tabs is sending these two to the panels
	Global Const $ELEMENT_EXPANDED = 145 ; element was expanded,

	Global Const $ACTIVATE_CHILD = 146 ; activate (select) child,
	; used for example by accesskeys behaviors to send activation request, e.g. tab on behavior:tabs.

;~ 	Global Const $DO_SWITCH_TAB $ACTIVATE_CHILD ; command to switch tab programmatically, handled by behavior:tabs
	; use it as HTMLayoutPostEvent(tabsElementOrItsChild, DO_SWITCH_TAB, tabElementToShow, = 0);

	Global Const $INIT_DATA_VIEW = 147 ; request to virtual grid to initialize its view

	Global Const $ROWS_DATA_REQUEST = 148 ; request from virtual grid to data source behavior to fill data in the table
	; parameters passed throug DATA_ROWS_PARAMS structure.

	Global Const $UI_STATE_CHANGED = 149 ; ui state changed, observers shall update their visual states.
	; is sent for example by behavior:richtext when caret position/selection has changed.

	Global Const $FORM_SUBMIT = 150 ; behavior:form detected submission event. BEHAVIOR_EVENT_PARAMS::data field contains data to be posted.
	; BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about
	; to be submitted. You can modify the data or discard submission by returning TRUE from the handler.
	Global Const $FORM_RESET = 151 ; behavior:form detected reset event (from button type reset). BEHAVIOR_EVENT_PARAMS::data field contains data to be reset.
	; BEHAVIOR_EVENT_PARAMS::data is of type T_MAP in this case key/value pairs of data that is about
	; to be rest. You can modify the data or discard reset by returning TRUE from the handler.

	Global Const $DOCUMENT_COMPLETE = 152 ; behavior:frame have complete document.

	Global Const $HISTORY_PUSH = 153 ; behavior:history stuff
	Global Const $HISTORY_DROP = 154
	Global Const $HISTORY_PRIOR = 155
	Global Const $HISTORY_NEXT = 156
	Global Const $HISTORY_STATE_CHANGED = 157 ; behavior:history notification - history stack has changed
	Global Const $CLOSE_POPUP = 158 ; close popup request
	Global Const $REQUEST_TOOLTIP = 159 ; request tooltip, evt.source <- is the tooltip element.
	Global Const $ANIMATION = 160 ; animation started (reason = 1) or ended(reason = 0) on the element.

	Global Const $FIRST_APPLICATION_EVENT_CODE = 0x100
	; all custom event codes shall be greater
	; than this number. All codes below this will be used
	; solely by application - HTMLayout will not intrepret it
	; and will do just dispatching.
	; To send event notifications with  these codes use
	; HTMLayoutSend/PostEvent API.

#EndRegion


#Region EVENT_REASON
	Global Const $BY_MOUSE_CLICK = 0
	Global Const $BY_KEY_CLICK = 1
	Global Const $SYNTHESIZED = 2 ; synthesized, programmatically generated.
#EndRegion




#Region EDIT_CHANGED_REASON
	Global Const $BY_INS_CHAR = 0 ; single char insertion
	Global Const $BY_INS_CHARS = 1 ; character range insertion, clipboard
	Global Const $BY_DEL_CHAR = 2 ; single char deletion
	Global Const $BY_DEL_CHARS = 3 ; character range deletion (selection)
#EndRegion

#Region ELEMENT_STATE_BITS
	Global Const $STATE_LINK = 0x00000001
	Global Const $STATE_HOVER = 0x00000002
	Global Const $STATE_ACTIVE = 0x00000004
	Global Const $STATE_FOCUS = 0x00000008
	Global Const $STATE_VISITED = 0x00000010
	Global Const $STATE_CURRENT = 0x00000020 ; current (hot) item
	Global Const $STATE_CHECKED = 0x00000040 ; element is checked (or selected)
	Global Const $STATE_DISABLED = 0x00000080 ; element is disabled
	Global Const $STATE_READONLY = 0x00000100 ; readonly input element
	Global Const $STATE_EXPANDED = 0x00000200 ; expanded state - nodes in tree view
	Global Const $STATE_COLLAPSED = 0x00000400 ; collapsed state - nodes in tree view - mutually exclusive with
	Global Const $STATE_INCOMPLETE = 0x00000800 ; one of fore/back images requested but not delivered
	Global Const $STATE_ANIMATING = 0x00001000 ; is animating currently
	Global Const $STATE_FOCUSABLE = 0x00002000 ; will accept focus
	Global Const $STATE_ANCHOR = 0x00004000 ; anchor in selection (used with current in selects)
	Global Const $STATE_SYNTHETIC = 0x00008000 ; this is a synthetic element - don't emit it's head/tail
	Global Const $STATE_OWNS_POPUP = 0x00010000 ; this is a synthetic element - don't emit it's head/tail
	Global Const $STATE_TABFOCUS = 0x00020000 ; focus gained by tab traversal
	Global Const $STATE_EMPTY = 0x00040000 ; empty - element is empty (text.size()   = 0 && subs.size()   = 0)
	;  if element has behavior attached then the behavior is responsible for the value of this flag.
	Global Const $STATE_BUSY = 0x00080000 ; busy; loading

	Global Const $STATE_DRAG_OVER = 0x00100000 ; drag over the block that can accept it (so is current drop target). Flag is set for the drop target block
	Global Const $STATE_DROP_TARGET = 0x00200000 ; active drop target.
	Global Const $STATE_MOVING = 0x00400000 ; dragging/moving - the flag is set for the moving block.
	Global Const $STATE_COPYING = 0x00800000 ; dragging/copying - the flag is set for the copying block.
	Global Const $STATE_DRAG_SOURCE = 0x01000000 ; element that is a drag source.
	Global Const $STATE_DROP_MARKER = 0x02000000 ; element is drop marker

	Global Const $STATE_PRESSED = 0x04000000 ; pressed - close to active but has wider life span - e.g. in MOUSE_UP it
	;   is still on; so behavior can check it in MOUSE_UP to discover CLICK condition.
	Global Const $STATE_POPUP = 0x08000000 ; this element is out of flow - popup
	Global Const $STATE_IS_LTR = 0x10000000 ; the element or one of its containers has dir ltr declared
	Global Const $STATE_IS_RTL = 0x20000000 ; the element or one of its containers has dir rtl declared
#EndRegion
