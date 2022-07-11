#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#SingleInstance, Force

$Volume_Up::
    ChangeVolume(+1)
Return

$Volume_Down::
    ChangeVolume(-1)
Return

ChangeVolume(d := 1, w := True) {
    static l := 20  ; limit to change between small/big steps
    static a := 5   ; big step to increase/decrease above the "limit"
    static b := 1   ; small step to increase/decrease below the "limit"
    static h := DllCall("User32\FindWindow", "Str","NativeHWNDHost", "Ptr",0)
    SoundGet, v
    v := Round(v)
    o := d * ( d > 0 ? (v >= l ? a : b) : (v > l ? a : b) )
    If (w) {
        DetectHiddenWindows On
        PostMessage 0xC028, 0x0C, 0xA0000,, % "ahk_id " h
    }
    SoundSet % Format("{:+d}", o)
}

ChangeVolumeExplained(direction := 1, show_osd := True) {
    ; Define some static values
    static volume_limit := 20   ; limit to change between small/big step
    static step_small := 5      ; big step to increase/decrease above the "limit"
    static step_big := 1        ; small step to increase/decrease below the "limit"
    SoundGet, current_volume    ; Get the current volume value 
    current_volume := Round(current_volume) ; Round it to a integer
    offset := 0 ;Initialize value
    ; Explanation:
    ; To ensure volume increase/decrease by defined values at the given limit (20), we check
    ; Increase volume, add 5 if volume is equal or greater than 20 else add 1
    ; Drecrease volume, sub 1 if volume is equal or less than 20 else sub 5
    ; The code here is to make sure the values behave like this:
    ;   VOLUME UP                   VOLUME DOWN
    ;   19 > 20 > 30 > 40           30 > 20 > 19 > 18 > 17...
    ; Otherwise the output will be like this:
    ;   VOLUME UP                   VOLUME DOWN
    ;   19 > 20 > 21 > 31           30 > 20 > 10 > 9 > 8...
    If (direction > 0) {
        If (current_volume >= volume_limit)
            offset := direction * step_small
        Else
            offset := direction * step_big
    }
    Else {
        If (current_volume > volume_limit)
            offset := direction * step_small
        Else
            offset := direction * step_big
    }
    ; If the user desire tho show windows osd
    If (show_osd) {
        windows_hwnd := DllCall("User32\FindWindow", "Str","NativeHWNDHost", "Ptr",0)   ; Get windows hadler
        DetectHiddenWindows On
        PostMessage 0xC028, 0x0C, 0xA0000,, % "ahk_id " windows_hwnd
    }
    SoundSet % Format("{:+d}", offset)
}
