local Serializer = {}

local function is_array(t)
    local max = 0
    local count = 0
    for k in pairs(t) do
        if type(k) ~= "number" or k <= 0 or k % 1 ~= 0 then
            return false
        end
        max = math.max(max, k)
        count = count + 1
    end

    return count == max
end

function Serializer.serialize(value)
    if type(value) == "table" then
        if is_array(value) then
            
            local result = "["
            local first = true
            for _, v in ipairs(value) do
                if not first then
                    result = result .. ","
                end
                first = false
                result = result .. Serializer.serialize(v)
            end
            return result .. "]"
        else
            
            local result = "{"
            local first = true

            
            local keys = {}
            for k in pairs(value) do
                table.insert(keys, k)
            end
            table.sort(keys, function(a, b)
                return tostring(a) < tostring(b)
            end)

            for _, k in ipairs(keys) do
                local v = value[k]
                if not first then
                    result = result .. ","
                end
                first = false
                
                if type(k) == "string" then
                    result = result .. '"' .. k .. '":'
                else
                    result = result .. '"' .. tostring(k) .. '":'
                end
                
                result = result .. Serializer.serialize(v)
            end
            return result .. "}"
        end
    elseif type(value) == "string" then
        
        local str = value:gsub('\\', '\\\\'):gsub('"', '\\"')
        return '"' .. str .. '"'
    elseif type(value) == "number" or type(value) == "boolean" then
        return tostring(value)
    elseif value == nil then
        
        return "null"
    else
        return nil 
    end
end

local readValue



function Serializer.deserialize(json)
    local pos = 1

    local function nextChar()
        local c = json:sub(pos, pos)
        pos = pos + 1
        return c
    end

    local function skipWhitespace()
        while true do
            local c = json:sub(pos, pos)
            if c == " " or c == "\t" or c == "\n" or c == "\r" then
                nextChar()
            else
                break
            end
    end
    end

    local function readString()
        local str = ""
        nextChar()
        while true do
            local c = nextChar()
            if c == '"' then
                break
            elseif c == "\\" then
                local nextC = nextChar()
                if nextC == '"' then
                    str = str .. '"'
                elseif nextC == "\\" then
                    str = str .. '\\'
                elseif nextC == "n" then 
                    str = str .. '\n'
                elseif nextC == "t" then 
                    str = str .. '\t'
                
                else
                    str = str .. nextC
                end
            else
                str = str .. c
            end
        end
        return str
    end

    local function readNumber()
        local num = ""
        
        local c = json:sub(pos, pos)
        if c == "-" then
            num = num .. c
            pos = pos + 1
        end

        while true do
            c = json:sub(pos, pos)
            
            if c:match("%d") or c == "." or c == "e" or c == "E" or c == "+" or c == "-" then
                num = num .. c
                pos = pos + 1
            else
                break
            end
        end
        return tonumber(num)
    end

    local function readLiteral(literal)
        if json:sub(pos, pos + #literal - 1) == literal then
            pos = pos + #literal
            return true
        end
        return false
    end
    
    local function readBoolean()
        local is_true = readLiteral("true")
        if is_true then
            return true
        elseif readLiteral("false") then
            return false
        end
        
        return nil
    end

    local function readNull()
        if readLiteral("null") then
            return nil 
        end
        return nil
    end

    local function readTable()
        local tbl = {}
        nextChar() 
        while true do
            skipWhitespace()
            local c = json:sub(pos, pos)
            if c == "}" then
                nextChar()
                break
            end

            
            local key = readString()
            skipWhitespace()
            nextChar() 
            skipWhitespace()
            local value = readValue()

            tbl[key] = value

            skipWhitespace()
            c = json:sub(pos, pos)
            if c == "," then
                nextChar()
            end
        end
        return tbl
    end
    
    local function readArray()
        local arr = {}
        nextChar() 
        local index = 1
        while true do
            skipWhitespace()
            local c = json:sub(pos, pos)
            if c == "]" then
                nextChar()
                break
            end

            local value = readValue()
            arr[index] = value
            index = index + 1

            skipWhitespace()
            c = json:sub(pos, pos)
            if c == "," then
                nextChar()
            end
        end
        return arr
    end

    function readValue()
        skipWhitespace()
        local c = json:sub(pos, pos)
        if c == "{" then
            return readTable()
        elseif c == "[" then
            return readArray()
        elseif c == "\"" then
            return readString()
        elseif c:match("%d") or c == "-" then 
            return readNumber()
        elseif c == "t" or c == "f" then
            return readBoolean()
        elseif c == "n" then 
            return readNull()
        else
            error("Unexpected character: " .. c .. " at pos " .. pos)
        end
    end

    return readValue()
end

return Serializer