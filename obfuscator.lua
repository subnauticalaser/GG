local alreadyUsed = {}
local function randomString()
    local prefix = '_'
    local str = prefix


    while true do
        for i = 1, math.random(5, 20) do
            str = str .. string.char((
                {
                    math.random(48, 57),
                    math.random(65, 90),
                    math.random(97, 122)
                }
            )[math.random(1, 3)])
        end


        if not alreadyUsed[str] then
            alreadyUsed[str] = true
            return str
        end

        str = prefix
    end
end


local function makeLocal(add)
    local localName = randomString()

    return 'local ' .. tostring(localName) .. '=' .. tostring(add) .. ';', tostring(localName)
end


local function encodeStr(str)
    local padding, newStr = math.random(1064, 9999), ''
    
    for i = 1, #str do
        newStr = newStr .. string.byte(str:sub(i, i)) + padding
    end

    return newStr, padding
end


local function StartDumping(script, allowLoadstring)
    local obfuscated = ''
    local _2ndString = ''


    for i = 1, 30 do
        _2ndString = _2ndString .. ({makeLocal(i)})[1]
    end


    if allowLoadstring then
        obfuscated = obfuscated .. (({makeLocal(("'%s'"))})[1]:format(_2ndString)) .. '\n'
        local getfenvNum = ''
        local upValue = ''
        local debugStringTable = {}

        local anyToString = (function()
            local str = ''

            local v1_1, v1_2 = makeLocal(upValue)
            local v2_1, v2_2 = makeLocal(getfenvNum)
            local v3_1, v3_2 = makeLocal(v2_2)

            local funcRanString = randomString()
            local arg1 = randomString()

            local pairs1, pairs2 = randomString(), randomString()
            local ranStr1, ranStr2 = makeLocal("''")

            str = str .. ([==[
function %s(%s)
%s
%s
%s
%s
            ]==]):format(funcRanString, arg1, v1_1, v2_1, v3_1, ranStr1)


            local tableSorter1 = makeLocal("''");
            local tableSorter = ([===[
%s=%s(%s);
            ]===]):format(ranStr2, funcRanString, pairs2)

            str = str .. ([==[
if(type(%s)=='table')then
    for %s,%s in pairs(%s) do
        %s
    end
else
    %s=tostring(%s)
end
return %s
end
            ]==]):format(
                arg1,
                pairs1,
                pairs2,
                arg1,
                tableSorter,
                ranStr2,
                arg1,
                ranStr2
            )


            return str, funcRanString
        end)


        local encodedString, paddingForDecoding = encodeStr(script)


        for i = 1, 10 do
            if i == 1 then
                local str, getfenvNum2 = makeLocal('(getfenv or function(...) return _ENV end)()')
                obfuscated = obfuscated .. str

                getfenvNum = getfenvNum2
            elseif i == 2 then
                local str, get = makeLocal('debug and debug.getupvalue')
                obfuscated = obfuscated .. str

                upValue = get
            elseif i == 3 then
                local str, get = anyToString()
                obfuscated = obfuscated .. str
            elseif i == 4 then
                local str, get = makeLocal(("'%s'"):format(encodedString))
                obfuscated = obfuscated .. str
            elseif i == 10 then
                local perStack = (function(arg)
                    local stack = ''
                    local str = ''


                    for i = 1, #script do
                        if i == 1 then
                            local ranNumber = math.random(9887, 99999)
                            local encodedLocal, get = makeLocal(("%s"):format(paddingForDecoding + ranNumber))
                            local nextE, get2 = makeLocal(('%s'):format(ranNumber))
                            local v1 = randomString()

                            str = v1
                            local v2 = v1

                            stack = stack .. (' if(%s==1)then '):format(tostring(arg)) .. tostring(encodedLocal) .. '' .. tostring(nextE) .. tostring(v2 .. '=' .. v2 .. '..string.char(' .. get .. '-' .. get2 .. ')')
                        elseif i == #script then
                            local ranNumber = math.random(9887, 99999)
                            local encodedLocal, get = makeLocal(("%s"):format(paddingForDecoding + ranNumber))
                            local nextE, get2 = makeLocal(('%s'):format(ranNumber))

                            local v2 = str

                            stack = stack .. ('\n elseif(%s==%s)then '):format(tostring(arg), tostring(i)) .. tostring(encodedLocal) .. '' .. tostring(nextE) .. tostring(v2 .. '=' .. v2 .. '..string.char(' .. get .. '-' .. get2 .. ')') .. ' end'
                        else
                            local ranNumber = math.random(9887, 99999)
                            local encodedLocal, get = makeLocal(("%s"):format(paddingForDecoding + ranNumber))
                            local nextE, get2 = makeLocal(('%s'):format(ranNumber))

                            local v2 = str

                            stack = stack .. ('\n elseif(%s==%s)then '):format(tostring(arg), tostring(i)) .. tostring(encodedLocal) .. '' .. tostring(nextE) .. tostring(v2 .. '=' .. v2 .. '..string.char(' .. get .. '-' .. get2 .. ')')
                        end
                    end


                    return stack, str
                end)

                local nextStr = randomString()

                local cmon = ([==[for %s=1,%s do ]==]):format(nextStr, tostring(#script))

                local stack, stackTrace = perStack(nextStr)

                obfuscated = obfuscated .. ' local ' .. stackTrace .. "='' "


                obfuscated = obfuscated .. cmon .. stack


                obfuscated = obfuscated .. ' end;'


                obfuscated = obfuscated .. ('load(%s)()'):format(stackTrace)
            end
        end
    else
        obfuscated = _2ndString
    end

    print(obfuscated)
end



StartDumping([[
print('GG')
]], true)
