/**
 * MapArrClone(obj)
 * AHK v2.x
 * Created by ruchuby on 2023.2.17
 * 深拷贝 支持值类型和Map、Array引用类型
 */

MapArrClone(obj) {
    m := Map()
    _deep(target) {
        if (!isObject(target))    ; 非对象直接返回
            return target

        if !(target is Array or obj is Map)    ; 对象类型仅支持Map和Array
            throw Format("Only Array and Map are supported: {}", Type(obj))

        if (m.Has(target))    ; 存在已递归过的对象，直接返回上次的值，避免循环递归溢出
            return m[target]

        if (target is Array) {    ; 创建新对象
            result := Array()
            result.Capacity := target.Capacity
        } else
            result := Map()

        m[target] := result    ; 记录已递归

        for k, v in target
            (target is Array) ? result.Push(v) : result[k] := _deep(v)    ; 递归
        return result
    }
    return _deep(obj)
}