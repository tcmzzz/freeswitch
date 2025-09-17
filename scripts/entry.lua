local cjson = require("cjson.safe")
local http = require("socket.http")
local inspect = require("inspect")

function requestFSApi(url, body)
	local baseURL = freeswitch.getGlobalVariable("backend_addr")
	if baseURL == nil or baseURL == "" then
		baseURL = "http://backend:8090" -- 默认值
	end
	local reqURL = baseURL .. url
	freeswitch.consoleLog("debug", "req: " .. reqURL .. "\n")

	-- local resp_body = {}
	local resp = {}
	local res, code, response_headers = http.request({
		url = reqURL,
		method = "POST",
		headers = {
			["Content-Type"] = "application/json",
			["Content-Length"] = #body,
		},
		source = ltn12.source.string(body),
		sink = ltn12.sink.table(resp),
	})

	freeswitch.consoleLog("debug", "code: " .. code .. "\n")
	freeswitch.consoleLog("debug", "resp: " .. table.concat(resp) .. "\n")
	return table.concat(resp)
end

if XML_REQUEST == nil then
	freeswitch.consoleLog("notice", "XML_REQUEST Empty!\n")
	return
end

freeswitch.consoleLog("debug", "===== Lua Debug Info =====\n")
freeswitch.consoleLog("debug", inspect(XML_REQUEST) .. "\n")
freeswitch.consoleLog("debug", params:serialize("text") .. "\n")

XML_STRING = requestFSApi("/api/custom/call/sip/fs", params:serialize("json"))
