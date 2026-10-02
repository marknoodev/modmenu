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

local _ESP = {}

local boxes = {}
local running = false

local ESP_COLOR = Color3.fromRGB(0, 0, 139)
local DUMMIES_PATH = workspace:WaitForChild("TrainingArea"):WaitForChild("Dummies")

local function createBox()
	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Color = ESP_COLOR
	box.Filled = false
	box.Transparency = 1
	box.Visible = false
	return box
end

local function getRoot(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum then return hum.RootPart end
	return model:FindFirstChild("HumanoidRootPart")
end

local function refreshModels()
	for _, model in ipairs(DUMMIES_PATH:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			if not boxes[model] then
				boxes[model] = createBox()
			end
		end
	end

	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") and Player.Character ~= model then
			if not boxes[model] then
				boxes[model] = createBox()
			end
		end
	end

	for model, box in pairs(boxes) do
		if not model.Parent or not model:FindFirstChildOfClass("Humanoid") then
			box:Remove()
			boxes[model] = nil
		end
	end
end

local function clearBoxes()
	for model, box in pairs(boxes) do
		pcall(function() box:Remove() end)
		boxes[model] = nil
	end
	table.clear(boxes)
end

function ESP(enabled)
	ClearConnections(_ESP)

	if enabled then
		running = true
		AddConnection(RunService.RenderStepped:Connect(function()
			if not running then return end

			refreshModels()

			for model, box in pairs(boxes) do
				local root = getRoot(model)
				if not root then
					box.Visible = false
					continue
				end

				local topWorld = root.Position + Vector3.new(0, 3, 0)
				local bottomWorld = root.Position - Vector3.new(0, 3, 0)

				local topScreen, topOn = Camera:WorldToViewportPoint(topWorld)
				local bottomScreen, bottomOn = Camera:WorldToViewportPoint(bottomWorld)

				if topOn and bottomOn then
					local height = math.abs(bottomScreen.Y - topScreen.Y)
					local width = height / 2
					local x = topScreen.X - width / 2
					local y = topScreen.Y

					box.Size = Vector2.new(width, height)
					box.Position = Vector2.new(x, y)
					box.Visible = true
				else
					box.Visible = false
				end
			end
		end), _ESP)
	else
		running = false
		clearBoxes()
	end
end

local _HoldAimbot = {}

local HoldAimbotRadius = 50
local HoldAimbotSmoothness = 0.3
local HoldAimbotColor = Color3.fromRGB(255)

local holdAimbotRunning = false
local holdAimbotCircle = nil
local holdAimbotAiming = false

local function getHead(model)
	local head = model:FindFirstChild("Head")
	if head and head:IsA("BasePart") then return head end

	local hum = model:FindFirstChildOfClass("Humanoid")
	if hum and hum.RootPart then return hum.RootPart end

	return nil
end

local function hasLineOfSight(targetPart)
	local origin = Camera.CFrame.Position
	local direction = (targetPart.Position - origin)
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.FilterDescendantsInstances = { Player.Character, targetPart.Parent }

	local result = workspace:Raycast(origin, direction, rayParams)
	if result then
		return false
	end
	return true
end

local function findTargetOnCircle()
	local viewport = Camera.ViewportSize
	local center = Vector2.new(viewport.X / 2, viewport.Y / 2)

	local bestTarget = nil
	local bestDistance = math.huge

	for _, model in ipairs(workspace:GetChildren()) do
		if model:IsA("Model")
			and model ~= Player.Character
			and model:FindFirstChildOfClass("Humanoid")
			and model.Humanoid.Health > 0
		then
			local head = getHead(model)
			if head then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local screenVec = Vector2.new(screenPos.X, screenPos.Y)
					local distance = (screenVec - center).Magnitude

					if distance <= HoldAimbotRadius and distance < bestDistance then
						if hasLineOfSight(head) then
							bestDistance = distance
							bestTarget = head
						end
					end
				end
			end
		end
	end

	for _, model in ipairs(DUMMIES_PATH:GetChildren()) do
		if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid") then
			local head = getHead(model)
			if head then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local screenVec = Vector2.new(screenPos.X, screenPos.Y)
					local distance = (screenVec - center).Magnitude

					if distance <= HoldAimbotRadius and distance < bestDistance then
						if hasLineOfSight(head) then
							bestDistance = distance
							bestTarget = head
						end
					end
				end
			end
		end
	end

	return bestTarget
end

local function aimCameraTo(position)
	local cameraPos = Camera.CFrame.Position
	local direction = (position - cameraPos).Unit
	local targetCFrame = CFrame.new(cameraPos, cameraPos + direction)

	if HoldAimbotSmoothness >= 1 then
		Camera.CFrame = targetCFrame
	else
		local alpha = 1 - HoldAimbotSmoothness
		Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, alpha)
	end
end

local function updateCircle()
	if holdAimbotCircle then
		local viewport = Camera.ViewportSize
		holdAimbotCircle.Position = Vector2.new(viewport.X / 2, viewport.Y / 2)
		holdAimbotCircle.Radius = HoldAimbotRadius
	end
end

function HoldAimbot(enabled)
	ClearConnections(_HoldAimbot)

	if enabled then
		holdAimbotRunning = true

		holdAimbotCircle = Drawing.new("Circle")
		holdAimbotCircle.Thickness = 1
		holdAimbotCircle.Color = HoldAimbotColor
		holdAimbotCircle.Filled = false
		holdAimbotCircle.Transparency = 1
		holdAimbotCircle.Radius = HoldAimbotRadius
		holdAimbotCircle.NumSides = 60
		holdAimbotCircle.Visible = true
		updateCircle()

		AddConnection(Camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateCircle), _HoldAimbot)

		AddConnection(RunService.RenderStepped:Connect(function()
			if not holdAimbotRunning then return end

			updateCircle()

			if not holdAimbotAiming then return end

			local target = findTargetOnCircle()
			if target then
				aimCameraTo(target.Position)
			end
		end), _HoldAimbot)

		AddConnection(UserInputService.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.KeyCode == Enum.KeyCode.Q then
				holdAimbotAiming = true
			end
		end), _HoldAimbot)

		AddConnection(UserInputService.InputEnded:Connect(function(input, gp)
			if input.KeyCode == Enum.KeyCode.Q then
				holdAimbotAiming = false
			end
		end), _HoldAimbot)

	else
		holdAimbotRunning = false
		holdAimbotAiming = false

		if holdAimbotCircle then
			pcall(function() holdAimbotCircle:Remove() end)
			holdAimbotCircle = nil
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
	Flag = "ESPFlag",
	Callback = function(state)
		ESP(state)
	end,
})

local Player_Tab = Window:Tab({
	Title = "Player",
	Icon = "user"
})

local HoldAimbot_Section = Player_Tab:Section({
	Title = "Hold Aimbot Config",
	Box = true,
	BoxBorder = true,
})

local HoldAimbot_Toggle = HoldAimbot_Section:Toggle({
	Title = "Hold Aimbot",
	Callback = function(state)
		HoldAimbot(state)
	end,
})

local HoldAimbot_Smoothness_Slider = HoldAimbot_Section:Slider({
	Title = "Smoothness",
	Step = 1,
	Flag = "HoldAimbotSmoothness",

	Value = {
		Min = 0,
		Max = 100,
		Default = 30,
	},

	Callback = function(value)
		HoldAimbotSmoothness = value / 100
	end,
})

local HoldAimbot_Slider = HoldAimbot_Section:Slider({
	Title = "Radius",
	Step = 1,
	Flag = "HoldAimbotRadius",

	Value = {
		Min = 50,
		Max = 150,
		Default = 50,
	},

	Callback = function(value)
		HoldAimbotRadius = value
	end,
})

--// CONFIG \\--
local Config_Tab = Window:Tab({
	Title = "Settings",
	Icon = "settings"
})

Config_Tab:Keybind({
	Title = "Show/Hide Menu",
	Value = "Insert",
	Flag = "ShowHideMenuKeybind",
	Callback = function(v)
		Window:SetToggleKey(Enum.KeyCode[v])
	end,
})
