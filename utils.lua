local utils = {}

function utils.split(str, delim, maxNb)
    if string.find(str, delim) == nil then
       return { str }
    end
    if maxNb == nil or maxNb < 1 then
       maxNb = 0    -- No limit
    end
    local result = {}
    local pat = "(.-)" .. delim .. "()"
    local nb = 0
    local lastPos
    for part, pos in string.gfind(str, pat) do
       nb = nb + 1
       result[nb] = part
       lastPos = pos
       if nb == maxNb then
          break
       end
    end
    -- Handle the last field
    if nb ~= maxNb then
       result[nb + 1] = string.sub(str, lastPos)
    end
    return result
end

function utils.slice(tbl, first, last, step)
    local sliced = {}
    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end
    return sliced
end

function utils.startswith(str, start)
	return string.sub(str, 1, string.len(start)) == start
end

function utils.endswith(str, ending)
	return ending == '' or string.sub(str, -string.len(ending)) == ending
end

function utils.check_prefix(prefix)
    local cjson = require 'cjson'

    local upstreams = prefix['upstream']
    if upstreams == nil then
        return 'upstream list must be specified'
    elseif getmetatable(upstreams) ~= getmetatable(cjson.decode('[null]')) then
        return 'upstream list must be a list'
    elseif #upstreams == 0 then
        return 'upstream list cannot be empty'
    end
    
    for i, v in ipairs(upstreams) do
        local result = utils.check_upstream(v)
        if result ~= nil then return 'invalid upstream: ' .. result end
    end

    return nil
end

function utils.check_upstream(url)
    local neturl = require 'net.url'

    if getmetatable(url) ~= getmetatable('') then
        return 'not a string'
    end

    local u = neturl.parse(url)
    
    if u.scheme == nil then return 'invalid url' end
    if u.scheme ~= 'http' and u.shceme ~= 'https' then return 'invalid scheme: ' .. u.scheme end
    if u.host == nil then return 'no host' end
    if u.path == nil then return 'no path' end
    return nil
end

return utils
