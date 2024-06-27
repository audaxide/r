local version = '0.1'
print(version)

local Stats = game:GetService('Stats')
local Players = game:GetService('Players')
local RunService = game:GetService('RunService')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local TweenService = game:GetService('TweenService')

local nurysium_Util = loadstring(game:HttpGet('https://raw.githubusercontent.com/flezzpe/nurysium/main/nurysium_helper.lua'))()

local local_player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local nurysium_Data = nil
local hit_Sound = nil

local closest_Entity = nil
local parry_remote = nil

getgenv().aura_Enabled = false
getgenv().hit_sound_Enabled = false
getgenv().hit_effect_Enabled = false
getgenv().night_mode_Enabled = false
getgenv().trail_Enabled = false
getgenv().self_effect_Enabled = false
getgenv().kill_effect_Enabled = false
getgenv().shaders_effect_Enabled = false
getgenv().ai_Enabled = false
getgenv().spectate_Enabled = false

local Services = {
	game:GetService('AdService'),
	game:GetService('SocialService')
}

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Nurysium " .. version,
    SubTitle = "Edited",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
	Misc = Window:AddTab({ Title = "Misc", Icon = "hammer" }),
	Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Settings = Window:AddTab({ Title = "Config", Icon = "save" })
}

local Options = Fluent.Options

function initializate(dataFolder_name)
	local nurysium_Data = Instance.new('Folder', game:GetService('CoreGui'))
	nurysium_Data.Name = dataFolder_name

	hit_Sound = Instance.new('Sound', nurysium_Data)
	hit_Sound.SoundId = 'rbxassetid://8726881116'
	hit_Sound.Volume = 6
end

local function get_closest_entity(Object)
	task.spawn(function()
		local closest
		local max_distance = math.huge

		for _, entity in ipairs(workspace.Alive:GetChildren()) do
			if entity.Name ~= Players.LocalPlayer.Name then
				local distance = (Object.Position - entity.HumanoidRootPart.Position).Magnitude

				if distance < max_distance then
					closest_Entity = entity
					max_distance = distance
				end
			end
		end
	end)
end

local function get_center()
	for _, object in ipairs(workspace.Map:GetDescendants()) do
		if object.Name == 'BALLSPAWN' then
			return object
		end
	end
end

function resolve_parry_Remote()
	for _, value in ipairs(Services) do
		local temp_remote = value:FindFirstChildOfClass('RemoteEvent')

		if temp_remote and temp_remote.Name:find('\n') then
			parry_remote = temp_remote
			break
		end
	end
end

function walk_to(position)
	local_player.Character.Humanoid:MoveTo(position)
end

Tabs.Combat:AddToggle("Aura", {Title = "Aura", Default = false}):OnChanged(function(toggled)
	resolve_parry_Remote()
	getgenv().aura_Enabled = toggled
end)

Tabs.Combat:AddToggle("AI - Beta", {Title = "AI - Beta", Default = false}):OnChanged(function(toggled)
	resolve_parry_Remote()
	getgenv().ai_Enabled = toggled
end)

Tabs.Misc:AddToggle("Hit Sound", {Title = "Hit Sound", Default = false}):OnChanged(function(toggled)
	getgenv().hit_sound_Enabled = toggled
end)

Tabs.Misc:AddToggle("Hit Effect", {Title = "Hit Effect", Default = false}):OnChanged(function(toggled)
	getgenv().hit_effect_Enabled = toggled
end)

Tabs.Visuals:AddToggle("Night Mode", {Title = "Night Mode", Default = false}):OnChanged(function(toggled)
	getgenv().night_mode_Enabled = toggled
end)

Tabs.Visuals:AddToggle("Trail", {Title = "Trail", Default = false}):OnChanged(function(toggled)
	getgenv().trail_Enabled = toggled
end)

Tabs.Visuals:AddToggle("Self Effect", {Title = "Self Effect", Default = false}):OnChanged(function(toggled)
	getgenv().self_effect_Enabled = toggled
end)

Tabs.Visuals:AddToggle("Kill Effect", {Title = "Kill Effect", Default = false}):OnChanged(function(toggled)
	getgenv().kill_effect_Enabled = toggled
end)

Tabs.Visuals:AddToggle("Shaders", {Title = "Shaders", Default = false}):OnChanged(function(toggled)
	getgenv().shaders_effect_Enabled = toggled
end)

Tabs.Misc:AddToggle("Spectate Ball", {Title = "Spectate Ball", Default = false}):OnChanged(function(toggled)
	getgenv().spectate_Enabled = toggled
end)

local originalMaterials = {}
local fpsBoosterEnabled = false
Tabs.Visuals:AddToggle("Universal FPS Boost - Beta", {Title = "Universal FPS Boost - Beta", Default = false}):OnChanged(function(toggled)
    fpsBoosterEnabled = toggled
    if toggled then
        game.Lighting.GlobalShadows = false
        setfpscap(9e9)
        task.spawn(function()
            while fpsBoosterEnabled do
                local descendants = game:GetDescendants()
                local lightingDescendants = game.Lighting:GetDescendants()
                local batchSize = 100

                -- Process game descendants in batches
                for i = 1, #descendants, batchSize do
                    local batch = {unpack(descendants, i, math.min(i + batchSize - 1, #descendants))}
                    for _, descendant in ipairs(batch) do
                        if descendant:IsA("Part") or descendant:IsA("UnionOperation") or descendant:IsA("MeshPart") or descendant:IsA("CornerWedgePart") or descendant:IsA("TrussPart") then
                            if not originalMaterials[descendant] then
                                originalMaterials[descendant] = {
                                    Material = descendant.Material,
                                    Reflectance = descendant.Reflectance
                                }
                            end
                            descendant.Material = Enum.Material.Plastic
                            descendant.Reflectance = 0
                        elseif descendant:IsA("Decal") then
                            descendant.Transparency = 1
                        elseif descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
                            descendant.Lifetime = NumberRange.new(0)
                        elseif descendant:IsA("Explosion") then
                            descendant.BlastPressure = 1
                            descendant.BlastRadius = 1
                        end
                    end
                    task.wait(0.1) -- Yield to prevent lag spike
                end

                -- Process lighting descendants in batches
                for i = 1, #lightingDescendants, batchSize do
                    local batch = {unpack(lightingDescendants, i, math.min(i + batchSize - 1, #lightingDescendants))}
                    for _, effect in ipairs(batch) do
                        if effect:IsA("BlurEffect") or effect:IsA("SunRaysEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("BloomEffect") or effect:IsA("DepthOfFieldEffect") then
                            effect.Enabled = false
                        end
                    end
                    task.wait(0.1) -- Yield to prevent lag spike
                end
                task.wait(2.5)
            end
        end)
    else
        for part, originalData in pairs(originalMaterials) do
            if part:IsA("Part") or part:IsA("UnionOperation") or part:IsA("MeshPart") or part:IsA("CornerWedgePart") or part:IsA("TrussPart") then
                part.Material = originalData.Material
                part.Reflectance = originalData.Reflectance
            end
        end
        originalMaterials = {}
        game.Lighting.GlobalShadows = true
    end
end)

local player = game.Players.LocalPlayer
local userInputService = game:GetService("UserInputService")
local jumpRequestConnection
Tabs.Misc:AddToggle("Infinite Jump", {Title = "Infinite Jump", Default = false}):OnChanged(function(toggled)
    if toggled then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                jumpRequestConnection = userInputService.JumpRequest:Connect(function()
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end)
            end
        end
    else
        if jumpRequestConnection then
            jumpRequestConnection:Disconnect()
        end
    end
end)

function play_kill_effect(Part)
	task.defer(function()
		local bell = game:GetObjects("rbxassetid://8726881116")[1]

		bell.Name = 'Neverlose'
		bell.Parent = workspace

		bell.Position = Part.Position - Vector3.new(0, 20, 0)
		bell:WaitForChild('Sound'):Play()

		TweenService:Create(bell, TweenInfo.new(0.85, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
			Position = Part.Position + Vector3.new(0, 10, 0)
		}):Play()

		task.delay(5, function()
			TweenService:Create(bell, TweenInfo.new(1.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut), {
				Position = Part.Position + Vector3.new(0, 100, 0)
			}):Play()
		end)

		task.delay(6, function()
			bell:Destroy()
		end)
	end)
end

task.defer(function()
	workspace.Alive.ChildRemoved:Connect(function(child)
		if not workspace.Dead:FindFirstChild(child.Name) and child ~= local_player.Character and #workspace.Alive:GetChildren() > 1 then
			return
		end

		if getgenv().kill_effect_Enabled then
			play_kill_effect(child.HumanoidRootPart)
		end
	end)
end)

task.defer(function()
	game:GetService("RunService").Heartbeat:Connect(function()
		if not local_player.Character then return end

		if getgenv().self_effect_Enabled then
			local effect = game:GetObjects("rbxassetid://17519530107")[1]
			effect.Name = 'nurysium_efx'

			if not local_player.Character.PrimaryPart:FindFirstChild('nurysium_efx') then
				effect.Parent = local_player.Character.PrimaryPart
			end
		else
			if local_player.Character.PrimaryPart:FindFirstChild('nurysium_efx') then
				local_player.Character.PrimaryPart['nurysium_efx']:Destroy()
			end
		end
	end)
end)

task.defer(function()
	game:GetService("RunService").Heartbeat:Connect(function()
		if not local_player.Character then return end

		if getgenv().trail_Enabled then
			local trail = game:GetObjects("rbxassetid://17483658369")[1]
			trail.Name = 'nurysium_fx'

			if not local_player.Character.PrimaryPart:FindFirstChild('nurysium_fx') then
				local attachment0 = Instance.new("Attachment", local_player.Character.PrimaryPart)
				local attachment1 = Instance.new("Attachment", local_player.Character.PrimaryPart)
				attachment0.Position = Vector3.new(0, -2.411, 0)
				attachment1.Position = Vector3.new(0, 2.504, 0)

				trail.Parent = local_player.Character.PrimaryPart
				trail.Attachment0 = attachment0
				trail.Attachment1 = attachment1
			end
		else
			if local_player.Character.PrimaryPart:FindFirstChild('nurysium_fx') then
				local_player.Character.PrimaryPart['nurysium_fx']:Destroy()
			end
		end
	end)
end)

task.defer(function()
	while task.wait(1) do
		if getgenv().night_mode_Enabled then
			TweenService:Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 1.9}):Play()
		else
			TweenService:Create(game:GetService("Lighting"), TweenInfo.new(3), {ClockTime = 13.5}):Play()
		end
	end
end)

task.defer(function()
    RunService.RenderStepped:Connect(function()
        if getgenv().spectate_Enabled then
            local self = nurysium_Util.getBall()
            if self then
                workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(CFrame.new(workspace.CurrentCamera.CFrame.Position, self.Position), 1.5)
            end
        end
    end)
end)

task.defer(function()
    while task.wait(1) do
        if getgenv().shaders_effect_Enabled then
            TweenService:Create(game:GetService("Lighting").Bloom, TweenInfo.new(4), {
                Size = 150,
                Intensity = 2.5
            }):Play()
            TweenService:Create(game:GetService("Lighting").ColorCorrection, TweenInfo.new(4), {
                Saturation = 0.3,
                Contrast = 0.2,
                Brightness = 0.1
            }):Play()
            TweenService:Create(game:GetService("Lighting").DepthOfField, TweenInfo.new(4), {
                FocusDistance = 30,
                InFocusRadius = 15,
                NearIntensity = 0.7,
                FarIntensity = 0.7
            }):Play()
            game.Lighting.GlobalShadows = true
            game.Lighting.Ambient = Color3.fromRGB(100, 100, 100)
            game.Lighting.OutdoorAmbient = Color3.fromRGB(80, 80, 80)
			game:GetService("Lighting").Bloom.Enabled = true
            game:GetService("Lighting").ColorCorrection.Enabled = true
            game:GetService("Lighting").DepthOfField.Enabled = true
        else
            game.Lighting.GlobalShadows = false
            game.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            game.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").Bloom.Enabled = false
            game:GetService("Lighting").ColorCorrection.Enabled = false
            game:GetService("Lighting").DepthOfField.Enabled = false
        end
    end
end)

ReplicatedStorage.Remotes.ParrySuccess.OnClientEvent:Connect(function()
	if getgenv().hit_sound_Enabled then
		hit_Sound:Play()
	end

	if getgenv().hit_effect_Enabled then
		local hit_effect = game:GetObjects("rbxassetid://17407244385")[1]
		hit_effect.Parent = nurysium_Util.getBall()
		hit_effect:Emit(3)

		task.delay(5, function()
			hit_effect:Destroy()
		end)
	end
end)

local aura_table = {
	can_parry = true,
	is_spamming = false,

	parry_Range = 0,
	spam_Range = 0,  
	hit_Count = 0,

	hit_Time = tick(),
	ball_Warping = tick(),
	is_ball_Warping = false,
	last_target = nil
}

ReplicatedStorage.Remotes.ParrySuccessAll.OnClientEvent:Connect(function()
	aura_table.hit_Count += 1
	task.delay(0.15, function()
		aura_table.hit_Count -= 1
	end)
end)

workspace:WaitForChild("Balls").ChildRemoved:Connect(function(child)
	aura_table.hit_Count = 0
	aura_table.is_ball_Warping = false
	aura_table.is_spamming = false
end)

task.defer(function()
	RunService.PreRender:Connect(function()
		if not getgenv().aura_Enabled then return end
		if closest_Entity and workspace.Alive:FindFirstChild(closest_Entity.Name) and aura_table.is_spamming then
			if local_player:DistanceFromCharacter(closest_Entity.HumanoidRootPart.Position) <= aura_table.spam_Range then   
				parry_remote:FireServer(
					0.5,
					CFrame.new(camera.CFrame.Position, Vector3.zero),
					{[closest_Entity.Name] = closest_Entity.HumanoidRootPart.Position},
					{closest_Entity.HumanoidRootPart.Position.X, closest_Entity.HumanoidRootPart.Position.Y},
					false
				)
			end
		end
	end)

	RunService.PreRender:Connect(function()
		if not getgenv().aura_Enabled then return end

		local ping = Stats.Network.ServerStatsItem['Data Ping']:GetValue() / 10
		local self = nurysium_Util.getBall()
		if not self then return end

		self:GetAttributeChangedSignal('target'):Once(function()
			aura_table.can_parry = true
		end)

		if self:GetAttribute('target') ~= local_player.Name or not aura_table.can_parry then return end

		get_closest_entity(local_player.Character.PrimaryPart)

		local player_Position = local_player.Character.PrimaryPart.Position
		local ball_Position = self.Position
		local ball_Velocity = self.AssemblyLinearVelocity
		if self:FindFirstChild('zoomies') then
			ball_Velocity = self.zoomies.VectorVelocity
		end

		local ball_Direction = (local_player.Character.PrimaryPart.Position - ball_Position).Unit
		local ball_Distance = local_player:DistanceFromCharacter(ball_Position)
		local ball_Dot = ball_Direction:Dot(ball_Velocity.Unit)
		local ball_Speed = ball_Velocity.Magnitude
		local ball_speed_Limited = math.min(ball_Speed / 1000, 0.1)

		local ball_predicted_Distance = (ball_Distance - ping / 15.5) - (ball_Speed / 3.5)

		local target_Position = closest_Entity.HumanoidRootPart.Position
		local target_Distance = local_player:DistanceFromCharacter(target_Position)
		local target_distance_Limited = math.min(target_Distance / 10000, 0.1)
		local target_Direction = (local_player.Character.PrimaryPart.Position - closest_Entity.HumanoidRootPart.Position).Unit
		local target_Velocity = closest_Entity.HumanoidRootPart.AssemblyLinearVelocity
		local target_isMoving = target_Velocity.Magnitude > 0
		local target_Dot = target_isMoving and math.max(target_Direction:Dot(target_Velocity.Unit), 0)

		aura_table.spam_Range = math.max(ping / 10, 15) + ball_Speed / 7
		aura_table.parry_Range = math.max(math.max(ping, 4) + ball_Speed / 3.5, 9.5)
		aura_table.is_spamming = aura_table.hit_Count > 1 or ball_Distance < 13.5

		if ball_Dot < 0 then
			aura_table.ball_Warping = tick()
		end

		task.spawn(function()
			if (tick() - aura_table.ball_Warping) >= 0.25 + target_distance_Limited - ball_speed_Limited or ball_Distance <= 12 then
				aura_table.is_ball_Warping = false
				return
			end
			aura_table.is_ball_Warping = true
		end)

		if ball_Distance <= aura_table.parry_Range and not aura_table.is_spamming and not aura_table.is_ball_Warping then
			parry_remote:FireServer(
				0.5,
				CFrame.new(camera.CFrame.Position, Vector3.new(math.random(-1000, 1000), math.random(0, 1000), math.random(-1000, 100))),
				{[closest_Entity.Name] = target_Position},
				{target_Position.X, target_Position.Y},
				false
			)

			aura_table.can_parry = false
			aura_table.hit_Time = tick()
			aura_table.hit_Count += 1

			task.delay(0.15, function()
				aura_table.hit_Count -= 1
			end)
		end

		task.spawn(function()
			repeat
				RunService.PreRender:Wait()
			until (tick() - aura_table.hit_Time) >= 1
				aura_table.can_parry = true
		end)
	end)
end)

task.defer(function()
    game:GetService("RunService").Heartbeat:Connect(function()
        if getgenv().ai_Enabled and workspace.Alive:FindFirstChild(local_player.Character.Name) then
            local self = nurysium_Util.getBall()

            if not self or not closest_Entity then
                return
            end

            if not closest_Entity:FindFirstChild('HumanoidRootPart') then
                walk_to(local_player.Character.HumanoidRootPart.Position + Vector3.new(math.sin(tick()) * math.random(35, 50), 0, math.cos(tick()) * math.random(35, 50)))
                return
            end

            local ball_Position = self.Position
            local ball_Speed = self.AssemblyLinearVelocity.Magnitude
            local ball_Distance = local_player:DistanceFromCharacter(ball_Position)

            local player_Position = local_player.Character.PrimaryPart.Position

            local target_Position = closest_Entity.HumanoidRootPart.Position
            local target_Distance = local_player:DistanceFromCharacter(target_Position)
            local target_LookVector = closest_Entity.HumanoidRootPart.CFrame.LookVector

            local resolved_Position = Vector3.zero

            local target_Humanoid = closest_Entity:FindFirstChildOfClass("Humanoid")
            local target_isMoving = target_Humanoid and target_Humanoid.MoveDirection.Magnitude > 0

            if target_Humanoid and target_Humanoid:GetState() == Enum.HumanoidStateType.Jumping then
				if local_player.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                	local_player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
            end

            if not target_isMoving or target_Distance < 5 then
                -- If the target is not moving or is too close, stop the character
                local_player.Character.Humanoid:MoveTo(local_player.Character.PrimaryPart.Position)
            else
                resolved_Position = target_Position

                if (player_Position - target_Position).Magnitude < 8 then
                    resolved_Position = target_Position + (player_Position - target_Position).Unit * 35
                end

                if ball_Distance < 8 then
                    resolved_Position = player_Position + (player_Position - ball_Position).Unit * 10
                end

                if aura_table.is_spamming then
                    local directionToBall = (ball_Position - player_Position).Unit
                    resolved_Position = player_Position + directionToBall * 10.5
                end

                walk_to(resolved_Position)
            end
        end
    end)
end)

initializate('nurysium_temp')

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Nurysium",
    Content = "The script has been loaded.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
