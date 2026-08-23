local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = game.Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function AddConnection(conn, tbl)
	if conn then
		table.insert(tbl, conn)
	end

	return conn
end

local function ClearConnections(tbl)
	for _, conn in ipairs(tbl) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(tbl)
end

local AimbotGui = nil
local AimbotCircle = nil

local AimbotConns = {}

local foundChar = nil

local AimbotRadiusValue = 200

local function setAimbotGui()
	if AimbotGui then return end

	AimbotGui = Instance.new("ScreenGui")
	AimbotGui.IgnoreGuiInset = true
	AimbotGui.Parent = Player:WaitForChild("PlayerGui")

	AimbotCircle = Instance.new("Frame")
	AimbotCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	AimbotCircle.Size = UDim2.fromOffset(AimbotRadiusValue, AimbotRadiusValue)
	AimbotCircle.Position = UDim2.fromScale(0.5, 0.5)
	AimbotCircle.AnchorPoint = Vector2.new(0.5, 0.5)
	AimbotCircle.BackgroundTransparency = 1
	AimbotCircle.Parent = AimbotGui

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(1, 0)
	Corner.Parent = AimbotCircle

	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color3.fromRGB(255, 0, 0)
	Stroke.Thickness = 2
	Stroke.Parent = AimbotCircle
end

local function HasLineOfSight(character)
	if not character then return false end

	local hrp = character:FindFirstChild("HumanoidRootPart")
	local head = character:FindFirstChild("Head")

	if not hrp and not head then
		return false
	end

	local targetParts = {}
	if head then table.insert(targetParts, head) end
	if hrp then table.insert(targetParts, hrp) end

	for _, part in ipairs(targetParts) do
		local origin = Camera.CFrame.Position
		local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude

		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		params.FilterDescendantsInstances = {
			Player.Character,
			part
		}

		local result = workspace:Raycast(origin, direction, params)

		if not result then
			return true, part
		end

		if result.Instance and result.Instance:IsDescendantOf(character) then
			return true, part
		end
	end

	return false, nil
end

local function findTargetInCircle()
	if not AimbotCircle then return nil end

	local circleCenter = Camera.ViewportSize / 2
	local radius = AimbotCircle.AbsoluteSize.X / 2

	local closestDistance = radius
	local closestTarget = nil

	for _, player in game.Players:GetPlayers() do
		if player == Player then continue end

		local character = player.Character
		if not character then continue end

		local hrp = character:FindFirstChild("HumanoidRootPart")
		local hum = character:FindFirstChild("Humanoid")

		if not hrp or not hum or hum.Health <= 0 then continue end

		local bodyParts = {}

		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				table.insert(bodyParts, part)
			end
		end

		local bestDist = math.huge
		local partFound = false

		for _, part in ipairs(bodyParts) do
			local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)

			if onScreen and screenPos.Z > 0 then
				local partPos2D = Vector2.new(screenPos.X, screenPos.Y)
				local distFromCenter = (partPos2D - circleCenter).Magnitude

				if distFromCenter <= radius then
					local hasLOS = HasLineOfSight(character)

					if hasLOS then
						partFound = true

						if distFromCenter < bestDist then
							bestDist = distFromCenter
						end
					end
				end
			end
		end

		if partFound and bestDist < closestDistance then
			closestDistance = bestDist
			closestTarget = character
		end
	end

	return closestTarget
end

function Aimbot(enabled)
	if enabled then
		AddConnection(RunService.Heartbeat:Connect(function()
			if Player.PlayerGui:FindFirstChild("GunOverlay") then
				if not AimbotGui then
					setAimbotGui()
				end

				foundChar = findTargetInCircle()

			else
				foundChar = nil

				if AimbotGui then
					AimbotGui:Destroy()
					AimbotGui = nil
				end
			end
		end), AimbotConns)

		AddConnection(UserInputService.InputBegan:Connect(function(i, p)
			if p then return end

			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				if foundChar then
					local hrp = foundChar:FindFirstChild("HumanoidRootPart")
					if hrp then
						local head = foundChar:FindFirstChild("Head")
						local targetPos = head.Position
						Camera.CFrame = CFrame.lookAt(
							Camera.CFrame.Position,
							targetPos
						)
					end
				end
			end
		end), AimbotConns)
	else
		ClearConnections(AimbotConns)

		if AimbotGui then
			AimbotGui:Destroy()
		end

		AimbotGui = nil
		AimbotCircle = nil

		foundChar = nil
	end
end

local ESPConns = {}

function ESP(enabled)
	local defaultESPName = "Teegnomish (referencia ao saco btw >.<)"
	
	if enabled then
		local function Effect(char)
			if char == game.Players.LocalPlayer.Character then return end
			
			for _, obj in char:GetChildren() do
				if obj:IsA("Highlight") then
					if obj.Name ~= defaultESPName then
						obj:Destroy()
					elseif obj.Name == defaultESPName then
						return
					end
				end
			end
			
			local highlight = Instance.new("Highlight", char)
			highlight.Name = defaultESPName
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		end
		
		while next(ESPConns) do
			task.wait(.1)
			
			for _, plr in game.Players:GetPlayers() do
				if plr.Character then
					Effect(plr.Character)
				end
			end
		end
	else
		ClearConnections(ESPConns)

		for _, plr in game.Players:GetPlayers() do
			if plr.Character then
				if plr.Character:FindFirstChild(defaultESPName) then
					plr.Character[defaultESPName]:Destroy()
				end
			end
		end
	end
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "Seitium Hub",
	Icon = "eye",
	Author = "all scripts made by infernus",
})

Window:SetToggleKey(Enum.KeyCode.Insert)

local Visuals_Tab = Window:Tab({
	Title = "Visuals",
	Icon = "eye"
})

local ESP_Toggle = Visuals_Tab:Toggle({
	Title = "ESP",
	Callback = function(state)
		ESP(state)
	end,
})

local Player_Tab = Window:Tab({
	Title = "Player",
	Icon = "user"
})

local Aimbot_Section = Player_Tab:Section({
	Title = "Aimbot Config",
	Box = true,
	BoxBorder = true,
	Opened = true
})

local Aimbot_Toggle = Aimbot_Section:Toggle({
	Title = "Aimbot",
	Callback = function(state)
		Aimbot(state)
	end,
})

local Aimbot_Radius = Aimbot_Section:Slider({
	Title = "Radius Size",
	Value = {
		Min = 50,
		Max = 500,
		Default = 200
	},
	Callback = function(value)
		AimbotRadiusValue = value

		if AimbotGui then
			AimbotCircle.Size = UDim2.fromOffset(AimbotRadiusValue, AimbotRadiusValue)
		end
	end,
})
