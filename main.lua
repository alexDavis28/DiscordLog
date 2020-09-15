-- set plugin folder
homeDir = 'Plugins/DiscordLog'

-- Plugin name and prefix for later usage
PluginName = "DiscordLog"
PluginPrefix = PluginName .. ": "

-- initialize global tables
g_Config = {}


-- SETUP



function Initialize(Plugin)
	-- Start the plugin
	Plugin:SetName("DiscordLog")
	Plugin:SetVersion(0.2)

	-- Load the config
	InitializeConfig()

	-- Check if URL is set
	if (g_Config.URL=="") then
		error("Please set a webhook URL in DiscordLog.ini")
	end

	-- Add the test command
	cPluginManager.BindCommand("/log", "DL.log", Log, " ~ Logs a message");

	-- -- Use the InfoReg shared library to process the Info.lua file:
	-- dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	-- RegisterPluginInfoCommands()

	-- Add the hook handlers
	if (g_Config.log_world_start) then
		cPluginManager:AddHook(cPluginManager.HOOK_WORLD_STARTED, MyOnWorldStarted);
	end

	if (g_Config.log_chat) then
		cPluginManager:AddHook(cPluginManager.HOOK_CHAT, MyOnChat);
	end

	if (g_Config.log_join) then
		cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_JOINED, MyOnPlayerJoined);
	end

	if (g_Config.log_disconnect) then
		cPluginManager:AddHook(cPluginManager.HOOK_DISCONNECT, MyOnDisconnect);
	end

	if (g_Config.log_command) then
		cPluginManager:AddHook(cPluginManager.HOOK_EXECUTE_COMMAND, MyOnExecuteCommand);
	end

	if (g_Config.log_plugins_loaded) then
		cPluginManager:AddHook(cPluginManager.HOOK_PLUGINS_LOADED, MyOnPluginsLoaded);
	end

	if (g_Config.log_player_spawn) then
		cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_SPAWNED, MyOnPlayerSpawned);
	end

	-- Log the plugin going online
	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

-- use a config.ini file
function InitializeConfig()

-- https://newsletter.cuberite.org/assets/cuberite.png

    local g_ini = cIniFile()
    iniFile = "DiscordLog.ini"
    g_ini:ReadFile(iniFile);
    if not cFile:IsFile(iniFile) then
        -- webhook settings
        g_Config.URL = g_ini:GetValueSet("Webhook", "URL", "");
		g_Config.PFP = g_ini:GetValueSet("Webhook", "PFP", "https://newsletter.cuberite.org/assets/cuberite.png");
		g_Config.log_world_start = g_ini:GetValueSetB("Log", "WorldStart", true)
		g_Config.log_chat = g_ini:GetValueSetB("Log", "Chat", true)
		g_Config.log_join = g_ini:GetValueSetB("Log", "PlayerJoin", true)
		g_Config.log_disconnect = g_ini:GetValueSetB("Log", "PlayerDisconnect", true)
		g_Config.log_command = g_ini:GetValueSetB("Log", "CommandExecution", true)
		g_Config.log_plugins_loaded = g_ini:GetValueSetB("Log", "PluginsLoaded", true)
		g_Config.log_player_spawn = g_ini:GetValueSetB("Log", "PlayerSpawned", false)


        g_ini:WriteFile(iniFile);
	else
		g_Config.URL = g_ini:GetValue("Webhook","URL", "")
		g_Config.PFP = g_ini:GetValue("Webhook", "PFP", "https://newsletter.cuberite.org/assets/cuberite.png")
		g_Config.log_world_start = g_ini:GetValueB("Log", "WorldStart", true)
		g_Config.log_chat = g_ini:GetValueB("Log", "Chat", true)
		g_Config.log_join = g_ini:GetValueB("Log", "PlayerJoin", true)
		g_Config.log_disconnect = g_ini:GetValueB("Log", "PlayerDisconnect", true)
		g_Config.log_command = g_ini:GetValueB("Log", "CommandExecution", true)
		g_Config.log_plugins_loaded = g_ini:GetValueB("Log", "PluginsLoaded", true)
		g_Config.log_player_spawn = g_ini:GetValueB("Log", "PlayerSpawned", false)

    end

end


-- HOOKS HANDLING


function MyOnWorldStarted(World)
	local payload = ConstructEmbedPayload("World loaded", World:GetName(), "SERVER", 65280)
	SendWebhook(payload)
end


function MyOnChat(Player, Message)
	local payload = ConstructEmbedPayload("Chat log", Message, Player:GetName())
	SendWebhook(payload)
end


function MyOnPlayerJoined(Player)
	local payload = ConstructEmbedPayload("Player joined", Player:GetName(), "SERVER", 65280)
	SendWebhook(payload)
end


function MyOnDisconnect(Client, Reason)
	local payload = ConstructEmbedPayload("Player left", Client:GetPlayer():GetName(), "SERVER", 16711680)
	SendWebhook(payload)
end


function MyOnExecuteCommand(Player, CommandSplit, EntireCommand)
	if (Player==nil) then
		local payload = ConstructEmbedPayload("Command executed", EntireCommand, "Console", 16776960)
		SendWebhook(payload)
	else
		local payload = ConstructEmbedPayload("Command executed", EntireCommand, Player:GetName(), 16776960)
		SendWebhook(payload)
	end
	return false
end


function MyOnPluginsLoaded()
	local payload = ConstructEmbedPayload("Plugins loaded", "", "SERVER", 255)
	SendWebhook(payload)
end


function MyOnPlayerSpawned(Player)
	local payload = ConstructEmbedPayload("Player spawned", Player:GetName(), "SERVER", 65280)
	SendWebhook(payload)
end


-- COMMANDS


function Log(Split, Player)
	if (#Split < 2) then
		-- Confirm there is at least one argument
		Player:SendMessageInfo("Usage: /log [text]")
		return true
	end


	local text_table = {}

	for i = 2, #Split do
		table.insert(text_table, Split[i])
	end

	local log_text = table.concat(text_table, " ")

	-- local payload = SimplePayload(log_text, Player:GetName())
	-- SendWebhook(payload)
	local payload = ConstructEmbedPayload("Log", log_text, Player:GetName())
	SendWebhook(payload)
	Player:SendMessageSuccess("Message sent!")

	return true
end


-- FUNCTIONS


function SendWebhook(payload)
	-- Defualt name
	-- Get the webhook url
	local url  = g_Config.URL

	local headers  = {["Content-Type"]="application/json"}

	local callback  =  function (a_Body, a_Data)
		if (a_Body) then
			-- Response received correctly, a_Body contains the entire response body,
			-- a_Data is a dictionary-table of the response's HTTP headers
			if (a_Body==nil or a_Body=="") then
				LOG("Webhook request successful, with payload: '" ..payload.."'")
			else
				LOG("Response from webhook request: " .. (a_Body) .. "")
			end
		else
			error(a_Data)
		end
	end

	-- Make the request
	cUrlClient:Post(url, callback, headers, payload)
end

function SimplePayload(content, username)
	local username = username or "MINECRAFT SERVER"
	local avatar = [["]] .. g_Config.PFP .. [["]]
	local payload = [[ {"username":"]] .. username .. [[","avatar_url":]] .. avatar .. [[,"content":"]] .. content .. [[", "allowed_mentions": {"parse": []} } ]]
	return payload
end

function ConstructEmbedPayload(title, description, author, color)
	author = author or "SERVER"
	color = color or 0
	local embed_footer = [[{"text":"]] .. author .. [["}]]
	local embed = [[{"title":"]] .. title ..[[", "description":"]] .. description .. [[", "footer":]] .. embed_footer ..[[, "color":]] .. color .. [[}]]

	local username = "MINECRAFT SERVER"
	local avatar = [["]] .. g_Config.PFP .. [["]]
	local payload = '{"username":"' .. username .. '","avatar_url":' .. avatar .. ',"embeds":[' .. embed .. '], "allowed_mentions": {"parse": []} }'
	return payload
end