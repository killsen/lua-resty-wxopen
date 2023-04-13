
local __ = {}

-- 左移
local function leftShift(num, shift)
-- @num     : number
-- @shift   : number
-- @return  : number
    return math.floor(num * (2 ^ shift));
end

-- 右移
local function rightShift(num, shift)
-- @num     : number
-- @shift   : number
-- @return  : number
    return math.floor(num / (2 ^ shift));
end

-- 转成Ascii
local function numToAscii(num)
-- @num     : number
-- @return  : string
    num = num % 256;
    return string.char(num);
end

-- 二进制转int
function __.bufToInt32(num1, num2, num3, num4)
-- @num1    : number
-- @num2    : number
-- @num3    : number
-- @num4    : number
-- @return  : number
    local num = 0;
    num = num + leftShift(num1, 24);
    num = num + leftShift(num2, 16);
    num = num + leftShift(num3, 8);
    num = num + num4;
    return num;
end

-- int转二进制
function __.int32ToBufStr(num)
-- @num     : number
-- @return  : string
    local str = "";
    str = str .. numToAscii(rightShift(num, 24));
    str = str .. numToAscii(rightShift(num, 16));
    str = str .. numToAscii(rightShift(num, 8));
    str = str .. numToAscii(num);
    return str;
end

-- 二进制转shot
function __.bufToInt16(num1, num2)
-- @num1    : number
-- @num2    : number
-- @return  : number
    local num = 0;
    num = num + leftShift(num1, 8);
    num = num + num2;
    return num;
end

-- shot转二进制
function __.int16ToBufStr(num)
-- @num     : number
-- @return  : string
    local str = "";
    str = str .. numToAscii(rightShift(num, 8));
    str = str .. numToAscii(num);
    return str;
end

return __
