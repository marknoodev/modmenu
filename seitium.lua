game.Loaded:Wait()

local Ids = {
	-- Blox Fruits
	[2753915549] = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/marknoodev/modmenu/refs/heads/main/bloxfruits.lua"))()
	end,
	
	-- The Strongest Battlegrounds
	[10449761463] = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/marknoodev/modmenu/refs/heads/main/tsb.lua"))()
	end,
	
	-- Flick
	[136801880565837] = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/marknoodev/modmenu/refs/heads/main/flick.lua"))()
	end,
}

local _script = Ids[game.PlaceId]

if _script then
	_script()
end
