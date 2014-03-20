#include-once
#include <Array.au3>

; Example 1 - Happy Birthday
Local $source = "<pno> ;=125 (G -G) Q | ;A G 1, C' | +'B' :| 2, D' | +C DC | Q ;G' E C | 'B' A (F' -F) | ;E C D | +C "
_MusPlusPlus($source)

Sleep(600)

; Example 2 - Mozart
$source =  @CRLF & "<fl>   ;=146 3/4 |: G   | C' E C   |  G B   G  | +.C''             | +B'     ;G   |  G  -G  G  ;G   |"
$source &= @CRLF & "<fl>   ;=146 3/4 |: ;   | E +G     | ;B D' 'B' | -C' 'B' C' D E F# | ;G  'G'  B   |  C' -C 'B' ;C'' |"
$source &= @CRLF & "<cl>   ;=146 3/4 |: ;   | +.       | +G     ;  | +.                | +.           | ;E' -E  D  ;E   |"
$source &= @CRLF & "<tpt>  ;=146 3/4 |: 'G  | 'C' E  C | ;'G ; 'G' | C    ;       C'   | 'G'  +       | ;G  -G  G  ;G   |"
$source &= @CRLF & "<timp> ;=146 3/4 |: ''G | +'C   ;C | +''G   ;G | A    A       A    |  G  -G G G G | +.G             |"
$source &= @CRLF ; Line Breaks are represented by empty lines

$source &= @CRLF & " ;G -G G ;G |  G  A  B | C'' ; fin :|  D' | +'B' ;C' | -D G F# G F G | +'B' ;C' |  D   ;  DC "
$source &= @CRLF & "  D -D C ;D | 'B' C' D | C ;   fin :| 'B' | +G   ;A  |  +.           | +G   ;A  |  B   ;  DC "
$source &= @CRLF & "  F -F E ;F | 'G' A B  | G  ;  fin :|  ;  | +.G'     | _;G  +        | +.G'     | _;G 'G' DC "
$source &= @CRLF & " ;G -G G ;G | 'G  G G  |'C' ;  fin :|  ;  | 'G G G   | +.'G'         | ;'G G G  |  G   ;  DC "
$source &= @CRLF & "  G         | ;G  G G  | +''C  fin :|  ;  | +.''G    | ;G   G    G   |  +.G     | ;G   G  DC "
_MusPlusPlus($source)

Func _MusPlusPlus($sSource) ; Parse mus++
    $sSource = _InitialTidySource($sSource)
    If @error Then Return SetError(1, 0, 0)

    Local $iParts = 8, $aSystems = StringSplit($sSource, @LF & @LF, 1)
    Local $aVoices[$iParts] = ["","","","","","","",""], $aStaves
    For $i = 1 To $aSystems[0]
        $aStaves = StringSplit($aSystems[$i], @LF)
        If $i = 1 And $aStaves[0] <= 8 Then
            $iParts = $aStaves[0]
            ReDim $aVoices [$iParts]
        ElseIf $iParts <> $aStaves[0] Then
            Return SetError (2, 0, 0) ; Inconsistant number of voices
        EndIf
        For $j = 0 To $iParts -1
            $aVoices[$j] &= " " & $aStaves[$j +1]
        Next
    Next

    Local $aTimeLine, $aRepeat[1][11], $iInstance, $vCurrInstrument, $vCurrKey, $sCurrNote, $iCurrOctave, $sLookFor, $sSegnoInstrument, _
    $sSegnoKey, $iSegnoOctave, $sSegnoNote, $iLatestInstrument, $iLatestKey, $iCurrRepeat, $iEndings, $iSegno, $iDalSegno, $iDaCapo, _
    $aAccidentals[7], $sSegnoAccidentals, $sAtTempo, $vCurrTempo, $aNotePart, $sSkipIndex, $sWarnings = "", $sErrors = "", $iTuplet, _
    $bTie, $bRest, $iPitch, $iBound =1, $aInstrument[$iParts], $iHangCheck, $iRepeats, $iCurrTime, $aMessage[$iParts][1][2] ;==> voice|instance|params=time/msg

    Local Enum $iEntry = 0, $iEntryInstrument, $iEntryKey, $iEntryOctave, $iEntryNote, $iFirstExit, $iFirstExitOctave, _
    $iFirstExitNote, $iFinalExit, $iFinalExitInstrument, $iFinalExitKey

    For $i = 0 To $iParts -1
        $aInstrument[$i] = 0xC0
    Next

    ; Parsing begins here
    For $i = 0 To $iParts -1
        _ClearAccidentals($aAccidentals)
        $aVoices[$i] = StringStripWS($aVoices[$i], 3)
        StringReplace($aVoices[$i], "|:", "") ; Get loop entry points
        If @extended Then ReDim $aRepeat[@extended +1][11]

        $iInstance = 0 ; bar repeat sections encountered
        $vCurrInstrument = "<pno>" ; piano
        $vCurrKey = "0#" ; C major / A minor
        $sCurrNote = ";" ; quarter note
        $iCurrOctave = 4
        $sLookFor = "" ; Look for Q or fin within a DC or DS section repeat

        ; Bar repeat data
        $aRepeat[$iInstance][$iEntry] = $iInstance
        $aRepeat[$iInstance][$iEntryInstrument] = $vCurrInstrument
        $aRepeat[$iInstance][$iEntryKey] = $vCurrKey
        $aRepeat[$iInstance][$iEntryOctave] = $iCurrOctave
        $aRepeat[$iInstance][$iEntryNote] = $sCurrNote
        $aRepeat[$iInstance][$iFirstExit] = $iInstance
        $aRepeat[$iInstance][$iFirstExitOctave] = $iCurrOctave
        $aRepeat[$iInstance][$iFirstExitNote] = $sCurrNote
        $aRepeat[$iInstance][$iFinalExit] = ""
        $aRepeat[$iInstance][$iFinalExitInstrument] = $vCurrInstrument
        $aRepeat[$iInstance][$iFinalExitKey] = $vCurrKey

        $iCurrRepeat = 1 ; First iteration of a bar repeat sequence
        $iEndings = 1 ; no separate bar repeat endings encountered yet

        $aTimeLine = StringRegExp($aVoices[$i], "[^\h]+", 3)
        $aVoices[$i] = ""

        $sSegnoInstrument = $vCurrInstrument ; Section repeat data
        $sSegnoKey = $vCurrKey ; Section repeat data =>
        $iSegnoOctave = $iCurrOctave
        $sSegnoNote = $sCurrNote
        $sSegnoAccidentals = ",,,,,," ; array is needed when $ occurs after an accidental
        $iLatestInstrument = 0 ; position in timeline
        $iLatestKey = 0 ; position in timeline
        $iSegno = -1 ; position of $
        $iDalSegno = -1 ; position of DS
        $iDaCapo = -1 ; position of DC
        $sAtTempo = -1
        $vCurrTempo = ";=100"
        $sSkipIndex = "|"

        For $j = 0 To UBound($aTimeLine) -1
            If StringInStr($sSkipIndex, "|" & $j & "|") Then ContinueLoop
            $iHangCheck = $j -1
            Select
                Case _IsInstrument($aTimeLine[$j])
                    If $j > $iLatestInstrument Then $iLatestInstrument = $j
                    _UpdateCurrentAttrib($vCurrInstrument, $aVoices, $aTimeLine[$j], $i)
                    $aRepeat[$iInstance][$iEntryInstrument] = $vCurrInstrument ; Temporary Patch

                Case _IsKeySig($aTimeLine[$j])
                    If $j > $iLatestKey Then $iLatestKey = $j
                    _UpdateCurrentAttrib($vCurrKey, $aVoices, $aTimeLine[$j], $i)

                Case _IsTempoMark($aTimeLine[$j])
                    If Not StringRegExp($aVoices[$i], "[A-Go\+;\-~\\\?]") Then
                        $sAtTempo = $aTimeLine[$j]
                    EndIf
                    _UpdateCurrentAttrib($vCurrTempo, $aVoices, $aTimeLine[$j], $i)

                Case _IsAtTempo($aTimeLine[$j])
                    _UpdateCurrentAttrib($vCurrTempo, $aVoices, $sAtTempo, $i)

                Case _IsSegno($aTimeLine[$j])
                    $sSegnoKey = $vCurrKey
                    $sSegnoInstrument = $vCurrInstrument
                    $iSegnoOctave = $iCurrOctave
                    $sSegnoNote = $sCurrNote
                    $iSegno = $j
                    $sSegnoAccidentals = ""
                    For $k = 0 To 5
                        $sSegnoAccidentals &= $aAccidentals[$k] & ","
                    Next
                    $sSegnoAccidentals &= $aAccidentals[6]

                Case _IsBarLine($aTimeLine[$j])
                    _ClearAccidentals($aAccidentals)

                Case _IsStartRepeat($aTimeLine[$j])
                    _ClearAccidentals($aAccidentals)
                    $iInstance += 1
                    If $j > $iDaCapo And $j > $iDalSegno Then
                        $aRepeat[$iInstance][$iEntry] = $j
                        $aRepeat[$iInstance][$iEntryInstrument] = $vCurrInstrument
                        $aRepeat[$iInstance][$iEntryKey] = $vCurrKey
                        $aRepeat[$iInstance][$iEntryOctave] = $iCurrOctave
                        $aRepeat[$iInstance][$iEntryNote] = $sCurrNote
                        $iCurrRepeat = 1
                        $iEndings = 1
                    EndIf

                Case _Is2ndTimeRound($aTimeLine[$j])
                    If $j > $iDaCapo And $j > $iDalSegno Then
                        If $aRepeat[$iInstance][$iFinalExit] = "" Then
                            $aRepeat[$iInstance][$iFirstExit] = $j
                            $aRepeat[$iInstance][$iFirstExitOctave] = $iCurrOctave
                            $aRepeat[$iInstance][$iFirstExitNote] = $sCurrNote
                        EndIf

                        $iRepeats = StringTrimRight($aTimeLine[$j], 1) ; string to number
                        If $iEndings < $iRepeats Then $iEndings = $iRepeats
                        If $iCurrRepeat > $iRepeats Then
                            If $vCurrKey <> $aTimeLine[$iLatestKey] Then
                                If _IsKeySig($aTimeLine[$iLatestKey]) Then
                                    $vCurrKey = $aTimeLine[$iLatestKey]
                                    $aVoices[$i] &= $vCurrKey & " "
                                EndIf
                            EndIf
                            _UpdateCurrentAttrib($vCurrInstrument, $aVoices, $aTimeLine[$iLatestInstrument], $i)
                            _ClearAccidentals($aAccidentals)
                            $j = $aRepeat[$iInstance][$iFinalExit] ; Go to the next end repeat mark
                        EndIf
                    Else
                        $j = $aRepeat[$iInstance][$iFinalExit] ; Go directly to the last end section
                        _ClearAccidentals($aAccidentals)
                        _UpdateCurrentAttrib($vCurrKey, $aVoices, $aRepeat[$iInstance][$iFinalExitKey], $i)
                        _UpdateCurrentAttrib($vCurrInstrument, $aVoices, $aRepeat[$iInstance][$iFinalExitInstrument], $i)
                    EndIf

                Case _IsTie($aTimeLine[$j]) Or _IsStartTuplet($aTimeLine[$j]) Or _IsEndTuplet($aTimeLine[$j])
                    $aVoices[$i] &= $aTimeLine[$j] & " "

                Case _IsNote($aTimeLine[$j])
                    $aNotePart = _NoteSplit($aTimeLine[$j])
                    If $aNotePart[0] <> "" Then
                        $sCurrNote = _GetCurrNote($aNotePart[0])
                    EndIf
                    If $aNotePart[1] <> "" Then
                        If StringInStr($aNotePart[1], "'") Then
                            $iCurrOctave = _GetOctave($aNotePart[1])
                        EndIf
                        If StringRegExp($aNotePart[1], "[#bxz]") Then
                            _UpdateAccidentals($aAccidentals, $aNotePart[1])
                        Else
                            _GetAccidental($aAccidentals, $aNotePart[1])
                        EndIf
                    EndIf
                    $aVoices[$i] &= $aNotePart[0] & $aNotePart[1] & " "
                    If $sAtTempo = -1 Then $sAtTempo = $vCurrTempo

                Case _IsEndRepeat($aTimeLine[$j])
                    If $j > $iDaCapo And $j > $iDalSegno Then
                        _ClearAccidentals($aAccidentals)
                        If $iCurrRepeat = $iEndings Then
                            $aRepeat[$iInstance][$iFinalExit] = $j
                            $aRepeat[$iInstance][$iFinalExitInstrument] = $vCurrInstrument
                            $aRepeat[$iInstance][$iFinalExitKey] = $vCurrKey
                        EndIf
                        If $iCurrRepeat <= $iEndings Then ; Go back to the start of the loop
                            $j = $aRepeat[$iInstance][$iEntry] ; $j will be incremented on the next pass ^^
                            $iCurrRepeat += 1
                            _UpdateCurrentAttrib($vCurrKey, $aVoices, $aRepeat[$iInstance][$iEntryKey], $i)
                            _UpdateCurrentAttrib($vCurrInstrument, $aVoices, $aRepeat[$iInstance][$iEntryInstrument], $i)
                            _UpdateCurrentAttrib($iCurrOctave, $aVoices, $aRepeat[$iInstance][$iEntryOctave], $i, "{", "} ")
                            _UpdateCurrentAttrib($sCurrNote, $aVoices, $aRepeat[$iInstance][$iEntryNote], $i, "{", "} ")
                        EndIf
                    EndIf

                Case _IsDalSegno($aTimeLine[$j])
                    If $iDalSegno < $j Then
                        If $iSegno = -1 Then
                            $sWarnings &= "Voice " & $i +1 & " Warning => Expected $ sign before DS " & @CRLF
                            ConsoleWrite($sWarnings) ; deal with this later
                            ExitLoop ; further parsing of this voice is meaningless
                        EndIf
                        $iDalSegno = $j
                        $j = $iSegno
                        $sLookFor = "DS"
                        _UpdateCurrentAttrib($vCurrKey, $aVoices, $sSegnoKey, $i)
                        _UpdateCurrentAttrib($vCurrInstrument, $aVoices, $sSegnoInstrument, $i)
                        _UpdateCurrentAttrib($iCurrOctave, $aVoices, $iSegnoOctave, $i, "{", "} ")
                        _UpdateCurrentAttrib($sCurrNote, $aVoices, $sSegnoNote, $i, "{", "} ")
                        $aAccidentals = StringSplit($sSegnoAccidentals, ",", 2)
                        For $iInstance = $iInstance To 0 Step -1
                            If $iSegno > $aRepeat[$iInstance][$iEntry] Then ExitLoop
                        Next
                    EndIf

                Case _IsDaCapo($aTimeLine[$j])
                    If $iDaCapo < $j Then
                        _ClearAccidentals($aAccidentals)
                        $iDaCapo = $j
                        $j = -1
                        $sLookFor = "DC"
                        $iInstance = 0
                        _UpdateCurrentAttrib($vCurrKey, $aVoices, $aRepeat[$iInstance][$iEntryKey], $i)
                        _UpdateCurrentAttrib($vCurrInstrument, $aVoices, $aRepeat[$iInstance][$iEntryInstrument], $i)
                        _UpdateCurrentAttrib($iCurrOctave, $aVoices, $aRepeat[$iInstance][$iEntryOctave], $i, "{", "} ")
                        _UpdateCurrentAttrib($sCurrNote, $aVoices, $aRepeat[$iInstance][$iEntryNote], $i, "{", "} ")
                    EndIf

                Case _IsCoda($aTimeLine[$j])
                    If ($sLookFor = "DS" And $j < $iDalSegno) Or ($sLookFor = "DC" And $j < $iDaCapo) Then
                        If $iDalSegno > $iDaCapo Then
                            $j = $iDalSegno
                        Else
                            $j = $iDaCapo
                        EndIf
                        _UpdateCurrentAttrib($vCurrKey, $aVoices, $aTimeLine[$iLatestKey], $i)
                        _UpdateCurrentAttrib($vCurrInstrument, $aVoices, $aTimeLine[$iLatestInstrument], $i)
                    EndIf

                Case _IsFin($aTimeLine[$j])
                    If ($sLookFor = "DS" And $j < $iDalSegno) Or ($sLookFor = "DC" And $j < $iDaCapo) Then ExitLoop

                Case Else
                    If _IsTimeSig($aTimeLine[$j]) Or _IsTechnique($aTimeLine[$j]) Or _IsBarRepeat($aTimeLine[$j]) Or _IsAccel($aTimeLine[$j]) Or _IsDynamicMark($aTimeLine[$j]) Then
                        ContinueLoop ; Currently unsupported performance instructions or features
                    Else
                        $sErrors &= "Voice " & $i +1 & " Syntax Error => " & $aTimeLine[$j] & @CRLF
                        $sSkipIndex &= $j & "|"
                        ConsoleWrite("Voice " & $i +1 & " Syntax Error => " & $aTimeLine[$j] & @LF)
                    EndIf
            EndSelect
            If $j = $iHangCheck Then $j += 1 ; Recursion correction
        Next
        ;ConsoleWrite($aVoices[$i] & @LF)

        $aTimeLine = StringRegExp($aVoices[$i], "[^\h]+", 3)
        $iInstance = UBound($aTimeLine)*2 ; upper limit... variable re-usage
        If $iInstance > UBound($aMessage, 2) Then ReDim $aMessage [$iParts][$iInstance][2]

        $vCurrInstrument = 0
        $iLatestInstrument = 0
        $vCurrKey = 0 ; C major / A minor
        $iLatestKey = 0 ; C major / A minor
        $vCurrTempo = 100
        $iCurrOctave = 4
        $sCurrNote = ";"
        $sLookFor = -1 ; variable re-usage
        $bTie = False ; variable re-usage
        $bRest = True
        $iInstance = 0 ; message count
        $iCurrTime = 0
        $iTuplet = 1
        Local $iDuration

        For $j = 0 To UBound($aTimeLine) -1
            Select
                Case _IsInstrument($aTimeLine[$j])
                    $aTimeLine[$j] = StringRegExpReplace($aTimeLine[$j], "(_)(pno|box|org|acc|gtr|bass|tpt|sax|hn|drum|bl)", " " & "$2")
                    $iLatestInstrument = _GetInstrument($aTimeLine[$j])
                    If @error And Not StringInStr($sErrors, $aTimeLine[$j]) Then
                        $sErrors &= "Voice " & $i +1 & " Instrument not recognized => " & $aTimeLine[$j] & @CRLF
                        ConsoleWrite("Voice " & $i +1 & " Instrument not recognized => " & $aTimeLine[$j] & @LF)
                    ElseIf $vCurrInstrument <> $iLatestInstrument Then
                        $vCurrInstrument = $iLatestInstrument
                        $aMessage[$i][$iInstance][0] = $iCurrTime
                        $aMessage[$i][$iInstance][1] = $vCurrInstrument*256 + 0xC0
                        $iInstance += 1
                    EndIf
                    $aInstrument[$i] = $vCurrInstrument*256 + 0xC0

                Case _IsKeySig($aTimeLine[$j])
                    $vCurrKey = _GetKey($aTimeLine[$j])

                Case _IsTempoMark($aTimeLine[$j])
                    $vCurrTempo = _GetQuartNoteBPM($aTimeLine[$j])

                Case _IsTie($aTimeLine[$j])
                    $bTie = True

                Case _IsStartTuplet($aTimeLine[$j])
                    $iTuplet = StringReplace($aTimeLine[$j], "(", "")
                    If $iTuplet = "" Then $iTuplet = 3

                Case _IsOctave($aTimeLine[$j])
                    $iCurrOctave = StringRegExpReplace($aTimeLine[$j], "[\{\}]", "")

                Case _IsCurrentNote($aTimeLine[$j])
                    $sCurrNote = StringRegExpReplace($aTimeLine[$j], "[\{\}]", "")

                Case _IsNote($aTimeLine[$j])
                    $aNotePart = _NoteSplit($aTimeLine[$j])
                    If $aNotePart[0] <> "" Then
                        $sCurrNote = _GetCurrNote($aNotePart[0])
                    Else
                        $aNotePart[0] = $sCurrNote
                    EndIf
                    $iDuration = _GetDuration($aNotePart[0], $vCurrTempo, $iTuplet)

                    If $aNotePart[1] <> "" Then
                        If StringInStr($aNotePart[1], "'") Then
                            $iCurrOctave = _GetOctave($aNotePart[1])
                        EndIf
                        If Not $bTie Then
                            $aMessage[$i][$iInstance][0] = $iCurrTime
                            $iPitch = _GetPitch($aNotePart[1], $vCurrKey, $iCurrOctave)
                            $aMessage[$i][$iInstance][1] = BitOr(($iPitch+0x15)*256, 0x90, 0x400000) ; Midi note on
                            $iInstance += 1
                        Else
                            If Not $bRest And $sLookFor > -1 Then
                                $aMessage[$i][$sLookFor][0] += $iDuration
                            EndIf
                        EndIf
                        $bRest = False
                    Else
                        $bRest = True
                    EndIf

                    $iCurrTime += $iDuration
                    If Not $bRest And Not $bTie Then ; Now turn note off
                        $aMessage[$i][$iInstance][0] = $iCurrTime
                        $aMessage[$i][$iInstance][1] = BitXOR($aMessage[$i][$iInstance -1][1], 0x400000) ; Midi note off
                        $sLookFor = $iInstance
                        $iInstance += 1
                    EndIf
                    $bTie = False

                Case _IsEndTuplet($aTimeLine[$j])
                    $iTuplet = 1
            EndSelect
        Next
        If $iInstance > $iBound Then $iBound = $iInstance
    Next

    ReDim $aMessage[$iParts][$iBound][2]

    ;_WalkThrough3D($aMessage) ; Debugging - Requires arratf.au3

    $sLookFor = ""
    For $i = 0 To $iParts -1
        For $j = 0 To UBound($aMessage, 2) -1
            If $aMessage[$i][$j][0] == "" Then ExitLoop
            If Not StringInStr($sLookFor, "," & $aMessage[$i][$j][0] & ",") Then
                $sLookFor &= $aMessage[$i][$j][0] & ","
            EndIf
        Next
    Next
    $aTimeLine = StringSplit(StringTrimRight($sLookFor, 1), ",", 2)
    _ArraySortByNumber($aTimeLine)

    If $aTimeLine[1] = 0 Then _ArrayDelete($aTimeLine, 0)

    Local $aGrid[UBound($aTimeLine)][$iParts*8 +3]
    For $i = 0 To UBound($aTimeLine) -1
        $aGrid[$i][0] = 1
        $aGrid[$i][1] = $aTimeLine[$i]
    Next

    For $i = $iParts -1 To 0 Step -1
        $iInstance = 0
        For $j = 0 To UBound($aMessage, 2) -1
            If $aMessage[$i][$j][0] == "" Then ExitLoop
            If $aMessage[$i][$j][0] == $aTimeLine[$iInstance] Then

                If BitAND($aMessage[$i][$j][1], 0x400000) = 0x400000 Then
                    If $aGrid[$iInstance][$aGrid[$iInstance][0]] <> $aInstrument[$i] Then
                        $aGrid[$iInstance][0] += 1
                        $aGrid[$iInstance][$aGrid[$iInstance][0]] = $aInstrument[$i]
                    EndIf
                EndIf

                $aGrid[$iInstance][0] += 1
                $aGrid[$iInstance][$aGrid[$iInstance][0]] = $aMessage[$i][$j][1]

            ElseIf $aMessage[$i][$j][0] > $aTimeLine[$iInstance] Then
                $iInstance += 1
                If $iInstance > UBound($aTimeLine) -1 Then ExitLoop
                $j -= 1
            EndIf
        Next

    Next
    ;_ArrayDisplay($aGrid)

    Local $iTimer, $dOpen = _MidiOutOpen()
    $iInstance = 0
    $iTimer = TimerInit()
    While 1
        If TimerDiff($iTimer) >= $aGrid[$iInstance][1] Then
            For $i = 2 To $aGrid[$iInstance][0]
                _MidiOutShortMsg($dOpen, $aGrid[$iInstance][$i])
            Next
            $iInstance += 1
        Else
            Sleep(10)
        EndIf
        If $iInstance > UBound($aTimeLine) -1 Then ExitLoop
    WEnd
    Sleep(600)
    _MidiOutClose($dOpen)
EndFunc ;==> _MusPlusPlus

#region ; conditionals
Func _IsInstrument($sInstruction)
    Return StringRegExp($sInstruction, "(?i)(\A<[a-z \-_0-9]+>\z)")
EndFunc ;==> _IsInstrument

Func _IsKeySig($sInstruction)
    Return StringRegExp($sInstruction, "(\A[0-7][#b]\z)")
EndFunc ;==> _IsKeySig

Func _IsTimeSig($sInstruction) ; Requires accentuation / dynamics
    Return StringRegExp($sInstruction, "(\A\d+/(1|2|4|8|16|32|64)\z)")
EndFunc ;==> _IsTimeSig

Func _IsTempoMark($sInstruction)
    Return StringRegExp($sInstruction, "(\A[o\+;\-~\\\?]\.?=\d*\.?\d+\z)")
EndFunc ;==> _IsTempoMark

Func _IsAtTempo($sInstruction)
    Return $sInstruction = "@Tempo" ; not case sensitive
EndFunc ;==> _IsAtTempo

Func _IsSegno($sInstruction)
    Return $sInstruction = "$"
EndFunc ;==> _IsSegno

Func _IsBarLine($sInstruction)
    Return $sInstruction = "|"
EndFunc ;==> _IsBarLine

Func _IsStartRepeat($sInstruction)
    Return $sInstruction = "|:"
EndFunc ;==> _IsStartRepeat

Func _Is2ndTimeRound($sInstruction)
    Return StringRegExp($sInstruction, "(\A\d+,\z)")
EndFunc ;==> _Is2ndTimeRound

Func _IsTie($sInstruction)
    Return $sInstruction = "_"
EndFunc ;==> _IsTie

Func _IsStartTuplet($sInstruction)
    Return StringRegExp($sInstruction, "(\A\d*\(\z)")
EndFunc ;==> _IsStartTuplet

Func _IsNote($sNote)
    If StringRegExp($sNote, "(\A'*[A-G](#|b|bb|x|z)?'*\z)") Then Return 1
    Return StringRegExp($sNote, "(\A[o\+;\-~\\\?\.]+('*[A-G](#|b|bb|x|z)?'*)?\z)")
EndFunc ;==> _IsNote

Func _IsEndTuplet($sInstruction)
    Return $sInstruction == ")"
EndFunc ;==> _IsEndTuplet

Func _IsEndRepeat($sInstruction)
    Return $sInstruction = ":|"
EndFunc ;==> _IsEndRepeat

Func _IsCoda($sInstruction)
    Return $sInstruction == "Q"
EndFunc ;==> _IsCoda

Func _IsDalSegno($sInstruction)
    Return $sInstruction == "DS"
EndFunc ;==> _IsDalSegno

Func _IsDaCapo($sInstruction)
    Return $sInstruction == "DC"
EndFunc ;==> _IsDaCapo

Func _IsFin($sInstruction)
    Return $sInstruction == "fin"
EndFunc ;==> _IsFin

Func _IsOctave($sInstruction)
    Return StringRegExp($sInstruction, "\A\{[0-8]\}\z")
EndFunc ;==> _IsOctave

Func _IsCurrentNote($sInstruction)
    Return StringRegExp($sInstruction, "\A\{[o+;=~\?]\.*\}\z")
EndFunc ;==> _IsCurrentNote
#endregion ;==> conditionals

#region ; currently unsupported features
Func _IsTechnique($sInstruction) ; Returns an integer - gliss is currently not supported
    Return StringInStr(" gliss pizz ", " " & $sInstruction & " ", 1)
EndFunc ;==> _IsTechnique

Func _IsBarRepeat($sInstruction) ; currently unsupported
    Return StringRegExp($sInstruction, "(\A%\d*\z)")
EndFunc ;==> _IsBarRepeat

Func _IsAccel($sInstruction) ; currently unsupported
    Return  StringInStr(" accel rit ", " " & $sInstruction & " ", 1)
EndFunc ;==> _IsAccel

Func _IsDynamicMark($sInstruction) ; Returns an integer - currently unsupported
    Return StringInStr(" cres dim ppp pp /p mp mf /f ff fff ", " " & $sInstruction & " ", 1)
EndFunc ;==> _IsDynamicMark
#endregion ;==> currently unsupported features

#region ; data requests
Func _GetAccidental($aAccidentals, ByRef $sNote)
    Local $sAlpha = StringReplace($sNote, "'", "")
    $sNote = StringReplace($sNote, $sAlpha, $sAlpha & $aAccidentals[Asc($sAlpha) - 65], 0, 1)
EndFunc ;==> _GetAccidental

Func _GetKey($sKey)
    Local $iSign = 1
    If StringInStr($sKey, "b", 1) Then $iSign = -1
    Return StringRegExpReplace($sKey, "[#b]", "")*$iSign
EndFunc ;==> _GetKey

Func _GetQuartNoteBPM($sTempo)
    Local $aTempo = StringSplit($sTempo, "=", 2)
    Local $iNote = StringInStr("?\~-;+o", $aTempo[0]) -5
    Return $aTempo[1]*2^$iNote
EndFunc ;==> _GetQuartNoteBPM

Func _GetCurrNote($sNote)
    Local $sCurrChr, $sRhythm = ""
    For $i = StringLen($sNote) To 1 Step -1
        $sCurrChr = StringMid($sNote, $i, 1)
        $sRhythm = $sCurrChr & $sRhythm
        If StringInStr("o+;-~\?", $sCurrChr, 1) Then ExitLoop
    Next
    Return $sRhythm
EndFunc ;==> _GetCurrNote

Func _GetOctave($sNote)
    Local $iPos, $iOctave = 4
    For $i = 65 To 71
        $iPos = StringInStr($sNote, Chr($i), 1)
        If $iPos Then
            ExitLoop
        EndIf
    Next
    For $i = 1 To $iPos -1
        If StringMid($sNote, $i, 1) = "'" Then $iOctave -= 1
    Next
    For $i = $iPos +1 To StringLen($sNote)
        If StringMid($sNote, $i, 1) = "'" Then $iOctave += 1
    Next
    Return $iOctave
EndFunc ;==> _GetOctave

Func _GetPitch($sName, $iKey = 0, $iOctave = 4)
    Local $iPitch, $sAlpha
    Select
        Case StringInStr($sName, "C", 1)
            $sAlpha = "C"
            $iPitch = 39
        Case StringInStr($sName, "D", 1)
            $sAlpha = "D"
            $iPitch = 41
        Case StringInStr($sName, "E", 1)
            $sAlpha = "E"
            $iPitch = 43
        Case StringInStr($sName, "F", 1)
            $sAlpha = "F"
            $iPitch = 44
        Case StringInStr($sName, "G", 1)
            $sAlpha = "G"
            $iPitch = 46
        Case StringInStr($sName, "A", 1)
            $sAlpha = "A"
            $iPitch = 48
        Case StringInStr($sName, "B", 1)
            $sAlpha = "B"
            $iPitch = 50
    EndSelect

    Select
        Case StringInStr($sName, "bb", 1)
            $iPitch -= 2
        Case StringInStr($sName, "b", 1)
            $iPitch -= 1
        Case StringInStr($sName, "z", 1)
            $iPitch += 0
        Case StringInStr($sName, "#", 1)
            $iPitch += 1
        Case StringInStr($sName, "x", 1)
            $iPitch += 2
        Case $iKey
            If $iKey > 0 Then
                If StringInStr(StringLeft("FCGDAEB", $iKey), $sAlpha) Then $iPitch += 1
            Else
                If StringInStr(StringRight("FCGDAEB", -$iKey), $sAlpha) Then $iPitch -= 1
            EndIf
    EndSelect

    $iOctave -= 4
    $iPitch += $iOctave*12
    If $iPitch < 0 Or $iPitch > 87 Then Return SetError (2, 0, "") ; Out of range pitch
    Return $iPitch ; values range from 0 to 87
EndFunc ;==> _GetPitch

Func _GetDuration($sNote, $iTempo = 100, $iTuplet = 1)
    Local $sLen = StringLen($sNote)
    If Not $sLen Then Return Default
    If StringLeft($sNote, 1) = "." Then Return SetError(1, 0, 0) ; Syntax error - Dot not preceeded by a note value
    Local $iDuration = 0, $iDots = 0, $sCurrChr = "", $iID, $iNote = 0
    For $i = 1 To $sLen
        $sCurrChr = StringMid($sNote, $i, 1)
        $iID = StringInStr("?\~-;+o.", $sCurrChr) -1
        Switch $iID
            Case 0 To 6
                $iDuration += $iNote
                $iNote = 6930 * 2^$iID
            Case 7
                While $sCurrChr = "."
                    $iDots += 1
                    $i += 1
                    $sCurrChr = StringMid($sNote, $i, 1)
                WEnd
                $iNote *= (2^($iDots +1) -1)/2^$iDots
                $i -= 1
                $iDots = 0
        EndSwitch
    Next
    $iDuration += $iNote
    If $iTuplet > 1 Then
        Switch $iTuplet
            Case 2, 4, 8, 16, 32, 64 ; In mus - only 2 and 4 appear, and then only in compound time
                $iDuration *= 3/2 ; it's the same result in all cases
            Case 3 ; triplets are the most common tuplet division
                $iDuration *= 2/3
            Case 5 To 7
                $iDuration *= 4/$iTuplet
            Case 9 To 15 ; In mus - tuplets greater than 12 almost never appear
                $iDuration *= 8/$iTuplet
            Case 17 To 31
                $iDuration *= 16/$iTuplet
            Case 33 To 63
                $iDuration *= 32/$iTuplet
            Case 65 To 127
                $iDuration *= 64/$iTuplet
            Case Else
                Return SetError (2, 0, 0) ; Unsupported out of range tuplet value
        EndSwitch
    EndIf
    Return $iDuration*125/(231*$iTempo)
EndFunc ;==> _GetDuration

Func _GetInstrument($vInstrument)
    $vInstrument = StringRegExpReplace($vInstrument, "[<>]", "")
    Local $aMIDIInst[72][4] _ ; A selection of available MIDI imstruments
    = _ ; Name    , ##,Mn,Mx
    [["pno"     ,  0, 0,87], _ ; Acoustic Grand Piano ... KEYBOARDS
    ["br pno"   ,  1, 0,87], _ ; Bright Piano
    ["e pno"    ,  2, 0,87], _ ; Electric Grand Piano
    ["h-t pno"  ,  3, 0,87], _ ; Honky-tonk piano
    ["hpsd"     ,  6, 0,87], _ ; Harpsichord
    ["clav"     ,  7, 0,87], _ ; Clavichord
    ["cel"      ,  8, 0,87], _ ; Celesta
    ["glock"    ,  9, 0,87], _ ; Glockenspiel ... PITCHED PERCUSSION
    ["mus box"  , 10, 0,87], _ ; Music Box
    ["vib"      , 11, 0,87], _ ; Vibraphone
    ["marim"    , 12, 0,87], _ ; Marimba
    ["xyl"      , 13, 0,87], _ ; Xylophone
    ["chimes"   , 14, 0,87], _ ; Tubular Bells
    ["dulc"     , 15, 0,87], _ ; Dulcimer
    ["ham org"  , 16, 0,87], _ ; Drawbar Organ ... ORGAN
    ["perc org" , 17, 0,87], _ ; Percussive Organ
    ["org"      , 19, 0,87], _ ; Church Organ
    ["harm"     , 20, 0,87], _ ; Harmonium Reed Organ
    ["accord"   , 21, 0,87], _ ; Accordion
    ["mouth org", 22, 0,87], _ ; Harmonica
    ["tango acc", 23, 0,87], _ ; Bandoneon
    ["gtr"      , 24, 0,87], _ ; Classical Guitar ... GUITAR
    ["a gtr"    , 25, 0,87], _ ; Accoustic Guitar
    ["jazz gtr" , 26, 0,87], _ ; Jazz Guitar
    ["e gtr"    , 27, 0,87], _ ; Electric Guitar
    ["mut gtr"  , 28, 0,87], _ ; Muted Electric Guitar
    ["fuzz gtr" , 30, 0,87], _ ; Distortion Guitar
    ["a bass"   , 32, 0,87], _ ; Acoustic Bass ... BASS
    ["e bass"   , 33, 0,87], _ ; Electric Bass
    ["bass"     , 34, 0,87], _ ; Upright Bass
    ["f bass"   , 35, 0,87], _ ; Fretless Bass
    ["sl bass"  , 36, 0,87], _ ; Slap Bass
    ["vln"      , 40, 0,87], _ ; Violin ... STRINGS
    ["vla"      , 41, 0,87], _ ; Viola
    ["vc"       , 42, 0,87], _ ; Cello
    ["db"       , 43, 0,87], _ ; Double Bass
    ["hp"       , 46, 0,87], _ ; Harp
    ["timp"     , 47, 0,87], _ ; Timpani (perc)
    ["tpt"      , 56, 0,87], _ ; Trumpet ... BRASS
    ["tbn"      , 57, 0,87], _ ; Trombone
    ["tba"      , 58, 0,87], _ ; Tuba
    ["mut tpt"  , 59, 0,87], _ ; Muted Trumpet
    ["hn"       , 60, 0,87], _ ; French Horn
    ["s sax"    , 64, 0,87], _ ; Soprano Sax ... REED
    ["a sax"    , 65, 0,87], _ ; Alto Sax
    ["sax"      , 66, 0,87], _ ; Tenor Sax
    ["b sax"    , 67, 0,87], _ ; Baritone Sax
    ["ob"       , 68, 0,87], _ ; Oboe
    ["eng hn"   , 69, 0,87], _ ; English Horn
    ["bsn"      , 70, 0,87], _ ; Bassoon
    ["cl"       , 71, 0,87], _ ; Clarinet
    ["picc"     , 72, 0,87], _ ; Piccolo ... PIPE
    ["fl"       , 73, 0,87], _ ; Flute
    ["rec"      , 74, 0,87], _ ; Recorder
    ["pan"      , 75, 0,87], _ ; Panpipes
    ["bottle"   , 76, 0,87], _ ; Bottle
    ["shaku"    , 77, 0,87], _ ; Shakuhachi
    ["whistle"  , 78, 0,87], _ ; Whistle
    ["oc"       , 79, 0,87], _ ; Ocarina
    ["sitar"    ,104, 0,87], _ ; Sitar ... OTHER
    ["banjo"    ,105, 0,87], _ ; Banjo
    ["shamisen" ,106, 0,87], _ ; Shamisen
    ["koto"     ,107, 0,87], _ ; Koto
    ["kalimba"  ,108, 0,87], _ ; Kalimba (perc)
    ["bagp"     ,109, 0,87], _ ; Bagpipe
    ["fiddle"   ,110, 0,87], _ ; Fiddle
    ["shanai"   ,111, 0,87], _ ; Shanai (woodwind)
    ["bell"     ,112, 0,87], _ ; Tinkle Bell
    ["st drum"  ,114, 0,87], _ ; Steel Drums
    ["w bl"     ,115, 0,87], _ ; Woodblock
    ["taiko"    ,116, 0,87], _ ; Taiko Drum
    ["tom-t"    ,117, 0,87]]   ; Tom-tom

    For $i = 0 To 71
        If $aMIDIInst[$i][0] = $vInstrument Then
            $vInstrument = $aMIDIInst[$i][1]
            ExitLoop
        EndIf
    Next

    $vInstrument = StringRegExpReplace($vInstrument, "[<>]", "")
    If StringRegExp($vInstrument, "[^\d]") Or $vInstrument < 0 Or $vInstrument > 127 Then Return SetError(1, 0, 0) ; returns Grand Piano
    Return $vInstrument ; values range from 0 to 117
EndFunc ;==> _GetInstrument
#endregion ;==> data requests

#region ; miscellaneous functions
Func _InitialTidySource($sSource)
    If _IllegalDotCheck($sSource) Then Return SetError(1, 0, 0)
    $sSource = StringReplace($sSource, '"', "''") ; Helmholtz-Wilkinson octaves
    $sSource = StringReplace($sSource, '(', "( ") ; Add spaces after (
    $sSource = StringReplace($sSource, ')', " ) ") ; Add spaces before and after )
    $sSource = StringRegExpReplace($sSource, "(<\h+)", " <") ; Remove spaces after <
    $sSource = StringRegExpReplace($sSource, "(\h+>)", "> ") ; Remove spaces before >
    $sSource = StringReplace($sSource, '_', " _ ") ; Add spaces before and after underscore
    $sSource = StringReplace($sSource, '|:', "|: ") ; Add spaces after start repeats
    $sSource = StringReplace($sSource, ':|', " :|") ; Add spaces before end repeats
    $sSource = StringReplace($sSource, ':|:', ":||:") ; Convert double repeat marks _
    $sSource = StringReplace($sSource, '|', " | ") ; Add spaces before and after bar lines
    $sSource = StringReplace($sSource, '| :', "|:") ; Restore start repeat marks
    $sSource = StringReplace($sSource, ': |', ":|") ; Restore end repeat marks
    $sSource = StringReplace($sSource, ' |  | ', " || ") ; Restore double bar lines
    $sSource = StringRegExpReplace($sSource, "(<[\-\w]+)(\h+)(pno|box|org|acc|gtr|bass|tpt|sax|hn|drum|bl)", "$1" & "_" & "$3")
    $sSource = StringReplace(StringReplace($sSource, @CRLF, @LF), @CR, @LF) ; Replace all breaks with @LF
    $sSource = StringRegExpReplace($sSource, "(\n\h*)", @LF) ; Remove spaces after breaks
    $sSource = StringRegExpReplace($sSource, "[\n]{2,}", @LF & @LF) ; Remove duplicate empty lines
    $sSource = StringRegExpReplace($sSource, "(\A\n*)", "") ; Remove Preceeding breaks
    $sSource = StringRegExpReplace($sSource, "(\n*\z)", "") ; Remove Trailing breaks
    Return $sSource
EndFunc ;==> _InitialTidySource

Func _UpdateCurrentAttrib(ByRef $vCurrAttrib, ByRef $aVoices, $vNewAttrib, $iIndex, $sPadLeft = "", $sPadRight = " ")
    If $vCurrAttrib <> $vNewAttrib Then
        $vCurrAttrib = $vNewAttrib
        $aVoices[$iIndex] &= $sPadLeft & $vCurrAttrib & $sPadRight
    EndIf
EndFunc ;==> _UpdateCurrentAttrib

Func _ClearAccidentals(ByRef $aAccidentals)
    For $i = 0 To 6
        $aAccidentals[$i] = ""
    Next
EndFunc ;==> _ClearAccidentals

Func _UpdateAccidentals(ByRef $aAccidentals, $sNote)
    $sNote = StringReplace($sNote, "'", "")
    Local $sAlpha = StringLeft($sNote, 1)
    $aAccidentals[Asc($sAlpha) - 65] = StringTrimLeft($sNote, 1)
EndFunc ;==> _UpdateAccidentals

Func _NoteSplit($sNote)
    Local $aNotePart[2] = ["", ""]
    $aNotePart[1] = StringRegExpReplace($sNote, "[o\+;\-~\\\?\.]+", "") ; Remove rhthmic values
    $aNotePart[0] = StringLeft($sNote, StringLen($sNote) - StringLen($aNotePart[1]))
    Return $aNotePart
EndFunc ;==> _NoteSplit

Func _IllegalDotCheck($sVoo)
    Return StringRegExp($sVoo, "(o\.{7}|\+\.{6}|;\.{5}|\-\.{4}|~\.{3}|\\\.\.|\?\.)")
        ; Warning - detected an unsupported number of dots after a note
EndFunc ;==> _IllegalDotCheck
#endregion ;==>  miscellaneous functions

#region ; MIDI functions
;=======================================================
;Retrieves a MIDI handle and Opens the Device
;Parameters(Optional) - Device ID, Window Callback,
; instance, flags
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutOpen($devid = 0, $callback = 0, $instance = 0, $flags = 0)
   Local $ret = DllCall("winmm.dll", "long", "midiOutOpen", "handle*", 0, "int", $devid, "dword_ptr", $callback, "dword_ptr", $instance, "long", $flags)
   If @error Then Return SetError(@error,0,0)
   If $ret[0] Then Return SetError(-1,$ret[0],0)
   Return $ret[1]
EndFunc   ;==>_MidiOutOpen

;=======================================================
;Closes Midi Output/Input devices
;Parameters - MidiHandle
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutClose ($hmidiout)
   Local $ret = DllCall("winmm.dll", "long", "midiOutClose", "handle", $hmidiout)
   If @error Then Return SetError(@error,0,0)
   If $ret[0] Then Return SetError(-1,$ret[0],0)
   Return $ret[0]
EndFunc   ;==> _MidiOutClose

;=======================================================
;Gets the Mixer Volume for MIDI
;Parameters - None
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutGetVolume ($devid = 0)
   Local $ret = DllCall("winmm.dll", "long", "midiOutGetVolume", "handle", $devid, "dword*",0)
   If @error Then Return SetError(@error,0,0)
   If $ret[0] Then Return SetError(-1,$ret[0],0)
   Return $ret[2]
EndFunc   ;==> _MidiOutGetVolume

;=======================================================
;Sets the Mixer Volume for MIDI
;Parameters - Volume (0 - 65535)
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutSetVolume($iVolume = 65535, $devid = 0)
    Local $iMixVolume=BitAND($iVolume,0xFFFF)+BitShift(BitAND($iVolume,0xFFFF),-16) ; From Ascend4nt
    Local $ret = DllCall("winmm.dll", "long", "midiOutSetVolume", "handle", $devid, "int", $iMixVolume)
    If @error Then Return SetError(@error,0,0)
    If $ret[0] Then Return SetError(-1,$ret[0],0)
    Return $ret[0]
EndFunc ;==> _MidiOutSetVolume

;=======================================================
;MIDI Message Send Function
;Parameters - Message as Hexcode or Constant
;Author : Eynstyne
;Library : Microsoft winmm.dll
;=======================================================
Func _MidiOutShortMsg($hmidiout, $msg)
   Local $ret = DllCall("winmm.dll", "long", "midiOutShortMsg", "handle", $hmidiout, "long", $msg)
   If @error Then Return SetError(@error,0,0)
   If $ret[0] Then Return SetError(-1,$ret[0],0)
   Return $ret[0]
EndFunc ;==> _MidiOutShortMsg
#endregion ;==> MIDI functions

#region ; functions ripped from arrayf.au3 and stringf.au3
; #FUNCTION# ====================================================================================================================
; Name...........: _ArraySortByNumber
; Description ...: Sorts a 1D array numerically ascending.
; Syntax.........: _ArraySortByNumber(ByRef $avArray [, $bVulgarFrac = False])
; Parameters ....: $avArray     - [ByRef] The array to sort
;                  $bVulgarFrac - [Optional] If set to True, vulgar fractions will be also be sorted numerically
; Return values .: Success   - Returns 1
;                  Failure   - Returns zero and sets @error to the following values:
;                  |@error = 1 : $avArray is not a one dimensional array
; Author ........: czardas
; Modified.......:
; Remarks .......: The array is sorted first by numbers and then by strings.
; Related .......: _ArraySort, _ArraySortByLen
; Link ..........:
; Example .......:
; ===============================================================================================================================

Func _ArraySortByNumber(ByRef $avArray, $bVulgarFrac = False)
    If Not IsArray($avArray) Or UBound($avArray, 0) > 1 Then Return SetError(1, 0, 0)

    Local $iBound = UBound($avArray) -1
    Local $aTemp[$iBound +1][2]
    For $i = 0 To $iBound
        $aTemp[$i][0] = $avArray[$i]
        If _StringIsNumber($avArray[$i], $bVulgarFrac) Then
            $aTemp[$i][1] = Execute($avArray[$i])
        Else
            $aTemp[$i][1] = "z" & $avArray[$i]
        EndIf
    Next
    _ArraySort($aTemp, 0, 0, 0, 1)
    For $i = 0 To $iBound
        $avArray[$i] = $aTemp[$i][0]
    Next
    Return 1
EndFunc ;==> _ArraySortByNumber

; #FUNCTION# ====================================================================================================================
; Name...........: _StringIsNumber
; Description ...: Checks whether a string is a number as recognised by the AutoIt interpreter
; Syntax.........: _StringIsNumber($sString [, $bVulgarFrac])
; Parameters ....: $sString     - The string to test
;                  $bVulgarFrac - [Optional] if set to True, vulgar fractions will also return True
; Return values .: True or False
; Author ........: czardas
; Remarks .......: Returns True for integers, floats, hexadecimal and scientific notation.
; Related .......: StringIsDigit, StringIsFloat, StringIsInt, StringIsXDigit
; Link ..........:
; Example .......: MsgBox(0, "1.2e-300 is a number", _StringIsNumber("1.2e-300"))
; ===============================================================================================================================

Func _StringIsNumber($sString, $bVulgarFrac = False)
    Local $bReturn = False
    If StringIsInt($sString) Or StringIsFloat($sString) Then
        $bReturn = True ; string is integer or float
    ElseIf StringRegExp($sString, "(?i)(\A[\+\-]?0x[A-F\d]+\z)") Then
        $bReturn = True ; string is hexadecimal integer
    ElseIf StringRegExp($sString, "(?i)(\A[\+\-]?\d*\.?\d+e[\+\-]?\d+\z)") Then
        $bReturn = True ; exponential (or scientific notation)
    ElseIf $bVulgarFrac And StringRegExp($sString, "(\A[\+\-]?\d+/\d+\z)") Then
        $bReturn = True ; string is a vulgar fraction
    EndIf
    Return $bReturn
EndFunc ; _StringIsNumber
#endregion ;==> functions ripped from arrayf.au3 and stringf.au3

#cs ; incomplete and unorganized comments
  note attributes ==> all new notes inherit attributes from the previous note played with the exception of repeats
  staff attributes ==> affecting all subsequent new notes (mus) ... key, instrument, time signature
  performance attributes ==> affecting all subsequent notes played including repeats (mus) tempo settings
  short lived attributes ==> affecting remaining notes within the bar ... accidentals
  section repeats ==> DC and DS
  multiple bar repeats ==> |: and :|

  o  ==> Lower case o ..... Whole note ......... open note
  +  ==> Plus symbol ...... Half note .......... open note with a stem
  ;  ==> Apostrophe ....... Quarter note ....... closed note with a stem
  -  ==> Minus sign ....... Eighth note ........ single flag
  ~  ==> Tilde ............ Sixteenth note ····· double flag
  \  ==> Back slash ....... Thirty-second note . tripple flag
  ?  ==> Question mark .... Sixty-fourth note .. quadruple flag (very rare)

  '   ==> 1 octave (above or below)
  "   ==> 2 octaves (above or below)
  "'  ==> 3 octaves (above or below)
  ""  ==> 4 octaves (above or below)

  Accidentals
  # ==> sharp
  b ==> flat
  x ==> double sharp
  bb ==> double flat
  z ==> natural

  Other symbols
  _   ==> tie
  .   ==> dot
  (   ==> start triplet
  5(  ==> start quintuplet
  )   ==> end tuplet
  |   ==> bar line
  |:  ==> start repeat
  :|  ==> end repeat
  1,  ==> first time round
  2,  ==> second time round
  DC ==> da capo
  $ ==> segno
  DS ==> dal segno
  fin ==> fine
  Q ==> coda
  @Tempo ==> a tempo
  <instrument name> ==> instrument

  time signatutes n/2^n
  2/4, 3/4, 6/8 etc...

  tempo markings
  ;=100  ==> 100 quarter note beats ber minute

  Key Signatures with sharps
  0# ==> C major ==> C  D  E  F  G  A  B  C
  1# ==> G major ==> G  A  B  C  D  E  F# G
  2# ==> D major ==> D  E  F# G  A  B  C# D
  3# ==> A major ==> A  B  C# D  E  F# G# A
  4# ==> E major ==> E  F# G# A  B  C# D# E
  5# ==> B major ==> B  C# D# E  F# G# A# B
  6# ==> F# major ==> F# G# A# B  C# D# E# F#
  7# ==> C# major ==> C# D# E# F# G# A# B# C#

  Key Signatures with flats
  0b ··· C major ···· C  D  E  F  G  A  B  C
  1b ··· F major ···· F  G  A  Bb C  D  E  F
  2b ··· Bb major ··· Bb C  D  Eb F  G  A  Bb
  3b ··· Eb major ··· Eb F  G  Ab Bb C  D  Eb
  4b ··· Ab major ··· Ab Bb C  Db Eb F  G  Ab
  5b ··· Db major ··· Db Eb F  Gb Ab Bb C  Db
  6b ··· Gb major ··· Gb Ab Bb C  Db Eb Fb G
  7b ··· Cb major ··· Cb Db Eb Fb Gb Ab Bb Cb

  Supported tuplet divisions
  Note    Divisions ·····································
          3       5to7    9to15  17to31   33to63  65to127
  \       ?
  ~       \       ?
  -       ~       \       ?
  ;       -       ~       \       ?
  +       ;       -       ~       \       ?
  o       +       ;       -       ~       \       ?

  Supported tuplets for compound time
  Note    Divisions ································
          2       4       8       16      32      64
  \.      ?
  ~.      \       ?
  -.      ~       \       ?
  ;.      -       ~       \       ?
  +.      ;       -       ~       \       ?
  o.      +       ;       -       ~       \       ?

  Dotted notes
  o. == o+ , o.. == o+;
  +. == +; , +.. == +;-
  ;. == ;- , ;.. == ;-~
  -. == -~ , -.. == -~\
  ~. == ~\ , ~.. == ~\?
  \. == \?
  o...... == o+;-~\?

  Illegal sequences
  o.......
  +......
  ;.....
  -....
  ~...
  \..
  ?.

  ""C  ==>  4th 8va below = sub-contra octave
  "'C  ==>  3rd 8va below
  "C   ==>  2nd 8va below
  'C   ==>  1st 8va below
  'C'  ==>  Middle C
  C'   ==>  1st 8va above
  C"   ==>  2nd 8va above
  C"'  ==>  3rd 8va above
  C""  ==>  4th 8va above

  Full Range = ""A to C""

  After DC and DS all repeat marks are ignored on second run.
  With separate endings the final section is entered immediately.
  Q or $ do not belong in a separate ending section.
  Coda occurs in a section which is skipped
  |: 1, Q :|2, [incorrect] => will miss the coda altogether
  The continuation from segno is unclear
  |: 1, $ :|2, [incorrect] => allow rhythmic corruption
  The following is fine
  |: $ 1, :|2, Q :| DS |Q
  Coda should not be placed before segno
  | Q | $ | DS | Q [incorrect]
  When entering the coda section repeat marks are reinstated

  Before DC or DS ignore $, Q and fin
  After DC go to the start and continue from there
  After DS look behind for $ and continue from there
  After DC or DS stop when you see fin or go to final section when you see Q
  Search for final section Q after DC or DS (whichever is greater)
  In the final section Q ignore DC DS Q $ - they do not belong in the coda
  After DC also look for DS and after DS also look for DC
  After DC or DS repeat marks are ignored within the repeated sequence
  With repeats that have separate endings, the final ending is entered immediately
  All other endings are skipped
  Repeat marks are reinstated after DC (or DS depending which was last encountered)
  DC DS $ fin may only be used once
  Q if used must appear twice

  Illegal characters
  {}[]&¬`
#ce ;==> incomplete and unorganized comments