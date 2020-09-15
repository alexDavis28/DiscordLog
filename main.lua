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
	-- if (g_Config.log_chat) then
	-- 	cPluginManager:AddHook(cPluginManager.HOOK_CHAT, MyOnChat);
	-- end

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
		g_Config.log_chat = g_ini:GetValueSetB("Log", "Chat", true)

        g_ini:WriteFile(iniFile);
	else
		g_Config.URL = g_ini:GetValue("Webhook","URL", "")
		g_Config.PFP = g_ini:GetValue("Webhook", "PFP", "https://newsletter.cuberite.org/assets/cuberite.png")
		g_Config.log_chat = g_ini:GetValueB("Log", "Chat", true)

    end

end


-- HOOKS


-- function MyOnChat(Player, Message)



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

	local payload = SimplePayload(log_text, Player:GetName())
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