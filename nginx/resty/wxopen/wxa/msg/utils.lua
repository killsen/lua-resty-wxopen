
local __ = {}

-- 左移
local function leftShift(num, shift)
    return math.floor(num * (2 ^ shift));
end

-- 右移
local function rightShift(num, shift)
    return math.floor(num / (2 ^ shift));
end

-- 转成Ascii
local function numToAscii(num)
    num = num % 256;
    return string.char(num);
end

-- 二进制转int
function __.bufToInt32(num1, num2, num3, num4)
    local num = 0;
    num = num + leftShift(num1, 24);
    num = num + leftShift(num2, 16);
    num = num + leftShift(num3, 8);
    num = num + num4;
    return num;
end

-- int转二进制
function __.int32ToBufStr(num)
    local str = "";
    str = str .. numToAscii(rightShift(num, 24));
    str = str .. numToAscii(rightShift(num, 16));
    str = str .. numToAscii(rightShift(num, 8));
    str = str .. numToAscii(num);
    return str;
end

-- 二进制转shot
function __.bufToInt16(num1, num2)
    local num = 0;
    num = num + leftShift(num1, 8);
    num = num + num2;
    return num;
end

-- shot转二进制
function __.int16ToBufStr(num)
    local str = "";
    str = str .. numToAscii(rightShift(num, 8));
    str = str .. numToAscii(num);
    return str;
end

return __
