local cjson = require 'cjson'
local prefixes = ngx.shared.prefixes
local counters = ngx.shared.counters

local prefix_name = ngx.var.prefix
local result = {}

if ngx.var.request_method == 'GET' then
    if prefix_name == "" then
		local cjson = require 'cjson'
		local prefixes = ngx.shared.prefixes
		
		local prefix_list = prefixes:get_keys(0)
		local data = {}
		for index, prefix_name in ipairs(prefix_list) do
		    data[prefix_name] = cjson.decode(prefixes:get(prefix_name))
		end
		result['error'] = 0
		result['data'] = data
    else
        local data = prefixes:get(prefix_name)
        if data == nil then
            result['error'] = 1
            result['msg'] = 'prefix not found'
        else
            result['data'] = cjson.decode(prefixes:get(prefix_name))
            result['error'] = 0
        end
    end
elseif ngx.var.request_method == 'PUT' then
    if prefix_name == "" then
        result['error'] = 1
        result['msg'] = '???'
    else
        ngx.req.read_body()
        local data = cjson.decode(ngx.req.get_body_data())
        local prefix = {}
        prefix['upstream'] = data['upstream']

        prefix['request_header'] = data['request_header']
        if prefix['request_header'] == nil then prefix['request_header'] = {} end
        prefix['response_header'] = data['response_header']
        if prefix['response_header'] == nil then prefix['response_header'] = {} end

        if prefix['upstream'] == nil then
            result['error'] = 2
            result['msg'] = 'upstream list must be specified'
        elseif getmetatable(prefix['upstream']) ~= getmetatable(cjson.decode('[null]')) then
            result['error'] = 3
            result['msg'] = 'upstream list must be a list'
        elseif #prefix['upstream'] == 0 then
            result['error'] = 4
            result['msg'] = 'upstream list cannot be empty'
        else
            prefixes:set(prefix_name, cjson.encode(prefix))
            counters:set(prefix_name, 1)
            result['data'] = prefix
            result['prefix'] = '/' .. prefix_name
            result['error'] = 0
        end
    end
elseif ngx.var.request_method == 'DELETE' then
	if prefix_name == "" then
		prefixes:flush_all()
		counters:flush_all()
		result['error'] = 0
	else
    	local data = prefixes:get(prefix_name)
    	if data == nil then
    	    result['error'] = 1
    	    result['msg'] = 'prefix not found'
    	else
    	    prefixes:delete(prefix_name)
    	    counters:delete(prefix_name)
    	    result['error'] = 0
    	    result['data'] = cjson.decode(data)
    	end
	end
else
    ngx.exit(ngx.HTTP_METHOD_NOT_ALLOWED)
end

ngx.header['Content-Type'] = 'application/json'
ngx.say(cjson.encode(result))
