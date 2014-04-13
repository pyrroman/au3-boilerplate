#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_requestedExecutionLevel=asInvoker
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include-once
#include <Array.au3>

;http://codesnob.wordpress.com/2009/05/18/displaying-windows-task-scheduler-tasks-with-php/
;http://msdn.microsoft.com/en-us/library/windows/desktop/aa381345%28v=VS.85%29.aspx
;http://www.scriptinganswers.com/forum2/forum_posts.asp?TID=3282
;http://www.autoit.de/index.php?page=Thread&postID=214517#post214517
;http://msdn.microsoft.com/en-us/library/aa383898%28v=VS.85%29.aspx
;http://msdn.microsoft.com/en-us/library/windows/desktop/aa381357%28v=vs.85%29.aspx

;based on this http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi


;here you will find a lot more you can do with tasks http://msdn.microsoft.com/en-us/library/windows/desktop/aa381345%28v=VS.85%29.aspx
;for most users i hope this will do...

Dim $oMyError, $ErrorFound = False
Global $wbemFlagReturnImmediately = 0x10
Global $wbemFlagForwardOnly = 0x20

Const $VT_EMPTY = 0
Const $VT_NULL = 1
Const $S_OK = "0x00000000L"
Const $S_FALSE = "0x00000001L"
Const $E_FAIL = "0x80004005L"

;~ _TestTaskSchedulerUDF()

Func _TestTaskSchedulerUDF()
	If _TaskSchedulerAutostart() Then
		$taskname1 = "Testname1"
		$taskname2 = "Testname2"
		$taskfolder1 = "\testfolder1"
		$taskfolder2 = "\testfolder2"
		$result = _TaskFolderCreate($taskfolder1)
		If $result = 1 Then
			MsgBox(0, "Success", "The folder with the name " & $taskfolder2 & " was created successfully")
		Else
			MsgBox(0, "Failure", "The folder with the name " & $taskfolder2 & " was not created successfully")
			Exit
		EndIf
		$result = _TaskFolderCreate($taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The folder with the name " & $taskfolder1 & $taskfolder2 & " was created successfully")
		Else
			MsgBox(0, "Failure", "The folder with the name " & $taskfolder1 & $taskfolder2 & " was not created successfully")
			Exit
		EndIf
		$result = _TaskFolderExists($taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The folder with the name " & $taskfolder1 & $taskfolder2 & " exists")
		Else
			MsgBox(0, "Failure", "The folder with the name " & $taskfolder1 & $taskfolder2 & " does not exist")
			Exit
		EndIf

		$result = _TaskCreate($taskfolder1 & $taskfolder2 & "\" & $taskname1, "Description of this Task", 3, "2011-03-30T08:00:00", "", 2, 1, 1, 1, 1, "PT1H", False, 3, 0, "", "", '"c:\windows\system32\notepad.exe"', "", "", False)
		If $result = 1 Then
			MsgBox(0, "Success", "The task with the name " & $taskname1 & " was created successfully")
		Else
			MsgBox(0, "Failure", "The task with the name " & $taskname1 & " was not created successfully")
			Exit
		EndIf
		$result = _TaskCreate($taskfolder1 & $taskfolder2 & "\" & $taskname2, "Description of this Task", 3, "2011-03-30T08:00:00", "", 2, 1, 1, 1, 1, "PT1H", False, 3, 0, "", "", '"c:\windows\system32\notepad.exe"', "", "", False)
		If $result = 1 Then
			MsgBox(0, "Success", "The task with the name " & $taskname2 & " was created successfully")
		Else
			MsgBox(0, "Failure", "The task with the name " & $taskname2 & " was not created successfully")
			Exit
		EndIf
		$result = _TaskStart($taskname2, $taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The task with the name " & $taskname2 & " was started successfully")
		Else
			MsgBox(0, "Failure", "The task with the name " & $taskname2 & " was not started successfully")
			Exit
		EndIf
		$result = _TaskIsRunning($taskname2, $taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The task with the name " & $taskname2 & " is running")
		ElseIf $result = 2 Then
			MsgBox(0, "Success", "The task with the name " & $taskname2 & " is not running")
		Else
			MsgBox(0, "Failure", "Not sure if the task with the name " & $taskname2 & " is running")
			Exit
		EndIf
		$result = _TaskStop($taskname2, $taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The task with the name " & $taskname2 & " was stopped successfully")
		Else
			MsgBox(0, "Failure", "The task with the name " & $taskname2 & " was not stopped successfully")
			Exit
		EndIf
		$result = _TaskListall($taskfolder1 & $taskfolder2, 1)
		If @error = 0 Then
			MsgBox(0, "Success", "The following tasks were found:" & @CRLF & $result)
		Else
			MsgBox(0, "Failure", "Tasks could not be listed")
			Exit
		EndIf

		$result = _TaskExists($taskname2, $taskfolder1 & $taskfolder2)
		If @error = 0 Then
			MsgBox(0, "Success", "The task " & $taskname2 & " exists")
		Else
			MsgBox(0, "Failure", "The task " & $taskname2 & " does not exist")
			Exit
		EndIf

		$result = _TaskDelete($taskname1, $taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The Task with the name " & $taskname1 & " was deleted successfully")
		Else
			MsgBox(0, "Failure", "The Task with the name " & $taskname1 & " was not deleted successfully")
			Exit
		EndIf

		$result = _TaskDelete($taskname2, $taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The Task with the name " & $taskname2 & " was deleted successfully")
		Else
			MsgBox(0, "Failure", "The Task with the name " & $taskname2 & " was not deleted successfully")
			Exit
		EndIf

		$result = _TaskFolderDelete($taskfolder1 & $taskfolder2)
		If $result = 1 Then
			MsgBox(0, "Success", "The Taskfolder with the name " & $taskfolder1 & $taskfolder2 & " was deleted successfully")
		Else
			MsgBox(0, "Failure", "The Taskfolder with the name " & $taskfolder1 & $taskfolder2 & " was not deleted successfully")
			Exit
		EndIf
		$result = _TaskFolderDelete($taskfolder1)
		If $result = 1 Then
			MsgBox(0, "Success", "The Taskfolder with the name " & $taskfolder1 & " was deleted successfully")
		Else
			MsgBox(0, "Failure", "The Taskfolder with the name " & $taskfolder1 & " was not deleted successfully")
			Exit
		EndIf
	Else
		MsgBox(0, "Error", "The TaskSchedulerService is not set to start at system boot - it may not be running")
		Exit
	EndIf
EndFunc   ;==>_TestTaskSchedulerUDF

;==================================================================================
; Function:          _TaskFolderCreate($folder)
; Description:       Create a Taskfolder - only folders that do not already exist can be created without error
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskFolderCreate($folder)
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder, $onewfolder
	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()
	$oFolder = $oService.GetFolder("\")
	If IsObj($oFolder) Then
		$result = $oFolder.CreateFolder($folder)
	EndIf
	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_TaskFolderCreate

;==================================================================================
; Function:          _TaskFolderDelete($folder)
; Description:       Delete a Taskfolder - only folders that do exist and that are empty can be deleted without error
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskFolderDelete($folder)
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder
	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()
	$oFolder = $oService.GetFolder("\")
	If IsObj($oFolder) Then
		$result = $oFolder.DeleteFolder($folder, 0)
	EndIf

	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_TaskFolderDelete

;==================================================================================
; Function:          _TaskFolderExists($taskname, $folder = "\")
; Description:       check if a Taskfolder exists
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskFolderExists($folder = "\")
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder
	Local $retval = 0
	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()
	$oFolder = $oService.GetFolder($folder)

	If IsObj($oFolder) Then
		$retval = 1
	Else
		$retval = 0
	EndIf

	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return $retval
	Else
		Return $retval
	EndIf
EndFunc   ;==>_TaskFolderExists

;==================================================================================
; Function:          _TaskExists($taskname, $folder = "\")
; Description:       check if a Task exists
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskExists($taskname, $folder = "\");check if a Task exists
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder

	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()

	$oFolder = $oService.GetFolder($folder)
	If IsObj($oFolder) Then
		$oTask = $oFolder.GetTask($taskname)
		If IsObj($oTask) Then
			$retval = 1
		Else
			$retval = 0
		EndIf
	Else
		$retval = 0
	EndIf
	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return $retval
	Else
		Return $retval
	EndIf
EndFunc   ;==>_TaskExists

;==================================================================================
; Function:          _TaskStop($taskname, $folder = "\")
; Description:       stop a task
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskStop($taskname, $folder = "\")
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder

	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()

	$oFolder = $oService.GetFolder($folder)
	If IsObj($oFolder) Then
		$oTask = $oFolder.GetTask($taskname)
		$instcount = 1
		If IsObj($oTask) Then
			$oTask.Stop(0)
			For $counter = 0 To 500 ;when the task is restarted (fast) after stoping it, it will look like a failure to stop it
				Sleep(100)
				$instances = $oTask.GetInstances(0)
				If IsObj($instances) Then
					If $instances.Count() = 0 Then
						$instcount = 0
						ExitLoop
					EndIf
				EndIf
			Next
			If $instcount = 0 Then
				$retval = 1
			Else
				$retval = 0
			EndIf
		Else
			$retval = 0
		EndIf
	Else
		$retval = 0
	EndIf
	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return $retval
	Else
		Return $retval
	EndIf
EndFunc   ;==>_TaskStop

;==================================================================================
; Function:          _TaskStart($taskname, $folder = "\")
; Description:       start a task
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskStart($taskname, $folder = "\");start a task
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder

	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()

	$oFolder = $oService.GetFolder($folder)
	If IsObj($oFolder) Then
		$oTask = $oFolder.GetTask($taskname)
		$instcount = 0
		If IsObj($oTask) Then
			$oTask.Run($VT_NULL)
			$retval = 1
		Else
			$retval = 0
		EndIf
	Else
		$retval = 0
	EndIf
	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return $retval
	Else
		Return $retval
	EndIf
EndFunc   ;==>_TaskStart

;==================================================================================
; Function:          _TaskIsRunning($taskname, $folder = "\")
; Description:       check if a Task is running
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskIsRunning($taskname, $folder = "\")
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder

	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()

	$oFolder = $oService.GetFolder($folder)
	If IsObj($oFolder) Then
		$oTask = $oFolder.GetTask($taskname)
		If IsObj($oTask) Then
			$instances = $oTask.GetInstances(0)
			If IsObj($instances) Then
				If $instances.Count() > 0 Then
					$retval = 1
				Else
					$retval = 2
				EndIf
			Else
				$retval = 0
			EndIf
		Else
			$retval = 0
		EndIf
	Else
		$retval = 0
	EndIf
	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return $retval
	Else
		Return $retval
	EndIf
EndFunc   ;==>_TaskIsRunning


;==================================================================================
; Function:          _TaskDelete($taskname, $folder = "\")
; Description:       delete an existing task
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskDelete($taskname, $folder = "\")
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $oService, $oFolder
	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()
	$oFolder = $oService.GetFolder($folder)
	If IsObj($oFolder) Then $odeleted = $oFolder.DeleteTask($taskname, 0)

	$oService = 0
	$oMyError = 0

	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_TaskDelete

;==================================================================================
; Function:          _TaskListAll($folder = "\", $hidden = 1)
; Description:       get a list of all tasks in a given taskfolder (Tasknames only) List is a string with names separeted by "|"
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskListAll($folder = "\", $hidden = 1)
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)
	Local $iCount = 1
	$Output = ""

	Local $oService, $oFolder

	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()

	$oFolder = $oService.GetFolder($folder)
	If IsObj($oFolder) Then
		$oTasks = $oFolder.GetTasks($hidden)
		If IsObj($oTasks) Then
			For $objItem In $oTasks
				$Output = $Output & $objItem.Name() & "|"
			Next
		EndIf
	EndIf
	;remove last "|"
	If $Output <> "" Then $Output = StringTrimRight($Output, 1)
	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return ("Error found")
	Else
		Return ($Output)
	EndIf
EndFunc   ;==>_TaskListAll

;==================================================================================
; Function:          _TaskCreate($TaskName, $TaskDescription, $TriggerEvent, $StartTrigger, $EndTrigger, $DaysOfWeek, $DaysOfMonth, $MonthOfYear, $WeeksOfMonth, $DaysInterval, $Interval, $RepetitionEnabled, $LogonType, $RunLevel, $Username, $Password, $Program, $WorkingDirectory = "", $Arguments = "", $RunOnlyIfNetworkAvailable = True, $active = True,$multiinst=0,$nobatstart=False,$stoponBat=False,$hidden = False, $idle = False, $WakeToRun=False,$timelimit="P1D",$priority = 5)
; Description:        Creates a scheduled task
; Return Value(s):   On Success  - Return 1, @ERROR = 0
;                    On Failure  - Sets @ERROR = 1, Return 0
;                                - Wrong OS (Needs Vista or higher) @Error = 2 Return 0
; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Note(s):          Works only on Win7 and above (Perhaps also Win Vista, but not tested!)
; Example:          _TaskCreate("Testname", "Description of this task", 3, "2011-03-30T08:00:00", "", 2, 1, 1, 1, 1, "PT1H", False, 3, 0, "", "", '"c:\windows\system32\notepad.exe"', "", "", True, True,0,False,False,False,False,False,"P1D",5)
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================

#cs
	$TaskName                 => String, Free text

	$TaskDescription         => String, Free text

	$TriggerEvent            => http://msdn.microsoft.com/en-us/library/aa383898%28v=VS.85%29.aspx
	(0: TASK_TRIGGER_EVENT; Triggers the task when a specific event occurs.) => Not working yet
	1: TASK_TRIGGER_TIME; Triggers the task at a specific time of day.
	2: TASK_TRIGGER_DAILY; Triggers the task on a daily schedule. For example, the task starts at a specific time every day, every-other day, every third day, and so on.
	3: TASK_TRIGGER_WEEKLY; Triggers the task on a weekly schedule. For example, the task starts at 8:00 AM on a specific day every week or other week.
	4: TASK_TRIGGER_MONTHLY; Triggers the task on a monthly schedule. For example, the task starts on specific days of specific months.
	5: TASK_TRIGGER_MONTHLYDOW; Triggers the task on a monthly day-of-week schedule. For example, the task starts on a specific days of the week, weeks of the month, and months of the year.
	6: TASK_TRIGGER_IDLE; Triggers the task when the computer goes into an idle state.
	7: TASK_TRIGGER_REGISTRATION; Triggers the task when the task is registered.
	8: TASK_TRIGGER_BOOT; Triggers the task when the computer boots. => Needs Admin-Rights!
	9: TASK_TRIGGER_LOGON; Triggers the task when a specific user logs on. => Needs Admin-Rights!
	11:TASK_TRIGGER_SESSION_STATE_CHANGE; Triggers the task when a specific session state changes. => Needs Admin-Rights!

	$StartTrigger            => String with Start time / date (Year-Month-DayTHour:Min:Sec) E.g. "2011-03-30T08:00:00"

	$EndTrigger                => String with End time / date (Year-Month-DayTHour:Min:Sec) E.g. "2011-03-30T08:00:00"

	$DaysOfWeek                => Integer; 1 = Sunday / 2 = Monday / 4 = Tuesday / 8 = Wednesday / 16 = Thursday / 32 = Friday / 64 = Saturday (http://msdn.microsoft.com/en-us/library/aa384024(v=VS.85).aspx)
	3 = Sunday AND Monday!
	This value works only in TriggerEvent 3 or 5

	$DaysOfMonth            => Integer http://msdn.microsoft.com/en-us/library/aa380735(VS.85).aspx
	This value is only noted when $TriggerEvent = 4
	Day 1; 1
	Day 2; 2
	Day 3; 4
	Day 4; 8
	Day 5; 16
	Day 6; 32
	Day 7; 64
	Day 8; 128
	Day 9; 256
	Day 10; 512
	Day 11; 1024
	Day 12; 2048
	Day 13; 4096
	Day 14; 8192
	Day 15; 16384
	Day 16; 32768
	Day 17; 65536
	Day 18; 131072
	Day 19; 262144
	Day 20; 524288
	Day 21; 1048576
	Day 22; 2097152
	Day 23; 4194304
	Day 24; 8388608
	Day 25; 16777216
	Day 26; 33554432
	Day 27; 67108864
	Day 28; 134217728
	Day 29; 268435456
	Day 30; 536870912
	Day 31; 1073741824
	Last Day; 2147483648

	$MonthOfYear            => http://msdn.microsoft.com/en-us/library/aa380736(v=VS.85).aspx
	This value is only noted when $TriggerEvent = 4
	January; 1
	February; 2
	March; 4
	April; 8
	May; 16
	June; 32
	July; 64
	August; 128
	September; 256
	October; 512
	November; 1024
	December; 2048
	January + February = 3...

	$WeeksOfMonth            => http://msdn.microsoft.com/en-us/library/aa380733(v=VS.85).aspx
	This value is only noted when $TriggerEvent = 5
	First; 1
	Second; 2
	Third; 4
	Fourth; 8
	Fifth; 16
	Last; 32

	$DaysInterval            => Integer of Days Interval; http://msdn.microsoft.com/en-us/library/aa380660(v=VS.85).aspx
	This value is only noted when $TriggerEvent = 2

	$Interval                => String for Interval; http://msdn.microsoft.com/en-us/library/aa381138(v=VS.85).aspx
	P<days>DT<hours>H<minutes>M<seconds>S (for example, "PT5M" is 5 minutes, "PT1H" is 1 hour, and "PT20M" is 20 minutes). The maximum time allowed is 31 days, and the minimum time allowed is 1 minute.

	$RepetitionEnabled        => True = Interval Trigger enabled / False = Interval Trigger disabled

	$LogonType                => 1= Save password; 2 = TASK_LOGON_S4U / Independant from an userlogin password not saved only local resources; 	3 = User must already be logged in	;http://msdn.microsoft.com/en-us/library/aa382075%28v=VS.85%29.aspx

	$RunLevel                => 0 = lowest, 1 = highest; http://msdn.microsoft.com/en-us/library/aa382076%28v=VS.85%29.aspx Highest needs Admin-Rights!

	$Username                => String with domainname "\" and Username. Use blank string ("") for actual user

	$Password                => Password for the specified user

	$Program                => String, Full Path and Programname to run

	$WorkingDirectory        => Optional String

	$Arguments                => Optional String

	$RunOnlyIfNetworkAvailable => Optional Boolean (Default = True)

	$active					=> Optional Boolean Tasks can be created enabled or disabled (True/False)

	$multiinst				=> Optional int Default is 0 1: put new task in queu to start after running task has finished 0: run while task is running 2: do not start if running 3: stop running task an start
	$nobatstart				=> Optional Boolean Default False do not start when on battery
	$stoponBat				=> Optional Boolean Default False stop when going on battery
	$hidden					=> Optional Boolean Default False Task is hidden
	$idle					=> Optional Boolean Default False run only if idle
	$WakeToRun				=> Optional Boolean Default False Wake up the system to run the tasl
	$timelimit				=> Optional String Default is "P1D" time aufter which the task is killed	When this parameter is set to Nothing, the execution time limit is infinite.
	$priority				=> Optional int Default is 5 Priority with which the task is executed		http://msdn.microsoft.com/en-us/library/aa383070(v=VS.85).aspx 0 = Realtime, 10 = Idle
#ce
Func _TaskCreate($taskname, $TaskDescription, $TriggerEvent, $StartTrigger, $EndTrigger, $DaysOfWeek, $DaysOfMonth, $MonthOfYear, $WeeksOfMonth, $DaysInterval, $Interval, $RepetitionEnabled, $LogonType, $RunLevel, $username, $password, $program, $WorkingDirectory = "", $Arguments = "", $RunOnlyIfNetworkAvailable = True, $active = True, $multiinst = 0, $nobatstart = False, $stoponBat = False, $hidden = False, $idle = False, $WakeToRun = False, $timelimit = "P1D", $priority = 5)
	If @OSVersion = "WIN_XP" Or @OSVersion = "WIN_XPe" Or @OSVersion = "WIN_2000" Then Return SetError(2, 2, 0)

	Local $oService, $oFolder, $oTaskDefinition, $oRegistrationInfo, $oSettings
	Local $oPrincipal, $oColActions, $oAction, $oTrigger, $oColTriggers, $oTriggerRepetition

	If $taskname = "" Or $program = "" Then Return SetError(1, 1, 0)

	$oMyError = ObjEvent("AutoIt.Error", "MyTaskErrFunc") ; Initialize a COM error handler
	$oService = ObjCreate("Schedule.Service")
	$oService.Connect()

	$oFolder = $oService.GetFolder("\")

	$oTaskDefinition = $oService.NewTask(0)

	$oRegistrationInfo = $oTaskDefinition.RegistrationInfo()
	$oRegistrationInfo.Description() = $TaskDescription
	$oRegistrationInfo.Author() = @LogonDomain & "\" & @UserName

	$oSettings = $oTaskDefinition.Settings()
	$oSettings.MultipleInstances() = $multiinst ;Starts a new instance while an existing instance of the task is running.
	$oSettings.DisallowStartIfOnBatteries() = $nobatstart
	$oSettings.StopIfGoingOnBatteries() = $stoponBat
	$oSettings.AllowHardTerminate() = True
	$oSettings.StartWhenAvailable() = True ;Start task as soon as possible when task missed
	$oSettings.RunOnlyIfNetworkAvailable() = $RunOnlyIfNetworkAvailable
	$oSettings.Enabled() = $active ;True ; The task can be performed only when this setting is True.
	$oSettings.Hidden() = $hidden
	$oSettings.RunOnlyIfIdle() = $idle
	$oSettings.WakeToRun() = $WakeToRun
	$oSettings.ExecutionTimeLimit() = $timelimit ; When this parameter is set to Nothing, the execution time limit is infinite.
	$oSettings.Priority() = $priority ;http://msdn.microsoft.com/en-us/library/aa383070(v=VS.85).aspx 0 = Realtime, 10 = Idle

	$oPrincipal = $oTaskDefinition.Principal()
	$oPrincipal.Id() = @UserName
	$oPrincipal.DisplayName() = @UserName
	$oPrincipal.LogonType() = $LogonType
	$oPrincipal.RunLevel() = $RunLevel

	$oColTriggers = $oTaskDefinition.Triggers()
	$oTrigger = $oColTriggers.Create($TriggerEvent)

	$oTrigger.Id() = "TriggerID"
	$oTrigger.Enabled() = True
	$oTrigger.StartBoundary() = $StartTrigger
	$oTrigger.EndBoundary() = $EndTrigger
	If $TriggerEvent = 3 Or $TriggerEvent = 5 Then
		$oTrigger.DaysOfWeek() = $DaysOfWeek
	EndIf

	If $TriggerEvent = 4 Then
		$oTrigger.DaysOfMonth() = $DaysOfMonth
		$oTrigger.MonthsOfYear() = $MonthOfYear
	EndIf

	If $TriggerEvent = 5 Then
		$oTrigger.WeeksOfMonth() = $WeeksOfMonth
	EndIf

	If $TriggerEvent = 2 Then
		$oTrigger.DaysInterval() = $DaysInterval
	EndIf

	If $RepetitionEnabled Then
		$oTriggerRepetition = $oTrigger.Repetition()
		$oTriggerRepetition.Interval() = $Interval
	EndIf

	$oColActions = $oTaskDefinition.Actions()
	$oColActions.Context() = @UserName
	$oAction = $oTaskDefinition.Actions.Create(0)
	$oAction.Path() = $program
	$oAction.WorkingDirectory() = $WorkingDirectory
	$oAction.Arguments() = $Arguments

	; call rootFolder.RegisterTaskDefinition(strTaskName, taskDefinition, FlagTaskCreate, , , LogonTypeInteractive)
	$oFolder.RegisterTaskDefinition($taskname, $oTaskDefinition, 6, $username, $password, $LogonType, "")
	$oService = 0
	$oMyError = 0
	If $ErrorFound Then
		$ErrorFound = 0
		SetError(1)
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>_TaskCreate


;==================================================================================
; Function:          _TaskSchedulerAutostart()
; Description:       check if the schedulerservice is set to autostart
; Return Value(s):   Autostart On  - Return 1
;                    Autostart Off - Return 0

; Author(s):        allow2010
; Based on:			http://www.autoit.de/index.php?page=Thread&postID=214517#post214517 and on work from Veronesi
; Thread: 			http://www.autoitscript.com/forum/topic/135994-taskplanner-udf/
;==================================================================================
Func _TaskSchedulerAutostart()
	If RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Schedule", "Start") > 0 Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>_TaskSchedulerAutostart

;catch com errors and if needed for debugging can display them
Func MyTaskErrFunc()
	$ErrorFound = True
	Return 0

	;only for debug: "comment out" the "return 0" above to make this code active
	MsgBox(0, "AutoItCOM Test", "We intercepted a COM Error !" & @CRLF & @CRLF & _
			"err.description is: " & @TAB & $oMyError.description & @CRLF & _
			"err.windescription:" & @TAB & $oMyError.windescription & @CRLF & _
			"err.number is: " & @TAB & Hex($oMyError.number, 8) & @CRLF & _
			"err.lastdllerror is: " & @TAB & $oMyError.lastdllerror & @CRLF & _
			"err.scriptline is: " & @TAB & $oMyError.scriptline & @CRLF & _
			"err.source is: " & @TAB & $oMyError.source & @CRLF & _
			"err.helpfile is: " & @TAB & $oMyError.helpfile & @CRLF & _
			"err.helpcontext is: " & @TAB & $oMyError.helpcontext _
			)

	Local $err = $oMyError.number
	Local $g_eventerror
	If $err = 0 Then $err = -1

	$g_eventerror = $err ; to check for after this function returns
EndFunc   ;==>MyTaskErrFunc
