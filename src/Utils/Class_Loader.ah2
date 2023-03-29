/**
 * @Name: Class_Loader
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-03-29
 * @Description: Loading files(or code) dynamically. But it needs to be loaded all in one call(loadFromFiles() or loadFromText()).
 */

#Requires AutoHotkey v2.0

#Include "*i \\.\pipe\3a9e1e44-8c0b-4e18-a0d3-63d1cadc4000"
class Loader {
    static _loaded := false

    /**
     * @description: loading files dynamically
     * @param fileList The file Path(Absolute or Relative) Array
     */
    static loadFromFiles(fileList) {
        includeText := ""
        for f in fileList {
            includeText .= "`n#Include " this._getFullPathName(f)
        }
        this.loadFromText(includeText)
    }

    /**
     * @description: loading code dynamically
     * @param text Code to load
     */
    static loadFromText(text) {
        if (this._loaded) ; Prevent dead cycle
            return

        text := "Loader._loaded := true`n" text
        ;// Create named pipes
        pipe := [0, 0]
        Loop 2
        {
            if ((pipe[A_Index] := DllCall(
                "CreateNamedPipe",                                       ; http://goo.gl/3aJQg7
                "Str", "\\.\pipe\3a9e1e44-8c0b-4e18-a0d3-63d1cadc4000", ; lpName
                "UInt", 2,                                               ; dwOpenMode = PIPE_ACCESS_OUTBOUND
                "UInt", 0,                                               ; dwPipeMode = PIPE_TYPE_BYTE
                "UInt", 255,                                             ; nMaxInstances
                "UInt", 0,                                               ; nOutBufferSize
                "UInt", 0,                                               ; nInBufferSize
                "Ptr", 0,                                               ; nDefaultTimeOut
                "Ptr", 0                                                ; lpSecurityAttributes
            )) == -1) ; INVALID_HANDLE_VALUE = -1
                throw A_ThisFunc . "() - Failed to create named pipe.`nGetLastError: " . A_LastError
        }

        ;// Process command line argument(s)
        q := Chr(34) ;// double quote for v1.1 and v2.0-a compatibility
        params := ""
        for arg in A_Args
        {
            i := 0
            while (i := InStr(arg, q, , i + 1)) ;// escape '"' with '\'
                if (SubStr(arg, i - 1, 1) != "\")
                    arg := SubStr(arg, 1, i - 1) . "\" . SubStr(arg, i++)
            params .= (A_Index > 1 ? " " : "") . (InStr(arg, " ") ? q . arg . q : arg)
        }

        ;// Reload script passing args(if any)
        Run(Format('"{}" /restart "{}" {}', A_AhkPath, A_ScriptFullPath, params))

        DllCall("ConnectNamedPipe", "Ptr", pipe[1], "Ptr", 0) ;// http://goo.gl/pwTnxj
        DllCall("CloseHandle", "Ptr", pipe[1])

        ; The second pipe is for the actual file contents.
        DllCall("ConnectNamedPipe", "Ptr", pipe[2], "Ptr", 0)
        ;// Write dynamic code into pipe
        if !(f := FileOpen(pipe[2], "h", "UTF-8")) ;// works on both Unicode and ANSI
            return A_LastError
        f.Write(text)
        f.Close(), DllCall("CloseHandle", "Ptr", pipe[2]) ;// close pipe handle
        ExitApp()
    }

    static _getFullPathName(path) {
        cc := DllCall("GetFullPathNameW", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
        buf := Buffer(cc * 2, 0)
        DllCall("GetFullPathNameW", "str", path, "uint", cc, "ptr", buf, "ptr", 0, "uint")
        return StrGet(buf)
    }
}