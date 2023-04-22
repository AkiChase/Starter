ChineseFirstChar(str)
{
	static bufferObj := Buffer(2)
	VarSetStrCapacity(&var, 2)
	static array := [[-20319, -20284, "A"], [-20283, -19776, "B"], [-19775, -19219, "C"], [-19218, -18711, "D"], [-18710, -18527, "E"], [-18526, -18240, "F"], [-18239, -17923, "G"], [-17922, -17418, "H"], [-17417, -16475, "J"], [-16474, -16213, "K"], [-16212, -15641, "L"], [-15640, -15166, "M"], [-15165, -14923, "N"], [-14922, -14915, "O"], [-14914, -14631, "P"], [-14630, -14150, "Q"], [-14149, -14091, "R"], [-14090, -13319, "S"], [-13318, -12839, "T"], [-12838, -12557, "W"], [-12556, -11848, "X"], [-11847, -11056, "Y"], [-11055, -10247, "Z"]]

	; 如果不包含中文字符，则直接返回原字符
	if !RegExMatch(str, "[^\x{00}-\x{ff}]")
		return str

	loop parse, str
	{
		if (Ord(A_LoopField) >= 0x2E80 and Ord(A_LoopField) <= 0x9FFF)
		{
			StrPut(A_LoopField, bufferObj, "CP936")
			nGBKCode := (NumGet(bufferObj, 0, "UChar") << 8) + NumGet(bufferObj, 1, "UChar") - 65536
			for item in array {
				if (nGBKCode >= item[1] and nGBKCode <= item[2]) {
					out .= item[3]
					Break
				}
			}
		}
		else
			out .= A_LoopField
	}

	return out
}