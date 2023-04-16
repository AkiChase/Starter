/**
 * @Name: HotkeyHelper
 * @Version: 0.0.1
 * @Author: ruchuby
 * @LastEditors: ruchuby
 * @LastEditTime: 2023-04-16
 * @Description: Hotkey Settings Tool Functions
 */

class HotkeyHelper {
    /**
     * @description: 
     * @param key the hotkey without modifier symbols
     * @param time The longest interval from first release to second press
     * @param CB Long press callback
     * @param block set false to add '~' for hotkey
     * @param physical set true to add '$' for hotkey
     * @return total hotkey string
     */
    static longPressHotKey(key, time, CB, block := false, physical := true) {
        totalKey := Format("{}{}{}", block ? "" : "~", physical ? "$" : "", key)
        time := String(Round(time, 1))
        handler(*) {
            if (!KeyWait(key, "T" time)) {
                CB()
                ; Endless waiting for release to avoid repeated calls
                KeyWait(key)
            }
        }
        Hotkey(totalKey, handler, "On")
        return totalKey
    }

    /**
     * @description: 
     * @param key the hotkey without modifier symbols
     * @param time The longest interval from first release to second press
     * @param doubleCB double press callback
     * @param singleCB single press callback
     * @param block set false to add '~' for hotkey
     * @param physical set true to add '$' for hotkey
     * @return total hotkey string
     */
    static doubleAndSingleHotKey(key, time, doubleCB, singleCB := (*) => 0, block := false, physical := true) {
        totalKey := Format("{}{}{}", block ? "" : "~", physical ? "$" : "", key)
        time := String(Round(time, 1))
        handler(*) {
            ; Wait for release
            if (KeyWait(key)) {
                if (KeyWait(key, "DT" time) && A_PriorKey = key) {
                    doubleCB()
                    KeyWait(key)
                } else
                    singleCB()
            }
        }
        Hotkey(totalKey, handler, "On")
        return totalKey
    }

    /**
     * @description: example of double and long press for the same key.
     * @param key the hotkey without modifier symbols
     * @param time1 Press for more than this time, it means long press
     * @param time2 The longest interval from first release to second press
     * @param longCB Long press callback
     * @param doubleCB double press callback
     * @param block set false to add '~' for hotkey
     * @param physical set true to add '$' for hotkey
     * @return total hotkey string
     */
    static doubleAndLongHotkey(key, time1, time2, longCB, doubleCB, block := false, physical := true) {
        ; Construct key string
        totalKey := Format("{}{}{}", block ? "" : "~", physical ? "$" : "", key)
        ; Round the time and convert it to string
        time1 := String(Round(time1, 1))
        time2 := String(Round(time2, 1))
        handler(*) {
            if (KeyWait(key, "T" time1)) {
                ; Released within time1, waiting for the second press
                if (KeyWait(key, "DT" time2)  && A_PriorKey = key) {
                    ; Second Press within time2
                    doubleCB()
                    ; Endless waiting for release to avoid repeated calls
                    KeyWait(key)
                    ; if you like, you can add 'KeyWait(key, "DT" time2)' for triple key, uadruple key...
                }
            } else {
                ; Press over the time1
                longCB()
                ; Endless waiting for release to avoid repeated calls
                KeyWait(key)
                ; Finally, the long press released.
            }
        }
        Hotkey(totalKey, handler, "On")
        return totalKey
    }
}