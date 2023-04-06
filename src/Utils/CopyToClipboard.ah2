; CopyToClipboard(".\test.png", 1)

CopyToClipboard(filePath, cut := false) {
    FileCount := 0
    PathLength := 0
    ;Count files and total string length

    pid := DllCall("GetCurrentProcessId", "Uint")
    hwnd := WinExist("ahk_pid " . pid)
    DllCall("OpenClipboard", "Ptr", hwnd)
    hPath := DllCall("GlobalAlloc", "uint", 0x42, "uint", 20 + (StrLen(filePath) + 2) * 2, "Ptr")      ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
    pPath := DllCall("GlobalLock", "Ptr", hPath)                   ; Lock the moveable memory, retrieving a pointer to it.
    NumPut("uint", 20, pPath + 0), pPath += 16 ; DROPFILES.pFiles = offset of file list
    NumPut("uint", 1, pPath + 0), pPath += 4 ;fWide = 0 -->ANSI, fWide = 1 -->Unicode
    StrPut(filePath, pPath, StrLen(filePath) + 1, "UTF-16")

    DllCall("GlobalUnlock", "Ptr", hPath)
    ;hPath must not be freed! ->http://msdn.microsoft.com/en-us/library/ms649051(VS.85).aspx

    DllCall("EmptyClipboard") ; Empty the clipboard, otherwise SetClipboardData may fail.
    result := DllCall("SetClipboardData", "uint", 0xF, "Ptr", hPath) ; Place the data on the clipboard. CF_HDROP=0xF

    ;Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
    mem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 4, "Ptr")  ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
    str := DllCall("GlobalLock", "Ptr", mem)
    if (!cut)
        DllCall("RtlFillMemory", "UInt", str, "UInt", 1, "UChar", 0x05)
    else
        DllCall("RtlFillMemory", "UInt", str, "UInt", 1, "UChar", 0x02)
    DllCall("GlobalUnlock", "Ptr", mem)
    cfFormat := DllCall("RegisterClipboardFormat", "Str", "Preferred DropEffect")
    result := DllCall("SetClipboardData", "UInt", cfFormat, "Ptr", mem)
    DllCall("CloseClipboard")
    ;mem must not be freed! ->http://msdn.microsoft.com/en-us/library/ms649051(VS.85).aspx
}