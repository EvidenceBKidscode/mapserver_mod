
mapserver = {
	enable_crafting = minetest.settings:get("mapserver.enable_crafting") == "true",
	send_interval = tonumber(minetest.settings:get("mapserver.send_interval")) or 2,

	bridge = {}
}

local MP = minetest.get_modpath("mapserver")
dofile(MP.."/common.lua")
dofile(MP.."/poi.lua")
dofile(MP.."/train.lua")
dofile(MP.."/label.lua")
dofile(MP.."/border.lua")
dofile(MP.."/legacy.lua")
dofile(MP.."/privs.lua")

local http = minetest.request_http_api()

function read_config()
	local mapserver_url = minetest.settings:get("mapserver.url")
	local mapserver_key = minetest.settings:get("mapserver.key")

	local path = minetest.get_worldpath().."/mapserver.json";
	local mapserver_cfg

	-- check if the mapserver.json is in the world-folder
	local file = io.open(path, "r" );
	if file then
		local json = file:read("*all");
		mapserver_cfg = minetest.parse_json(json);
		file:close();
		print("[Mapserver] read settings from 'mapserver.json'")
	end

	if mapserver_cfg and mapserver_cfg.webapi then
		if not mapserver_key then
			-- apply key from json
			mapserver_key = mapserver_cfg.webapi.secretkey
		end
		if not mapserver_url then
			-- assemble url from json
			mapserver_url = "http://127.0.0.1:" .. mapserver_cfg.port
		end
	end

	if mapserver_url and mapserver_key then
		print("[Mapserver] starting mapserver-bridge with endpoint: " .. mapserver_url)
		mapserver.bridge_init(http, mapserver_url, mapserver_key)
	else
		-- Retry config in a moment
		minetest.after(1, read_config)
	end
end

-- optional mapserver-bridge stuff below
if http then
	dofile(MP.."/bridge/init.lua")
	read_config()
else
	print("[Mapserver] bridge not active, additional infos will not be visible on the map")
end
