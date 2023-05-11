QuickSort(arr, function) {
    if 2 > len := arr.Length
        return arr
    ranges := [1 | (len << 32)], ranges.Length := len, i := 2
    while i > 1 {
        range := ranges[--i]
        if (start := range & 0xffffffff) >= (end := range >> 32)
            continue
        mid := arr[(start + end) / 2], left := start, right := end
        loop {
            while function(arr[left], mid) < 0
                ++left
            while function(arr[right], mid) > 0
                --right
            if left <= right
                temp := arr[left], arr[left] := arr[right], arr[right] := temp, left++, right--
        } until left > right
        if start < right
            ranges[i++] := start | right << 32
        if end > left
            ranges[i++] := left | end << 32
    }
    return arr
}