local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/audaxide/r/main/uilibs/uwuware.lua"))()

local window = library:CreateWindow("Baddies")

-- Walk Speed Slider
local walkSpeedSlider = window:AddSlider({
    text = "Walk Speed",
    min = 16,
    max = 30,
    value = 20, -- default value
    callback = function(value)
        spawn(function()
            while true do
                local player = game.Players.LocalPlayer
                if player and player.Character then
                    player.Character.Humanoid.WalkSpeed = value
                end
                wait(0.1) -- Adjust delay as necessary to avoid too much load
            end
        end)
    end
})

local killAuraToggle = window:AddToggle({
    text = "Kill Aura",
    state = false,
    callback = function(state)
        if state then
            spawn(function()
                while state do
                    local player = game.Players.LocalPlayer

                    -- Wait for the character and HumanoidRootPart to load
                    if player and player.Character and player.Character:WaitForChild("HumanoidRootPart", 5) then
                        for _, target in pairs(game:GetService("Players"):GetPlayers()) do
                            if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
                                local humanoid = target.Character.Humanoid
                                
                                -- Attempt to get HumanoidRootPart, fallback to Torso/UpperTorso if not available
                                local rootPart = target.Character:FindFirstChild("HumanoidRootPart") 
                                    or target.Character:FindFirstChild("UpperTorso") 
                                    or target.Character:FindFirstChild("Torso")
                                
                                if rootPart then
                                    local distance = (rootPart.Position - player.Character.HumanoidRootPart.Position).magnitude

                                    if distance <= 6 then
                                        -- Spam hit humanoids
                                        local args = { [1] = 1 }
                                        game:GetService("ReplicatedStorage"):WaitForChild("PUNCHEVENT"):FireServer(unpack(args))
                                    end
                                end

                                -- Auto grab when stamina is 100
                                local staminaText = player.PlayerGui.GeneralGUI.bars.stamina.TextLabel.Text
                                local staminaValue = tonumber(staminaText:match("%d+"))
                                if staminaValue == 100 then
                                    game:GetService("ReplicatedStorage"):WaitForChild("JALADADEPELOEVENT"):FireServer()
                                end
                            end
                        end
                    end
                    wait(0.01) -- Reduced delay for more frequent checks
                end
            end)
        end
    end
})



local autoSprayToggle = window:AddToggle({
    text = "Auto Spray",
    state = false,
    callback = function(state)
        if state then
            spawn(function()
                while state do
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    local spray = character:FindFirstChild("Spray") -- Check if Spray is equipped
                    
                    if spray and spray:FindFirstChild("RemoteEvent") then
                        local nearestEnemy
                        local shortestDistance = math.huge

                        -- Find the nearest enemy
                        for _, target in pairs(game:GetService("Players"):GetPlayers()) do
                            if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
                                local humanoid = target.Character.Humanoid
                                local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
                                    or target.Character:FindFirstChild("UpperTorso")
                                    or target.Character:FindFirstChild("Torso")
                                
                                if rootPart and humanoid.Health > 0 then
                                    local distance = (rootPart.Position - character.HumanoidRootPart.Position).magnitude
                                    if distance < shortestDistance then
                                        nearestEnemy = target
                                        shortestDistance = distance
                                    end
                                end
                            end
                        end

                        -- Spray the nearest enemy if within a reasonable range
                        if nearestEnemy and shortestDistance <= 10 then -- Adjust range as needed
                            spray.RemoteEvent:FireServer()
                        end
                    end

                    wait(0.5) -- Adjust delay as necessary
                end
            end)
        end
    end
})


local autoTaserToggle = window:AddToggle({
    text = "Auto Taser",
    state = false,
    callback = function(state)
        if state then
            spawn(function()
                while state do
                    local player = game.Players.LocalPlayer
                    local character = player.Character
                    local taser = character:FindFirstChild("Taser") -- Check if Taser is equipped
                    
                    if taser and taser:FindFirstChild("RemoteEvent") then
                        local nearestEnemy
                        local shortestDistance = math.huge

                        -- Find the nearest enemy
                        for _, target in pairs(game:GetService("Players"):GetPlayers()) do
                            if target ~= player and target.Character and target.Character:FindFirstChild("Humanoid") then
                                local humanoid = target.Character.Humanoid
                                local rootPart = target.Character:FindFirstChild("HumanoidRootPart")
                                    or target.Character:FindFirstChild("UpperTorso")
                                    or target.Character:FindFirstChild("Torso")
                                
                                if rootPart and humanoid.Health > 0 then
                                    local distance = (rootPart.Position - character.HumanoidRootPart.Position).magnitude
                                    if distance < shortestDistance then
                                        nearestEnemy = target
                                        shortestDistance = distance
                                    end
                                end
                            end
                        end

                        -- Tase the nearest enemy if within a reasonable range
                        if nearestEnemy and shortestDistance <= 15 then -- Adjust range as needed
                            taser.RemoteEvent:FireServer()
                        end
                    end

                    wait(0.5) -- Adjust delay as necessary
                end
            end)
        end
    end
})

library:Init()
