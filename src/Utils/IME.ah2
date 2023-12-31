; IME_GET 获取输入法状态
; 返回 0 英文
; 返回 1 中文
IME_GET() {
    return DllCall("SendMessage"
        , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinActive("A"))
        , "UInt", 0x0283    ;Message : WM_IME_CONTROL
        , "Int", 0x0005    ;wParam  : IMC_GETOPENSTATUS
        , "Int", 0)
}

; IME_SET 设置输入法状态
; state := 0 英文
; state := 1 中文
IME_SET(state := 0) {
    return DllCall("SendMessage"
        , "UInt", DllCall("imm32\ImmGetDefaultIMEWnd", "Uint", WinActive("A"))
        , "UInt", 0x0283    ;Message : WM_IME_CONTROL
        , "Int", 0x006    ;wParam  : IMC_SETOPENSTATUS
        , "Int", state)    ;lParam  : 0 or 1
}
