function Initialize(Plugin)
	Plugin:SetName("DerpyPlugin")
	Plugin:SetVersion(1)

	cPluginManager.AddHook(cPluginManager.HOOK_PLAYER_MOVING, OnPlayerMoving)

	LOG("Initialised " .. Plugin:GetName() .. " v." .. Plugin:GetVersion())
	return true
end

function OnPlayerMoving(Player) -- See API docs for parameters of all hooks
	return true -- Prohibit player movement, see docs for whether a hook is cancellable
end
