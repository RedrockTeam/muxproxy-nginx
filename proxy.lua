local cjson = require 'cjson'
local utils = require 'utils'
local prefixes = ngx.shared.prefixes
local counters = ngx.shared.counters

local url_split = utils.split(ngx.var.app_uri, '/')
for i = #url_split, 1, -1 do
    local url_prefix = table.concat(utils.slice(url_split, 1, i, 1), '/')
    local prefix = prefixes:get(url_prefix)
    if prefix ~= nil then
        prefix = cjson.decode(prefix)
        local counter, err = counters:incr(url_prefix, 1)
        local upstreams = prefix['upstream']
        local upstream = upstreams[(counter-1)%#upstreams+1]
        for name, value in pairs(prefix['request_header']) do
            ngx.req.set_header(name, value)
        end
        for name, value in pairs(prefix['response_header']) do
            if value == cjson.null then value = nil end
            ngx.headers[name] = value
        end

        local path = '/' .. table.concat(utils.slice(url_split, i+1, #url_split, 1), '/') .. (ngx.var.args or '')
        local result = upstream
        result = ngx.re.gsub(upstream, '\\$prefix', url_prefix)
        result = ngx.re.gsub(upstream, '\\$path', path)
        return result
    end
end
