g_PluginInfo =
{
	Name = "DiscordLog",
	Date = "2020-09-14",
	Description = "Cuberite plugin to log to a discord webhook",

	-- The following members will be documented in greater detail later:
	AdditionalInfo = {
        {
            Title = "Chapter 1",
            Contents = "On first run DiscordLog.ini will be created. Add a webhook url in that and reload plugins."
        }
    },
	Commands = {
        ["/log"] =
        {
        HelpString = "Logs the given text to the webhook, with an optional username.",
        Permission = "DL.log",
        Handler = Log,
        ParameterCombinations =
        {
            {
                Params = "text",
                Help = "Logs the given text",
            },
            {
                Params = "text username",
                Help = "Logs the given text with the given",
            }
        }
        }
    },
    Permissions =
    {
        ["DL.log"] =
        {
            Description = "Allows the player to log messages over the webhook",
            RecommendedGroups = "admins",
        }
    }
	Categories = {},
}