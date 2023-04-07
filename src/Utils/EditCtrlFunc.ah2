/**
 * @Name: 名称
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-07
 * @Description: 介绍
 */
class EditCtrlFunc {
    ; Set placeholder
    static setPlaceholder(ctrl, placeholder) {
        DllCall("User32.dll\SendMessageW", "Ptr", ctrl.Hwnd, "Uint", (0x1500 + 1), "Ptr", True, "WStr", placeholder)
    }

    ; Gets the start and end offset of the current selection.
    static getSelection(&start, &end, ctrl) {
        s := Buffer(4, 0), e := Buffer(4, 0)
        SendMessage(0xB0, s.Ptr, e.Ptr, ctrl) ;EM_GETSEL
        start := NumGet(s, 0, "UInt"), end := NumGet(e, 0, "UInt")
    }

    ; Selects text in a edit box, given absolute character positions (starting at 0.)
    ;
    ; start:    Starting character offset, or -1 to deselect.
    ; end:      Ending character offset, or -1 for "end of text."
    static editSelect(ctrl, start := 0, end := -1) {
        SendMessage(0xB1, start, end, ctrl) ;EM_SETSEL
    }

    ; Selects a line of text.
    ;
    ; line:             One-based line number, or 0 to select the current line.
    ; include_newline:  Whether to also select the line terminator (`r`n).
    ;
    static editSelectline(ctrl, line := 0, include_newline := false)
    {
        if (line < 1)
            line := EditGetCurrentLine(ctrl)

        offset := SendMessage(0xBB, line - 1, 0, ctrl) ; EM_LINEINDEX
        lineLen := SendMessage(0xC1, offset, 0, ctrl) ; EM_LINELENGTH

        if (include_newline) {
            lineLen += (ctrl.ClassNN = "Edit" || ctrl.ClassNN = "Edit1") ? 2 : 1 ; `r`n : `n
        }

        ; Select the line.
        SendMessage(0xB1, offset, offset + lineLen, ctrl)  ; EM_SETSEL
    }

    ; Deletes a line of text.
    ;
    ; line:     One-based line number, or 0 to delete current line.
    ;
    static editDeleteline(ctrl, line := 0) {
        ; Select the line.
        this.editSelectline(ctrl, line, true)
        ControlSend("{Delete}", ctrl)
    }
}