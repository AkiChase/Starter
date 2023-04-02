LoadIconFromBase64(base64, W := 0, H := 0)
{
    nBytes := Floor((B64Len := StrLen(base64 := RTrim(base64, "="))) * 3 / 4)
    buf := Buffer(nBytes)

    DllCall("Crypt32.dll\CryptStringToBinary", "str", base64, "int", B64Len, "int", 1, "ptr", buf, "uintp", nBytes, "Int", 0, "Int", 0)
    Return DllCall("User32.dll\CreateIconFromResourceEx", "ptr", buf, "int", nBytes, "int", 1, "int", 0x30000, "Int", W, "Int", H, "Int", 0, "ptr")
}