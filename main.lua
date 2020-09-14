function Initialize(Plugin)
	Plugin:SetName("DerpyPluginThatBlowsPeopleUp")
	Plugin:SetVersion(9001)

	cPluginManager.BindCommand("/explode", "derpyplugin.explode", Explode, " ~ Explode a player");

	cPluginManager:AddHook(cPluginManager.HOOK_COLLECTING_PICKUP, OnCollectingPickup)

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function Explode(Split, Player)
	if (#Split ~= 2) then
		-- There was more or less than one argument (excluding the "/explode" bit)
		-- Send the proper usage to the player and exit
		Player:SendMessage("Usage: /explode [playername]")
		return true
	end

	-- Create a callback ExplodePlayer with parameter Explodee, which Cuberite calls for every player on the server
	local HasExploded = false
	local ExplodePlayer = function(Explodee)
		-- If the player name matches exactly
		if (Explodee:GetName() == Split[2]) then
			-- Create an explosion of force level 2 at the same position as they are
			-- see API docs for further details of this function
			Player:GetWorld():DoExplosionAt(10, Explodee:GetPosX(), Explodee:GetPosY(), Explodee:GetPosZ(), false, esPlugin)
			Player:SendMessageSuccess(Split[2] .. " was successfully exploded")
			HasExploded = true;
			return true -- Signalize to Cuberite that we do not need to call this callback for any more players
		end
	end

	-- Tell Cuberite to loop through all players and call the callback above with the Player object it has found
	cRoot:Get():FindAndDoWithPlayer(Split[2], ExplodePlayer)

	if not(HasExploded) then
		-- We have not broken out so far, therefore, the player must not exist, send failure
		Player:SendMessageFailure(Split[2] .. " was not found")
	end

	return true
end

function OnCollectingPickup(Player, Pickup) -- Again, see the API docs for parameters of all hooks. In this case, it is a Player and Pickup object
	if (Player:GetClientHandle():GetPing() > 100) then -- Get ping of player, in milliseconds
		return true -- Discriminate against high latency - you don't get drops :D
	else
		return false -- You do get the drops! Yay~
	end
end