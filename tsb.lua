local UserInputService = game:GetService("UserInputService")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart : Part = Character:FindFirstChild("HumanoidRootPart")
local Humanoid : Humanoid = Character:FindFirstChild("Humanoid")

local Animator : Animator = Humanoid:WaitForChild("Animator")

local Camera = workspace.CurrentCamera

local function AddConnection(conn, tbl)
	if conn then
		table.insert(tbl, conn)
	end

	return conn
end

local function ClearConnections(tbl)
	if next(tbl) then
		for _, conn in ipairs(tbl) do
			pcall(function()
				conn:Disconnect()
			end)
		end
		table.clear(tbl)
	end
end

local function isEnabled(obj)
	if typeof(obj) == "table" then
		return next(obj) and true or false
	elseif typeof(obj) == "boolean" then
		return obj
	end
end

local PreloadedIds = {}

local function PreloadImage(Id)
	if PreloadedIds[Id] then return end

	PreloadedIds[Id] = true

	local image = Instance.new("ImageLabel")
	image.Image = "rbxassetid://" .. Id

	ContentProvider:PreloadAsync({image})
end

-- Functions
local _AntiBlockDebuff = {}

function AntiBlockDebuff(enabled)
	ClearConnections(_AntiBlockDebuff)

	if enabled then
		if Character:GetAttribute("Blocking") == nil then
			Character:SetAttribute("Blocking", false)
		end

		AddConnection(Character:GetAttributeChangedSignal("Blocking"):Connect(function()
			if Character:GetAttribute("Blocking") == true then
				Character:SetAttribute("Blocking", false)
			end
		end), _AntiBlockDebuff)
	end
end

local _ForceAutoRotate = {}

function ForceAutoRotate(enabled)
	ClearConnections(_ForceAutoRotate)

	if enabled then		
		if not Character:FindFirstChild("Ragdoll") then
			Humanoid.AutoRotate = true
		end

		AddConnection(Humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function()
			if not Character:FindFirstChild("Ragdoll") then
				Humanoid.AutoRotate = true
			end
		end), _ForceAutoRotate)
	end
end

local _TPBackwards = false

function TPBackwards()
	if _TPBackwards then
		local look = HumanoidRootPart.CFrame.LookVector
		HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (-look * 26)
	end
end

local _CounterVisualizer = {}

function CounterVisualizer(enabled)
	PreloadImage(137607954274376)

	for _, obj in pairs(workspace.Live:GetChildren()) do
		if obj.Head:FindFirstChild("CounterV") then
			obj.Head.CounterV:Destroy()
		end
	end

	ClearConnections(_CounterVisualizer)

	local function createDCImage(chr)
		local BillboardGui = Instance.new("BillboardGui")
		local ImageLabel = Instance.new("ImageLabel")

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

	if enabled then
		for _, chr in pairs(workspace.Live:GetChildren()) do
			if game.Players:GetPlayerFromCharacter(chr) and chr ~= Character then
				local plr = game.Players:GetPlayerFromCharacter(chr)

				if chr:FindFirstChild("Counter") then
					createDCImage(chr)
				end

				AddConnection(plr.CharacterAdded:Connect(function(chr)
					AddConnection(chr.ChildAdded:Connect(function(obj)
						if obj.Name == "Counter" and obj:IsA("Accessory") then
							createDCImage(chr)
						end
					end), _CounterVisualizer)

					AddConnection(chr.ChildRemoved:Connect(function(obj)
						if obj.Name == "Counter" and obj:IsA("Accessory") then
							chr.Head:FindFirstChild("CounterV"):Destroy()
						end
					end), _CounterVisualizer)
				end), _CounterVisualizer)

				AddConnection(chr.ChildAdded:Connect(function(obj)
					if obj.Name == "Counter" and obj:IsA("Accessory") then
						createDCImage(chr)
					end
				end), _CounterVisualizer)

				AddConnection(chr.ChildRemoved:Connect(function(obj)
					if obj.Name == "Counter" and obj:IsA("Accessory") then
						chr.Head:FindFirstChild("CounterV"):Destroy()
					end
				end), _CounterVisualizer)
			end
		end
	end
end

local _NoCutscene = {}

function NoCutscene(enabled)
	ClearConnections(_NoCutscene)

	local function CloneCam()
		local NewCam = Instance.new("Camera")
		NewCam.CameraSubject = Humanoid
		NewCam.CameraType = Enum.CameraType.Custom
		NewCam.Parent = workspace

		Camera = NewCam

		AddConnection(NewCam:GetPropertyChangedSignal("CameraType"):Connect(function()
			NewCam:Destroy()
			CloneCam()
		end), _NoCutscene)
	end

	if enabled then
		if Camera.CameraType == Enum.CameraType.Scriptable then
			Camera:Destroy()
			CloneCam()
		end

		AddConnection(Camera:GetPropertyChangedSignal("CameraType"):Connect(function()
			Camera:Destroy()
			CloneCam()
		end), _NoCutscene)
	end
end

local _AntiDC = {}

function AntiDC(enabled)
	ClearConnections(_AntiDC)

	if enabled then
		for _, obj in Character:GetChildren() do
			if obj.Name == "NoRotateUltimate" then
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
				break
			end
		end

		AddConnection(Character.ChildAdded:Connect(function(obj)
			if obj.Name == "NoRotateUltimate" then
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
		end), _AntiDC)
	end
end

local _KorbloxHeadless = false

local OldChrMesh = {
	MeshId = 0,
	OverlayTextureId = 0
}

local cMesh = nil

function KorbloxHeadless(enabled)
	if enabled then
		_KorbloxHeadless = true

		if Character:FindFirstChild("Head") then -- Headless
			task.wait(.3)

			local mesh = Instance.new("SpecialMesh", Character.Head)
			mesh.Name = "fHeadless"
			mesh.MeshType = Enum.MeshType.FileMesh
		end

		for _, mesh in pairs(Character:GetChildren()) do
			if mesh:IsA("CharacterMesh") and mesh.BodyPart == Enum.BodyPart.RightLeg then
				cMesh = mesh
				oldChrMesh.MeshId = cMesh.MeshId -- if plr has an chrMesh then it will save it
				oldChrMesh.OverlayTextureId = cMesh.OverlayTextureId

				mesh.MeshId = 101851696
				mesh.OverlayTextureId = 101851254
				break
			else
				cMesh = Instance.new("CharacterMesh", Character)
				cMesh.BodyPart = Enum.BodyPart.RightLeg
				cMesh.MeshId = 101851696
				cMesh.OverlayTextureId = 101851254
				break
			end
		end
	else
		_KorbloxHeadless = false

		if cMesh then
			cMesh.MeshId = OldChrMesh.MeshId
			cMesh.OverlayTextureId = OldChrMesh.OverlayTextureId
			cMesh:Destroy()

			cMesh = nil
		end

		local head = Character:FindFirstChild("Head")

		if head then
			local hMesh = head:FindFirstChild("fHeadless")

			if hMesh then
				hMesh:Destroy()
			end
		end
	end
end

local _M1Reset = {}

function M1Reset(enabled)
	ClearConnections(_M1Reset)

	if enabled then
		AddConnection(HumanoidRootPart.ChildAdded:Connect(function(obj)
			if obj.Name == "dodgevelocity" then
				while obj.Name == "dodgevelocity" do
					task.wait()

					if obj then
						obj.Name = "velocity"
					end
				end
			end
		end), _M1Reset)
	end
end

local _HideBlockAnims = {}

function HideBlockAnims(enabled)
	ClearConnections(_HideBlockAnims)

	local BlockIDS = {
		10470389827,
		13380778193,
		13935548552
	}

	if enabled then
		AddConnection(Animator.AnimationPlayed:Connect(function(track)
			for _, id in pairs(BlockIDS) do
				if track.Animation.AnimationId == "rbxassetid://" .. id then
					track:Stop()
				end
			end
		end), _HideBlockAnims)
	end
end

local _EmoteWhileDash = {}

function EmoteWhileDash(enabled)
	ClearConnections(_EmoteWhileDash)

	if enabled then
		AddConnection(Character:GetAttributeChangedSignal("_JustDashed"):Connect(function()
			Character:SetAttribute("_JustDashed", 0)
		end), _EmoteWhileDash)
	end
end

local _Lay = false

function Lay()
	if _Lay then
		Humanoid.Sit = true
		task.wait(0.1)
		Humanoid.RootPart.CFrame = Humanoid.RootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)
		for _, v in ipairs(Humanoid:GetPlayingAnimationTracks()) do
			v:Stop()
		end
	end
end

local _RemoveEmoteFreeze = {}

function RemoveEmoteFreeze(enabled)
	ClearConnections(_RemoveEmoteFreeze)

	if enabled then
		local TempConn = {}

		AddConnection(Character.ChildAdded:Connect(function(obj)
			if obj.Name == "DoingEmote" and obj:IsA("Accessory") then
				if Character:FindFirstChild("DoingEmote") then
					local freeze = Character:WaitForChild("Freeze")
					freeze:Destroy()
				end
				
				AddConnection(Animator.AnimationPlayed:Connect(function(track)
					if track.Animation.AnimationId == "rbxassetid://7815618175" then
						if Character:FindFirstChild("DoingEmote") then
							track:Stop()
						end
					end
				end), TempConn)

				local currentTrack = Animator:GetPlayingAnimationTracks()[1]
				if currentTrack.Animation.AnimationId == "rbxassetid://7815618175" then
					if Character:FindFirstChild("DoingEmote") then
						currentTrack:Stop()
					end
				end
			end
		end), _RemoveEmoteFreeze)

		AddConnection(Character.ChildRemoved:Connect(function(obj)
			if obj.Name == "DoingEmote" and obj:IsA("Accessory") then
				ClearConnections(TempConn)
			end
		end), _RemoveEmoteFreeze)
	end
end

local _FreezeMidAir = false
local thread = 0

function FreezeMidAir(key)
	if _FreezeMidAir then
		local TempConn = {}

		AddConnection(UserInputService.InputEnded:Connect(function(i, p)
			if i.KeyCode == key then
				thread = thread + tick()

				HumanoidRootPart.Anchored = false
				Humanoid.Sit = false		

				ClearConnections(TempConn)
			end
		end), TempConn)

		thread = thread + tick()
		local oldThread = thread

		Humanoid.Sit = true

		task.wait(0.1)

		if oldThread ~= thread then return end

		HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
		HumanoidRootPart.CFrame = HumanoidRootPart.CFrame * CFrame.Angles(math.pi * 0.5, 0, 0)

		task.spawn(function()
			for _, v in ipairs(Humanoid:GetPlayingAnimationTracks()) do
				v:Stop()
			end	
		end)

		task.wait(.07)

		if oldThread ~= thread then return end

		HumanoidRootPart.Anchored = true
	end
end

local _DisablePlayerCollision = {}

function DisablePlayerCollision(enabled)
	ClearConnections(_DisablePlayerCollision)

	if enabled then
		AddConnection(RunService.Heartbeat:Connect(function()
			for _, v in pairs(Character:GetDescendants()) do
				if v:IsA("BasePart") then
					v.CollisionGroup = "nocol2" 
				end
			end
		end), _DisablePlayerCollision)
	else
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CollisionGroup = "playercol" 
			end
		end
	end
end

local _InvisibleTableflip = {}

function InvisibleTableflip(enabled)
	ClearConnections(_InvisibleTableflip)

	if enabled then
		AddConnection(Character.ChildAdded:Connect(function(obj)
			if obj.Name == "Table Flip" then
				local list = {
					"AntiMove",
					"Freeze",
					"HeavyBody",
					"NoRotate"
				}

				local oldPos = nil

				local totalDeleted = 0

				task.spawn(function()
					while totalDeleted ~= #list do
						for _, v in pairs(Character:GetChildren()) do
							for _, v2 in pairs(list) do
								if v.Name == v2 then
									v:Destroy()
									totalDeleted += 1
								end
							end
						end

						task.wait(.1)
					end
				end)

				task.spawn(function()
					for i = 1, 20 do
						HumanoidRootPart.CustomPhysicalProperties = nil
						task.wait(.1)
					end
				end)

				local TIME = 3.5

				task.spawn(function()
					task.wait(TIME - .3)

					oldPos = HumanoidRootPart.CFrame
				end)

				task.wait(TIME)

				HumanoidRootPart.CFrame = CFrame.new(9999, 9999, 9999)

				task.wait(.6)

				HumanoidRootPart.CFrame = oldPos
			end
		end), _InvisibleTableflip)
	end
end

local _Reset = false

function Reset()
	if _Reset then
		Humanoid.Health = 0
	end
end

local _FloatWhileSemiRagolled = {}

function FloatWhileSemiRagolled(enabled)
	ClearConnections(_FloatWhileSemiRagolled)

	if enabled then
		AddConnection(Character.ChildAdded:Connect(function(obj)
			if obj.Name == "BeingLaunched" then -- start
				Humanoid.HipHeight = 4
			elseif obj.Name == "LaunchEnded" then -- end
				Humanoid.HipHeight = 0
			end
		end), _FloatWhileSemiRagolled)
	end
end

Player.CharacterAdded:Connect(function(char)
	Character = char
	HumanoidRootPart = char:WaitForChild("HumanoidRootPart")
	Humanoid = char:WaitForChild("Humanoid")	
	Animator = Humanoid:WaitForChild("Animator")

	FloatWhileSemiRagolled(isEnabled(_FloatWhileSemiRagolled))
	InvisibleTableflip(isEnabled(_InvisibleTableflip))
	DisablePlayerCollision(isEnabled(_DisablePlayerCollision))
	RemoveEmoteFreeze(isEnabled(_RemoveEmoteFreeze))
	EmoteWhileDash(isEnabled(_EmoteWhileDash))
	HideBlockAnims(isEnabled(_HideBlockAnims))
	M1Reset(isEnabled(_M1Reset))
	KorbloxHeadless(isEnabled(_KorbloxHeadless))
	AntiDC(isEnabled(_AntiDC))
	NoCutscene(isEnabled(_NoCutscene))
	CounterVisualizer(isEnabled(_CounterVisualizer))
	AntiBlockDebuff(isEnabled(_AntiBlockDebuff))
	ForceAutoRotate(isEnabled(_ForceAutoRotate))
end)

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "Seitium Hub",
	Icon = "eye",
	Author = "all scripts made by infernus",
})

--// PLAYER \\--
local Player_Tab = Window:Tab({
	Title = "Player",
	Icon = "user"
})

local TPBackwards_Section = Player_Tab:Section({
	Title = "TP Backwards Config",
	Box = true,
	BoxBorder = true,
})

local TPBackwards_Toggle = TPBackwards_Section:Toggle({
	Title = "TP Backwards",
	Callback = function(state)
		_TPBackwards = state
	end,
})

TPBackwards_Section:Keybind({
	Title = "Keybind",
	Value = "R",
	Callback = function()
		TPBackwards()
	end,
})

local FreezeMidAir_Section = Player_Tab:Section({
	Title = "Freeze Mid Air Config",
	Box = true,
	BoxBorder = true,
})

local FreezeMidAir_Toggle = FreezeMidAir_Section:Toggle({
	Title = "Freeze Mid Air",
	Callback = function(state)
		_FreezeMidAir = state
	end,
})

FreezeMidAir_Section:Keybind({
	Title = "Keybind",
	Value = "X",
	Callback = function(value)
		FreezeMidAir(Enum.KeyCode[value])
	end,
})

local Reset_Section = Player_Tab:Section({
	Title = "Reset Config",
	Box = true,
	BoxBorder = true,
})

local Reset_Toggle = Reset_Section:Toggle({
	Title = "Reset",
	Callback = function(state)
		_Reset = state
	end,
})

Reset_Section:Keybind({
	Title = "Keybind",
	Value = "R",
	Callback = function()
		Reset()
	end,
})

local FloatWhileSemiRagdolled_Toggle = Player_Tab:Toggle({
	Title = "Float While Semi Ragolled",
	Callback = function(state)
		FloatWhileSemiRagdolled(state)
	end,
})

local AntiDC_Toggle = Player_Tab:Toggle({
	Title = "Anti Death Counter",
	Callback = function(state)
		AntiDC(state)
	end,
})

local DisablePlayerCollision_Toggle = Player_Tab:Toggle({
	Title = "Disable Player Collision",
	Callback = function(state)
		DisablePlayerCollision(state)
	end,
})

local EmoteSideDash_Toggle = Player_Tab:Toggle({
	Title = "Emote While Side Dashing",
	Callback = function(state)
		EmoteWhileDash(state)
	end,
})

local RemoveEmoteFreeze_Toggle = Player_Tab:Toggle({
	Title = "Remove Emote Freeze",
	Callback = function(state)
		RemoveEmoteFreeze(state)
	end,
})

local ForceAutoRotate_Toggle = Player_Tab:Toggle({
	Title = "Force AutoRotate",
	Callback = function(state)
		ForceAutoRotate(state)
	end,
})

local AntiBlockDebuff_Toggle = Player_Tab:Toggle({
	Title = "Anti Block Debuff",
	Callback = function(state)
		AntiBlockDebuff(state)
	end,
})

--// COMBAT \\-
local Combat_Tab = Window:Tab({
	Title = "Combat",
	Icon = "sword"
})

local M1Reset_Toggle = Combat_Tab:Toggle({
	Title = "M1 Reset",
	Callback = function(state)
		M1Reset(state)
	end,
})

--// VISUALS \\--
local Visuals_Tab = Window:Tab({
	Title = "Visuals",
	Icon = "eye"
})

local CounterVisualizer_Toggle = Visuals_Tab:Toggle({
	Title = "Counter Visualizer",
	Callback = function(state)
		CounterVisualizer(state)
	end,
})

local InvisibleTableflip_Toggle = Visuals_Tab:Toggle({
	Title = "Invisible Tableflip",
	Callback = function(state)
		InvisibleTableflip(state)
	end,
})

local NoCutscene_Toggle = Visuals_Tab:Toggle({
	Title = "No Cutscene",
	Callback = function(state)
		NoCutscene(state)
	end,
})

local KorbloxHeadless_Toggle = Visuals_Tab:Toggle({
	Title = "Korblox + Headless",
	Callback = function(state)
		KorbloxHeadless(state)
	end,
})

local HideBlockAnim_Toggle = Visuals_Tab:Toggle({
	Title = "Hide Block Animations",
	Callback = function(state)
		HideBlockAnims(state)
	end,
})

--// MISCELLANEOUS \\--
local Miscellaneous_Tab = Window:Tab({
	Title = "Miscellaneous",
	Icon = "toolbox"
})

local Lay_Section = Miscellaneous_Tab:Section({
	Title = "Lay Config",
	Box = true,
	BoxBorder = true,
})

local Lay_Toggle = Lay_Section:Toggle({
	Title = "Lay",
	Callback = function(state)
		_Lay = state
	end,
})

Lay_Section:Keybind({
	Title = "Keybind",
	Value = "Z",
	Callback = function()
		Lay()
	end,
})

local JerkOff_Button = Miscellaneous_Tab:Button({
	Title = "Jerk Off",
	Callback = function()
		loadstring(game:HttpGet("https://pastefy.app/wa3v2Vgm/raw"))("Spider Script")
	end,
})

local Rejoin_Button = Miscellaneous_Tab:Button({
	Title = "Rejoin Server",
	Callback = function()	
		TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player)
	end,
})

-- Join A Specific Server
local CopyJobId_Button = Miscellaneous_Tab:Button({
	Title = "Copy JobId",
	Callback = function()
		setclipboard(game.JobId)
	end,
})

local JoinJobId_Input = Miscellaneous_Tab:Input({
	Title = "Join with JobId",
	Type = "Input",
	Placeholder = "Enter JobId",
	Callback = function(input) 
		TeleportService:TeleportToPlaceInstance(game.PlaceId, input, Player)
	end
})

--// CONFIG \\--
local Config_Tab = Window:Tab({
	Title = "Settings",
	Icon = "settings"
})

Config_Tab:Keybind({
	Title = "Show/Hide Menu",
	Value = "Insert",
	Callback = function(v)
		Window:SetToggleKey(Enum.KeyCode[v])
	end,
})
