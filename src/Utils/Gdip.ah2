/**
 * @Name: Gdip
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-03-29
 * @Description: Gdip部分功能
 */

class Gdip {
	static pToken := 0

	static Startup(autoShutdown := false) {
		if (this.pToken)
			return

		if !DllCall("GetModuleHandle", "str", "gdiplus", "UPtr") {
			DllCall("LoadLibrary", "str", "gdiplus")
		}

		si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
		NumPut("UInt", 1, si)
		DllCall("gdiplus\GdiplusStartup", "UPtr*", &pToken := 0, "UPtr", si.Ptr, "UPtr", 0)
		if (!pToken) {
			throw Error("Gdiplus failed to start. Please ensure you have gdiplus on your system")
		}

		this.pToken := pToken
		if (autoShutdown)
			OnExit((*) => this.Shutdown())
	}

	static Shutdown()
	{
		DllCall("gdiplus\GdiplusShutdown", "UPtr", this.pToken)
		if hModule := DllCall("GetModuleHandle", "str", "gdiplus", "UPtr") {
			DllCall("FreeLibrary", "UPtr", hModule)
		}

		this.pToken := 0
	}

	static BitmapFromBase64(&Base64)
	{
		; calculate the length of the buffer needed
		if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", 0, "UInt*", &DecLen := 0, "UPtr", 0, "UPtr", 0)) {
			return -1
		}

		Dec := Buffer(DecLen, 0)

		; decode the Base64 encoded string
		if !(DllCall("crypt32\CryptStringToBinary", "UPtr", StrPtr(Base64), "UInt", 0, "UInt", 0x01, "UPtr", Dec.Ptr, "UInt*", &DecLen, "UPtr", 0, "UPtr", 0)) {
			return -2
		}

		; create a memory stream
		if !(pStream := DllCall("shlwapi\SHCreateMemStream", "UPtr", Dec.Ptr, "UInt", DecLen, "UPtr")) {
			return -3
		}

		DllCall("gdiplus\GdipCreateBitmapFromStreamICM", "UPtr", pStream, "Ptr*", &pBitmap := 0)
		ObjRelease(pStream)

		return pBitmap
	}

	static CreateHBITMAPFromBitmap(pBitmap, Background := 0xffffffff) {
		DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "UPtr", pBitmap, "UPtr*", &hbm := 0, "Int", Background)
		return hbm
	}
}