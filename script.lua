-- Detector
local placeId = 10449761463
if game.PlaceId ~= placeId then return end

-- Services
local uis = game:GetService("UserInputService")
local cp = game:GetService("ContentProvider")
local rs = game:GetService("RunService")

-- Player Variables
local Player = game.Players.LocalPlayer

if Player.PlayerGui:FindFirstChild("ZM V1.3") then return end

local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

-- Instances
local ScreenGui = Instance.new("ScreenGui")
local bg = Instance.new("Frame")
local extraFolder = Instance.new("Folder")

ScreenGui.Name = "ZM V1.3"
ScreenGui.Enabled = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
ScreenGui.ResetOnSpawn = false

bg.Visible = false
bg.Name = "bg"
bg.Parent = ScreenGui
bg.AnchorPoint = Vector2.new(0.5, 0.5)
bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bg.BackgroundTransparency = .7
bg.BorderColor3 = Color3.fromRGB(0)
bg.BorderSizePixel = 0
bg.Position = UDim2.new(0.5, 0, 0.5, 0)
bg.Size = UDim2.new(1, 0, 1, 0)

extraFolder.Name = "Extras"
extraFolder.Parent = ScreenGui

function createMenu(name, sizeX)
	local Frame = Instance.new("Frame")
	local Name = Instance.new("TextLabel")
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	local hider = Instance.new("TextButton")
	local mods = Instance.new("Folder")
	local holder = Instance.new("Frame")
	local UIGridLayout = Instance.new("UIGridLayout")
	local UIDragDetector = Instance.new("UIDragDetector")

	-- Properties
	Frame.Name = name
	Frame.Parent = ScreenGui
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(sizeX, 0, 0.5, 0)
	Frame.Size = UDim2.new(0.17, 0, 0.7, 0)

	Name.Parent = Frame
	Name.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	Name.BorderSizePixel = 0
	Name.Size = UDim2.new(1, 0, 0.1, 0)
	Name.Font = Enum.Font.Sarpanch
	Name.Text = name
	Name.TextColor3 = Color3.fromRGB(255, 255, 255)
	Name.TextScaled = true
	Name.TextWrapped = true
	UITextSizeConstraint.Parent = Name
	UITextSizeConstraint.MaxTextSize = 23

	hider.Name = "hider"
	hider.Parent = Frame
	hider.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	hider.BackgroundTransparency = 1
	hider.Position = UDim2.new(0.79, 0, 0, 0)
	hider.Size = UDim2.new(0.21, 0, 0.1, 0)
	hider.ZIndex = 2
	hider.AutoButtonColor = false
	hider.Font = Enum.Font.Sarpanch
	hider.Text = "-"
	hider.TextColor3 = Color3.fromRGB(255, 255, 255)
	hider.TextSize = 23

	mods.Name = "mods"
	mods.Parent = Frame
	UIDragDetector.Parent = Frame

	holder.Name = "holder"
	holder.Parent = Frame
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(0, 0, 0.1, 0)
	holder.Size = UDim2.new(1, 0, 0.9, 0)

	UIGridLayout.Parent = holder
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 0)
	UIGridLayout.CellSize = UDim2.new(1, 0, 0.07, 0)

	-- Hider Func

	hider.MouseButton1Down:Connect(function()
		local transparent = Frame.BackgroundTransparency == 0
		Frame.BackgroundTransparency = transparent and 1 or 0
		UIDragDetector.Enabled = not transparent

		for _, tbs in pairs(holder:GetChildren()) do
			if tbs:IsA("TextButton") then
				tbs.Visible = not transparent
			end
		end
	end)
end

-- VARIABLES
local cam = workspace.CurrentCamera
local Live = workspace:WaitForChild("Live")

local sounds = {}

local kjTrack

local kjAnim = Instance.new("Animation")
kjAnim.AnimationId = "rbxassetid://77727115892579"

local vKConns = {}
local vKProceed = true
local oldPos

local cVConns = {}

local movesTbl = { -- false = ready
	["1"] = false,
	["2"] = false,
	["3"] = false,
	["4"] = false
}

local movesConnector = {}
local canStartVK = false

local vKEnabled = false

local oldSelectedAnim = nil
local currentTb = nil -- if multiselection is disabled

-- FUNCTIONS

local function createExtraButton(name, parent, multiSelection, code) -- idk if i will work futurely on No Toggle version. it only works with toggle btw
	for _, v in pairs(parent:GetChildren()) do
		if v:IsA("TextButton") then
			if v.Text == name then
				return
			end
		end
	end

	local tb = Instance.new("TextButton")
	tb.Parent = parent
	tb.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	tb.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tb.BorderSizePixel = 0
	tb.AutoButtonColor = false
	tb.Font = Enum.Font.Sarpanch
	tb.Text = tostring(name)
	tb.TextColor3 = Color3.fromRGB(255, 255, 255)
	tb.TextScaled = true
	tb.TextWrapped = true
	tb:SetAttribute("activated", false)

	tb.MouseButton1Down:Connect(function()
		if tb:GetAttribute("activated") then
			tb:SetAttribute("activated", false) -- disabled
			tb.BackgroundColor3 = Color3.fromRGB(44, 44, 44)

			if code then code(tb) end
		else
			if multiSelection then
				tb:SetAttribute("activated", true)
				tb.BackgroundColor3 = Color3.fromRGB(0, 163, 166)
			else
				if currentTb then
					if currentTb ~= tb then
						currentTb:SetAttribute("activated", false)
						currentTb.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
					end
				end

				currentTb = tb
				currentTb:SetAttribute("activated", true)
				currentTb.BackgroundColor3 = Color3.fromRGB(0, 163, 166)
			end

			if code then code(tb) end
		end
	end)
end

local function createModButton(name, category, toggle, code, extraCode)
	local btn = Instance.new("TextButton")

	for _, cat in pairs(ScreenGui:GetDescendants()) do
		if cat.Name == category then
			btn.Parent = cat:FindFirstChild("holder")
		end
	end

	btn.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Sarpanch
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.AutoButtonColor = false
	btn:SetAttribute("activated", false)

	btn.MouseButton1Down:Connect(function()
		if toggle then
			if btn:GetAttribute("activated") then
				btn:SetAttribute("activated", false) -- disabled
				btn.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
				code(false)
			else
				btn:SetAttribute("activated", true) -- enabled
				btn.BackgroundColor3 = Color3.fromRGB(0, 163, 166)
				code(true)
			end
		else
			if btn.BackgroundColor3 == Color3.fromRGB(127, 0, 0) then return end
			btn.BackgroundColor3 = Color3.fromRGB(127, 0, 0)

			code()
		end
	end)

	if extraCode then
		local ScrollingFrame = Instance.new("ScrollingFrame")
		local TextLabel = Instance.new("TextLabel")
		local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
		local UIGridLayout = Instance.new("UIGridLayout")
		local extraHider = Instance.new("TextButton")

		ScrollingFrame.Name = tostring(name)
		ScrollingFrame.Visible = false
		ScrollingFrame.Parent = extraFolder
		ScrollingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
		ScrollingFrame.Size = UDim2.new(0.17, 0, 0.7, 0)
		ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		ScrollingFrame.ScrollBarThickness = 0
		ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

		TextLabel.Parent = ScrollingFrame
		TextLabel.BackgroundColor3 = Color3.fromRGB(38, 38, 38)
		TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
		TextLabel.BorderSizePixel = 0
		TextLabel.Size = UDim2.new(1, 0, 0.04, 0)
		TextLabel.Font = Enum.Font.Sarpanch
		TextLabel.Text = "Extra"
		TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TextLabel.TextScaled = true
		TextLabel.TextWrapped = true

		UITextSizeConstraint.Parent = TextLabel
		UITextSizeConstraint.MaxTextSize = 33

		UIGridLayout.Parent = ScrollingFrame
		UIGridLayout.FillDirection = Enum.FillDirection.Horizontal
		UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
		UIGridLayout.CellSize = UDim2.new(1, 0, 0.07, 0)

		extraHider.Name = "extraHider"
		extraHider.Parent = TextLabel
		extraHider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		extraHider.BackgroundTransparency = 1
		extraHider.BorderSizePixel = 0
		extraHider.Position = UDim2.new(0.8, 0, 0, 0)
		extraHider.Size = UDim2.new(0.2, 0, 1, 0)
		extraHider.Font = Enum.Font.Sarpanch
		extraHider.Text = "-"
		extraHider.TextColor3 = Color3.fromRGB(255, 255, 255)
		extraHider.TextScaled = true
		extraHider.TextWrapped = true

		extraHider.MouseButton1Down:Connect(function()
			ScrollingFrame.Visible = false
			bg.Visible = false

			-- need to add background working

			for _, v in pairs(ScreenGui:GetChildren()) do
				if v:IsA("Frame") then
					if v.Name ~= "bg" then
						v.Visible = true
					end
				end
			end
		end)

		btn.MouseButton2Down:Connect(function()
			ScrollingFrame.Visible = not ScrollingFrame.Visible
			bg.Visible = true

			for _, v in pairs(ScreenGui:GetChildren()) do
				if v:IsA("Frame") then
					if v.Name ~= "bg" then
						v.Visible = not ScrollingFrame.Visible
					end
				end
			end

			extraCode()
		end)
	end
end

local function cleanupConnections()
	for _, connection in ipairs(movesConnector) do
		connection:Disconnect()
	end
	movesConnector = {}
end

local function setupMoves()
	cleanupConnections()

	local moves = Player.PlayerGui.Hotbar.Backpack.Hotbar

	for _, button in pairs(moves:GetDescendants()) do
		if button:IsA("TextButton") then
			if movesTbl[button.Name] ~= nil then
				movesConnector[#movesConnector+1] = button.DescendantAdded:Connect(function(desc)
					if desc.Name == "Cooldown" then
						movesTbl[button.Name] = true
						print(button.Name .. " is on cooldown")

						if button.Name == "1" and movesTbl["1"] == true then
							task.spawn(function() -- only flowing water can void kill
								canStartVK = true
								task.wait(2)
								canStartVK = false
							end)
						end
					end
				end)

				movesConnector[#movesConnector+1] = button.DescendantRemoving:Connect(function(desc)
					if desc.Name == "Cooldown" then
						movesTbl[button.Name] = false
						print(button.Name .. " is ready")
					end
				end)
			end
		end
	end
end

-- when starting
if Player.Character then
	setupMoves()
end

-- Toggle With T Key
uis.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

-- MAIN
createMenu("Combat", .1)
createMenu("Player", .3)
createMenu("Visuals", .5)
createMenu("Miscellaneous", .7)

-- TP Backwards
local tpBackwardsConnection
createModButton("TP Backwards", "Player", true, function(isEnabled)
	if isEnabled then
		tpBackwardsConnection = uis.InputBegan:Connect(function(i, p)
			if p then return end

			if i.KeyCode == Enum.KeyCode.R then
				if Character and Character:FindFirstChild("HumanoidRootPart") then
					local root = Character.HumanoidRootPart
					local look = root.CFrame.LookVector
					root.CFrame = root.CFrame + (-look * 26)
				end
			end
		end)
	elseif tpBackwardsConnection then
		tpBackwardsConnection:Disconnect()
		tpBackwardsConnection = nil
	end
end)

-- Void Kill

local vKFlowingWater = false

local function vKCode()
	if not vKEnabled then return end

	vKConns[#vKConns+1] = Character.DescendantAdded:Connect(function(d)
		if d.Name == "Flowing Water" then
			vKFlowingWater = true
			task.wait(1)
			vKFlowingWater = false
		end
	end)

	vKConns[#vKConns+1] = Character.ChildAdded:Connect(function(c)	
		if c.Name == "ForceField" then

			if not canStartVK then return end			

			local hf = Character:FindFirstChild("HunterFists")

			if hf == nil then return end		
			if not vKFlowingWater then return end

			task.spawn(function()
				task.wait(1.3)
				oldPos = HumanoidRootPart.CFrame

				if not vKProceed then return end

				HumanoidRootPart.CFrame = CFrame.new(100, -450, 100)
				task.wait(.5)
				HumanoidRootPart.CFrame = oldPos
			end)
		elseif c.Name == "Effects" then
			vKProceed = false
		end
	end)

	vKConns[#vKConns+1] = Character.ChildRemoved:Connect(function(c)
		if c.Name == "Effects" then
			vKProceed = true
		end
	end)
end

createModButton("Void Kill", "Combat", true, function(isEnabled)
	if isEnabled then
		vKEnabled = true
		vKCode()
	elseif vKConns then
		vKEnabled = false
		for _, conn in pairs(vKConns) do
			if conn then
				conn:Disconnect()
			end
		end
		vKConns = {}
	end
end)

-- Force AutoRotate

local forceAutoRotateConnection

local function forceAutoRotateCode()
	if not Character:FindFirstChild("Ragdoll") then
		Humanoid.AutoRotate = true
	end

	forceAutoRotateConnection = Humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function()
		if not Character:FindFirstChild("Ragdoll") then
			Humanoid.AutoRotate = true
		end
	end)
end

createModButton("Force AutoRotate", "Player", true, function(isEnabled)
	if isEnabled then
		forceAutoRotateCode()
	elseif forceAutoRotateConnection then
		forceAutoRotateConnection:Disconnect()
		forceAutoRotateConnection = nil
	end
end)

-- Anti Block Debuff

local antiBlockDebuffConnection

local function antiBlockDebuffCode()
	if Character:GetAttribute("Blocking") == nil then
		Character:SetAttribute("Blocking", false)
	end

	antiBlockDebuffConnection = Character:GetAttributeChangedSignal("Blocking"):Connect(function()
		if Character:GetAttribute("Blocking") == true then
			Character:SetAttribute("Blocking", false)
		end
	end)
end

createModButton("Anti Block Debuff", "Player", true, function(isEnabled)
	if isEnabled then
		antiBlockDebuffCode()
	elseif antiBlockDebuffConnection then
		antiBlockDebuffConnection:Disconnect()
		antiBlockDebuffConnection = nil
	end
end)

-- No Cutscene

local cloneCamConnection
local function cloneCam()
	local newCam = Instance.new("Camera")
	newCam.CameraSubject = Humanoid
	newCam.CameraType = Enum.CameraType.Custom
	newCam.Parent = workspace

	cam = newCam

	cloneCamConnection = newCam:GetPropertyChangedSignal("CameraType"):Connect(function()
		newCam:Destroy()
		cloneCam()
	end)
end

local noCutsceneConnection
createModButton("No Cutscene", "Miscellaneous", true, function(isEnabled)
	if isEnabled then
		noCutsceneConnection = cam:GetPropertyChangedSignal("CameraType"):Connect(function()
			cam:Destroy()
			cloneCam()
		end)
	elseif noCutsceneConnection then
		noCutsceneConnection:Disconnect()
		noCutsceneConnection = nil
	end
end)

-- Counter Visualizer

local function createDCImage(chr)
	local BillboardGui = Instance.new("BillboardGui")
	local ImageLabel = Instance.new("ImageLabel")

	--Properties:
	BillboardGui.Name = "CounterV"
	BillboardGui.Parent = chr.Head
	BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	BillboardGui.Active = true
	BillboardGui.LightInfluence = 1
	BillboardGui.Size = UDim2.new(3, 0, 3, 0)
	BillboardGui.StudsOffset = Vector3.new(0, 4, 0)

	ImageLabel.Parent = BillboardGui
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Size = UDim2.new(1, 0, 1, 0)
	ImageLabel.Image = "rbxassetid://137607954274376"
end

local function cVReconnector(chr)
	cVConns[#cVConns+1] = chr.ChildAdded:Connect(function(c)
		if c.Name == "Counter" and c:IsA("Accessory") then
			createDCImage(chr)
		end
	end)

	cVConns[#cVConns+1] = chr.ChildRemoved:Connect(function(c)
		if c.Name == "Counter" and c:IsA("Accessory") then
			chr.Head:FindFirstChild("CounterV"):Destroy()
		end
	end)
end

createModButton("Counter Visualizer", "Visuals", true, function(isEnabled)
	if isEnabled then
		cVConns[#cVConns+1] = game.Players.PlayerAdded:Connect(function(plr)
			cVConns[#cVConns+1] = plr.CharacterAdded:Connect(function(chr)
				cVReconnector(chr)
			end)		
		end)

		for _, v in pairs(Live:GetChildren()) do		
			if game.Players:GetPlayerFromCharacter(v) and v ~= Character then		
				local plr = game.Players:GetPlayerFromCharacter(v)

				if v:FindFirstChild("Counter") then
					createDCImage(v)
				end

				cVConns[#cVConns+1] = plr.CharacterAdded:Connect(function(chr)
					cVReconnector(chr)
				end)

				cVConns[#cVConns+1] = v.ChildAdded:Connect(function(c)
					if c.Name == "Counter" and c:IsA("Accessory") then
						createDCImage(v)
					end
				end)

				cVConns[#cVConns+1] = v.ChildRemoved:Connect(function(c)
					if c.Name == "Counter" and c:IsA("Accessory") then
						v.Head:FindFirstChild("CounterV"):Destroy()
					end
				end)
			end
		end
	else
		for _, conn in pairs(cVConns) do
			if conn then
				conn:Disconnect()
			end
		end

		cVConns = {}

		for _, v in pairs(Live:GetChildren()) do
			if v.Head:FindFirstChild("CounterV") then
				v.Head.CounterV:Destroy()
			end
		end
	end
end)

-- KJ Flexworks Anim
local function createSounds()
	for _, s in pairs(sounds) do
		if s then
			s:Destroy()
		end
	end

	sounds = {}

	local kjphysic = Instance.new("Sound")
	kjphysic.SoundId = "rbxassetid://99126314241685"
	kjphysic.Volume = 2.5
	kjphysic.Parent = workspace

	local kjvoice = Instance.new("Sound")
	kjvoice.SoundId = "rbxassetid://128136381213631"
	kjvoice.Volume = 2.5
	kjvoice.Parent = workspace

	local kjmusic = Instance.new("Sound")
	kjmusic.SoundId = "rbxassetid://95410275491981"
	kjmusic.Volume = 2.5
	kjmusic.Parent = workspace

	table.insert(sounds, kjphysic)
	table.insert(sounds, kjvoice)
	table.insert(sounds, kjmusic)
end

local function kjSetup(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Animator = Humanoid:WaitForChild("Animator")

	kjTrack = Animator:LoadAnimation(kjAnim)

	createSounds()
end


createModButton("KJ Flexworks Anim", "Miscellaneous", false, function()
	kjSetup(Character)

	uis.InputBegan:Connect(function(input, processed)
		if processed then return end

		-- Stop KJ'S Anim
		if input.KeyCode == Enum.KeyCode.F then
			if kjTrack and kjTrack.IsPlaying then
				kjTrack:Stop()
			end

			for _, s in pairs(sounds) do
				if s.IsPlaying then
					s:Stop()
				end
			end
		end

		-- Start
		if input.KeyCode == Enum.KeyCode.Z then
			if kjTrack.IsPlaying then
				kjTrack:Stop()
				task.wait(0.05)
			end
			kjTrack:Play()

			for _, s in pairs(sounds) do
				if s.IsPlaying then
					s:Stop()
					task.wait(0.05)
				end
				s:Play()
			end
		end
	end)
end)

local Extras = ScreenGui:WaitForChild("Extras")

-- Damage Visualizer
local dmgVisualizerConns = {}

local function dmgVisualizerCode2(chr)
	if chr:GetAttribute("LastDamage") == nil then
		chr:SetAttribute("LastDamage", 0)
	end

	dmgVisualizerConns[#dmgVisualizerConns+1] = chr:GetAttributeChangedSignal("LastDamage"):Connect(function()
		local h = nil

		if chr:FindFirstChild("ImHighRn") == nil then

			h = Instance.new("Highlight")
			h.Name = "ImHighRn"
			h.FillColor = Color3.new(1)
			h.FillTransparency = .6
			h.OutlineColor = Color3.fromRGB(150)
			h.DepthMode = Enum.HighlightDepthMode.Occluded
			h.Parent = chr
		end

		local savedNumber = chr:GetAttribute("LastDamage")

		task.wait(.7)

		if savedNumber ~= chr:GetAttribute("LastDamage") then return end

		local highlight = chr:FindFirstChild("ImHighRn")
		if highlight then
			highlight:Destroy()
		end
	end)
end

local function dmgVisualizerCode()
	dmgVisualizerConns[#dmgVisualizerConns+1] = game.Players.PlayerAdded:Connect(function(plr)
		dmgVisualizerConns[#dmgVisualizerConns+1] = plr.CharacterAdded:Connect(function(chr)
			dmgVisualizerCode2(chr)	
		end)
	end)

	for _, chr in pairs(Live:GetChildren()) do
		if chr ~= Character then
			local plr = game.Players:GetPlayerFromCharacter(chr)
			if not plr then continue end -- "continue" just resets the actual round of for loop

			dmgVisualizerCode2(chr)

			dmgVisualizerConns[#dmgVisualizerConns+1] = plr.CharacterAdded:Connect(function(chr)
				dmgVisualizerCode2(chr)
			end)
		end
	end
end

local dmgVisualizer = false
createModButton("Damage Visualizer", "Visuals", true, function(isEnabled)
	if isEnabled then
		dmgVisualizer = true
		dmgVisualizerCode()
	elseif dmgVisualizerConns then
		dmgVisualizer = false
		
		for _, conn in pairs(dmgVisualizerConns) do
			if conn then
				conn:Disconnect()
			end
		end

		dmgVisualizerConns = {}

		for _, v in pairs(Live:GetChildren()) do
			if v:FindFirstChild("ImHighRn") then
				v.ImHighRn:Destroy()
			end
		end
	end
end)

-- Anti Death Counter

local antiDeathCounterConnection

local function antiDCCode()
	antiDeathCounterConnection = Character.ChildAdded:Connect(function(child)
		if child.Name == "NoRotateUltimate" then
			local oldPos = HumanoidRootPart.CFrame
			HumanoidRootPart.CFrame = CFrame.new(9999, 9999, 9999)	

			task.wait(.8)

			if Character:FindFirstChild("Freeze") then
				Character:FindFirstChild("Freeze"):Destroy()
			end

			if Character:FindFirstChild("NoRotate") then
				Character:FindFirstChild("NoRotate"):Destroy()
			end

			HumanoidRootPart.CFrame = oldPos
		end
	end)
end

createModButton("Anti Death Counter", "Player", true, function(isEnabled)
	if isEnabled then
		antiDCCode()
	elseif antiDeathCounterConnection then
		antiDeathCounterConnection:Disconnect()
		antiDeathCounterConnection = nil
	end
end)

-- Korblox + Headless

local oldChrMesh ={
	MeshId = 0,
	OverlayTextureId = 0
}

local cMesh = nil

local function korbloxHeadlessCode()
	if Character:FindFirstChild("Head") then -- Headless
		if Character:FindFirstChild("Head") then -- Headless
			local mesh = Instance.new("SpecialMesh", Character.Head)
			mesh.Name = "fHeadless"
			mesh.MeshType = Enum.MeshType.FileMesh
		end
	end

	for _, mesh in pairs(Character:GetChildren()) do
		if mesh:IsA("CharacterMesh") and mesh.BodyPart == Enum.BodyPart.RightLeg then
			cMesh = mesh
			oldChrMesh.MeshId = cMesh.MeshId -- if plr has an chrMesh then it will save it
			oldChrMesh.OverlayTextureId = cMesh.OverlayTextureId

			mesh.MeshId = 101851696
			mesh.OverlayTextureId = 101851254
		else
			cMesh = Instance.new("CharacterMesh", Character)
			cMesh.BodyPart = Enum.BodyPart.RightLeg
			cMesh.MeshId = 101851696
			cMesh.OverlayTextureId = 101851254
		end
		break
	end
end

createModButton("Korblox + Headless", "Visuals", true, function(isEnabled)
	if isEnabled then
		korbloxHeadlessCode()
	else
		cMesh.MeshId = oldChrMesh.MeshId
		cMesh.OverlayTextureId = oldChrMesh.OverlayTextureId
		cMesh:Destroy()

		cMesh = nil

		local head = Character:FindFirstChild("Head")
		local hMesh = head:FindFirstChild("fHeadless")

		if hMesh then
			hMesh:Destroy()
		end
	end
end)

-- M1 Reset

local m1ResetConns = {}

local function m1ResetCode()
	m1ResetConns[#m1ResetConns+1] = HumanoidRootPart.ChildAdded:Connect(function(c)
		if c.Name == "dodgevelocity" then
			m1ResetConns[#m1ResetConns+1] = rs.Heartbeat:Connect(function()
				if c then
					c.Name = "velocity"
				end
			end)
		end
	end)

	m1ResetConns[#m1ResetConns+1] = HumanoidRootPart.ChildRemoved:Connect(function(c)
		if c.Name == "velocity" then
			if m1ResetConns then
				m1ResetConns:Disconnect()
				m1ResetConns = nil
			end
		end
	end)
end

createModButton("M1 Reset", "Combat", true, function(isEnabled)
	if isEnabled then
		m1ResetCode()
	elseif m1ResetConns then
		for _, conn in pairs(m1ResetConns) do
			if conn then
				conn:Disconnect()
			end
		end

		m1ResetConns = {}
	end
end)

-- Always Can Jump
local alwaysJumpEnabled = false

createModButton("Always Can Jump", "Player", true, function(isEnabled)
	if isEnabled then
		alwaysJumpEnabled = true
		Humanoid.UseJumpPower = false
	else
		alwaysJumpEnabled = false
		Humanoid.UseJumpPower = true
	end
end)

-- Auto Mambo
local mamboSound = Instance.new("Sound", workspace)
mamboSound.Name = "Mambo"
mamboSound.SoundId = "rbxassetid://104825100882122"
mamboSound.Volume = .3

local tcs = game:GetService("TextChatService")
local channel = tcs.TextChannels.RBXGeneral

local mamboEnabled = false
local lastMambo = 0

local function mamboCode()
	local randomTime = math.random(30, 60)
	local now = tick()
	lastMambo = now

	task.wait(randomTime)

	if now ~= lastMambo then return end
	if not mamboEnabled then return end

	local mambo = workspace:FindFirstChild("Mambo")

	if mambo then
		mambo:Play()
	end

	channel:SendAsync("mambo")

	mamboCode()
end

createModButton("Auto Mambo", "Miscellaneous", true, function(isEnabled)
	if isEnabled then
		mamboEnabled = true
		mamboCode()
	else
		mamboEnabled = false
	end
end)

Player.CharacterAdded:Connect(function(char) -- my chrAdded
	task.wait(.1)

	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	Animator = Humanoid:WaitForChild("Animator")

	-- Reloads the previous ' ON ' options

	if alwaysJumpEnabled then
		Humanoid.UseJumpPower = false
	end

	if m1ResetConns then
		for _, conn in pairs(m1ResetConns) do
			if conn then
				conn:Disconnect()
			end
		end

		m1ResetConns = {}

		m1ResetCode()
	end

	if cMesh ~= nil then
		korbloxHeadlessCode("wonderifixedit")
	end

	if antiDeathCounterConnection then
		antiDCCode()
	end

	if forceAutoRotateConnection then -- it means it is on
		forceAutoRotateCode()
	end

	if antiBlockDebuffConnection then
		antiBlockDebuffCode()
	end

	if vKConns then
		for _, conn in pairs(vKConns) do
			if conn then
				conn:Disconnect()
			end
		end

		vKConns = {}
		vKCode()
	end

	setupMoves()

	kjSetup(char)

	if dmgVisualizer then
		for _, conn in pairs(dmgVisualizerConns) do
			if conn then
				conn:Disconnect()
			end
		end

		dmgVisualizerCode()
	end
end)
