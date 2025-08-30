-- Roblox Compatibility Layer
local RobloxCompat = {}

-- Simulate Roblox services and global functions
RobloxCompat.Services = {
    Players = {
        LocalPlayer = {
            Name = "Player",
            DisplayName = "Player",
            Character = nil,
            WaitForChild = function(self, child) return {} end,
            GetAttributeChangedSignal = function() 
                return { Connect = function(_, callback) 
                    return { Disconnect = function() end } 
                end } 
            end,
            GetAttribute = function() return false end
        }
    },
    TweenService = {
        Create = function(_, _, _) 
            return { 
                Play = function() end, 
                Completed = { Wait = function() end } 
            } 
        end
    },
    StarterGui = {},
    HttpService = {
        HttpEnabled = true,
        GetAsync = function() return "{\"valid\": false}" end,
        JSONDecode = function(_, str) 
            if type(str) == "string" then
                return {valid = false} 
            end
            return {valid = false} 
        end,
        HttpGet = function(_, url)
            -- Simulate HttpGet method
            print("Simulating HttpGet for URL: " .. url)
            return "-- Simulated content from " .. url
        end
    }
}

-- Simulate Instance creation
RobloxCompat.Instance = {
    new = function(class)
        local instances = {
            ScreenGui = { Parent = {}, Destroy = function() end },
            Frame = { Parent = {}, Size = {}, Position = {}, BackgroundColor3 = {} },
            TextLabel = { Parent = {}, Text = "", Size = {}, Position = {}, BackgroundColor3 = {}, TextColor3 = {} },
            TextBox = { Parent = {}, Size = {}, Position = {}, PlaceholderText = "" },
            TextButton = { Parent = {}, Text = "", Size = {}, Position = {}, BackgroundColor3 = {}, 
                MouseButton1Click = { Connect = function(_, callback) end }
            }
        }
        return instances[class] or {}
    end
}

-- Simulate other Roblox-specific types
RobloxCompat.UDim2 = {
    new = function() return {} end
}

RobloxCompat.Color3 = {
    fromRGB = function() return {} end
}

RobloxCompat.Vector3 = {
    new = function() return {} end
}

RobloxCompat.CFrame = {
    new = function() return {} end
}

RobloxCompat.Enum = {
    EasingStyle = { Linear = {} },
    HumanoidStateType = { Running = {} }
}

-- Add color and gradient support to RobloxCompat
RobloxCompat.ColorSequence = {
    new = function(...)
        local args = {...}
        return {
            Keypoints = args
        }
    end
}

RobloxCompat.ColorSequenceKeypoint = {
    new = function(offset, color)
        return {
            Offset = offset,
            Value = color or Color3.fromRGB(255, 255, 255)
        }
    end
}

-- Update the global environment
ColorSequence = RobloxCompat.ColorSequence
ColorSequenceKeypoint = RobloxCompat.ColorSequenceKeypoint

-- Global function replacements
local function fireclickdetector() end
local function fireproximityprompt() end
local function firetouchinterest() end

-- Add HttpGet to global environment
local function HttpGet(url)
    return game:GetService("HttpService"):HttpGet(url)
end

-- Replace global environment with compatibility layer
game = RobloxCompat.Services
workspace = {}
task = {
    wait = function() end,
    spawn = function(func) pcall(func) end,
    cancel = function() end
}
Instance = RobloxCompat.Instance
UDim2 = RobloxCompat.UDim2
Color3 = RobloxCompat.Color3
Vector3 = RobloxCompat.Vector3
CFrame = RobloxCompat.CFrame
Enum = RobloxCompat.Enum
tick = os.time
TweenInfo = { new = function() return {} end }

-- Placeholder for initialize function
local function initialize() end

-- Load OverHeaven UI Library
local OverHeavenLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Pedalkis123/UISMAX/refs/heads/main/UI.lua"))()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Load HTTP Service for key validation
local HttpService = game:GetService("HttpService")

-- Key validation function
local function validateKey(key)
    local success, response = pcall(function()
        local url = string.format("https://work.ink/_api/v2/token/isValid/%s", key)
        local httpResponse = HttpService:GetAsync(url)
        return HttpService:JSONDecode(httpResponse)
    end)
    
    if not success then
        warn("Key validation failed: Unable to connect to validation service")
        return false
    end
    
    -- Check if the response has a valid structure
    if type(response) == "table" and response.valid == true then
        -- Optional: You can add additional checks like expiration, etc.
        return true
    else
        return false
    end
end

-- Key input UI function
local function showKeyInputUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
    
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.5, 0, 0.5, 0)
    Frame.Position = UDim2.new(0.25, 0, 0.25, 0)
    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Frame.BorderSizePixel = 0
    Frame.Parent = ScreenGui
    
    -- Add a gradient for better visual appeal
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
    })
    UIGradient.Parent = Frame
    
    local Title = Instance.new("TextLabel")
    Title.Text = "Access Key Validation"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 20
    Title.Size = UDim2.new(1, 0, 0.2, 0)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.BorderSizePixel = 0
    Title.Parent = Frame
    
    local KeyInput = Instance.new("TextBox")
    KeyInput.Size = UDim2.new(0.8, 0, 0.2, 0)
    KeyInput.Position = UDim2.new(0.1, 0, 0.4, 0)
    KeyInput.PlaceholderText = "Enter your access key"
    KeyInput.Font = Enum.Font.Gotham
    KeyInput.TextSize = 16
    KeyInput.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.BorderSizePixel = 0
    KeyInput.Parent = Frame
    
    local SubmitButton = Instance.new("TextButton")
    SubmitButton.Text = "Validate Key"
    SubmitButton.Font = Enum.Font.GothamBold
    SubmitButton.TextSize = 16
    SubmitButton.Size = UDim2.new(0.6, 0, 0.2, 0)
    SubmitButton.Position = UDim2.new(0.2, 0, 0.7, 0)
    SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SubmitButton.BorderSizePixel = 0
    SubmitButton.Parent = Frame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, 0, 0.1, 0)
    StatusLabel.Position = UDim2.new(0, 0, 0.9, 0)
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.TextSize = 14
    StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    StatusLabel.Parent = Frame
    
    -- Add hover and click effects to button
    SubmitButton.MouseEnter:Connect(function()
        SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 230, 0)
    end)
    
    SubmitButton.MouseLeave:Connect(function()
        SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    end)
    
    SubmitButton.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if key ~= "" then
            -- Disable button during validation
            SubmitButton.Text = "Validating..."
            SubmitButton.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
            SubmitButton.Active = false
            
            -- Validate key with error handling
            local success, isValid = pcall(function()
                return validateKey(key)
            end)
            
            if success and isValid then
                StatusLabel.Text = "Key Validated Successfully!"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                task.wait(1)
                ScreenGui:Destroy()
                -- Continue with script initialization
                initialize()
            else
                StatusLabel.Text = "Invalid Key. Please try again."
                StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                
                -- Reset button
                SubmitButton.Text = "Validate Key"
                SubmitButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
                SubmitButton.Active = true
            end
        else
            StatusLabel.Text = "Please enter a key."
        end
    end)
    
    Frame.Parent = ScreenGui
end

-- Configuration
local BASE_COUNT = 8
local BOARD_NAMES = {"Board", "NameBoard", "PlayerBoard", "Sign"} -- Common names for boards
local BASE_FOLDER_NAMES = {"Bases", "Base", "Plots", "Claims"} -- Common folder names

-- Variables
local myBase = nil
local allBases = {}
local baseTeleportSpeed = 50 -- Minimum speed for close distances
local maxAirTime = 5 -- Maximum air time before detection (seconds)
local airTravelHeight = 45 -- Height to fly at during air travel (studs) - much higher to avoid all obstacles

-- Auto teleport after stealing variables
local autoTeleportAfterSteal = false
local robberyConnection = nil

-- Auto lock base variables
local autoLockEnabled = false
local lockConnection = nil

-- Teleport variables
local isTeleporting = false -- Flag to prevent auto-lock during teleportation

-- Auto collect money variables
local autoCollectEnabled = false
local collectConnection = nil

-- Teleport method variables
local teleportMethod = "air" -- "air", "underground", "instant"

-- Instant interact variables
local instantInteractEnabled = false
local instantInteractConnection = nil
local originalHoldDurations = {}

-- Function to find all player bases in the workspace
local function findAllBases()
    local bases = {}
    
    -- Look for the specific structure: workspace.PlayerBases.PlayerBaseTemplate_X
    local playerBases = workspace:FindFirstChild("PlayerBases")
    if not playerBases then
        return bases
    end
    
    -- Search for PlayerBaseTemplate_1 through PlayerBaseTemplate_8 (and beyond)
    for _, child in pairs(playerBases:GetChildren()) do
        if child.Name:match("^PlayerBaseTemplate_") then
            table.insert(bases, child)
        end
    end
    
    return bases
end

-- Function to find the username board within a player base
local function findBoardInBase(playerBase)
    -- Follow the specific path: _PERMANENT.PlayerNameSign.DisplayPart.NameSurfaceGui.PlayerName
    local permanent = playerBase:FindFirstChild("_PERMANENT")
    if not permanent then
        return nil
    end
    
    local playerNameSign = permanent:FindFirstChild("PlayerNameSign")
    if not playerNameSign then
        return nil
    end
    
    local displayPart = playerNameSign:FindFirstChild("DisplayPart")
    if not displayPart then
        return nil
    end
    
    local nameSurfaceGui = displayPart:FindFirstChild("NameSurfaceGui")
    if not nameSurfaceGui then
        return nil
    end
    
    local playerName = nameSurfaceGui:FindFirstChild("PlayerName")
    if not playerName then
        return nil
    end
    
    return playerName
end

-- Function to get text from the username TextLabel
local function getTextFromBoard(usernameTextLabel)
    if not usernameTextLabel then return "" end
    
    -- Since we know it's a TextLabel, just return its text
    if usernameTextLabel:IsA("TextLabel") then
        return usernameTextLabel.Text
    end
    
    return ""
end

-- Function to identify player's base
local function identifyMyBase()
    local playerBases = findAllBases()
    
    allBases = {}
    myBase = nil
    
    for i, playerBase in pairs(playerBases) do
        local usernameLabel = findBoardInBase(playerBase)
        local usernameText = getTextFromBoard(usernameLabel)
        
        -- Get the base's CashMultiplierDisplay.DisplayPart position for teleporting
        local teleportPosition = nil
        local permanent = playerBase:FindFirstChild("_PERMANENT")
        if permanent then
            local cashMultiplierDisplay = permanent:FindFirstChild("CashMultiplierDisplay")
            if cashMultiplierDisplay then
                local displayPart = cashMultiplierDisplay:FindFirstChild("DisplayPart")
                if displayPart and displayPart:IsA("BasePart") then
                    teleportPosition = displayPart.Position
                end
            end
        end
        
        -- If no teleport position found, use base's position
        if not teleportPosition then
            local firstPart = playerBase:FindFirstChildOfClass("BasePart")
            if firstPart then
                teleportPosition = firstPart.Position
            else
                teleportPosition = Vector3.new(0, 50, 0) -- Emergency fallback
            end
        end
        
        local baseInfo = {
            base = playerBase,
            board = usernameLabel,
            text = usernameText,
            position = teleportPosition
        }
        
        table.insert(allBases, baseInfo)
        
        -- Extract player name by removing "'s Base" suffix
        local extractedPlayerName = usernameText:gsub("'s Base", "")
        
        -- Check if this base belongs to the player (exact match)
        if extractedPlayerName == player.Name or extractedPlayerName == player.DisplayName then
            myBase = baseInfo
        end
    end
    
    if myBase then
        return true
    else
        return false
    end
end

-- DeepWoken-style teleport function (AC bypass)
local function teleportToMyBase()
    if not myBase then
        return
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    -- Set teleporting flag to prevent auto-lock interference
    isTeleporting = true
    
    local humanoidRootPart = character.HumanoidRootPart
    
    -- Use stored position with Y offset for safe teleportation
    local targetPosition = myBase.position + Vector3.new(0, 5, 0)
    
    -- Calculate speed to ensure teleport takes AT LEAST 4 seconds (safer for steal completion)
    local startPosition = humanoidRootPart.Position
    local totalDistance = (targetPosition - startPosition).Magnitude
    local minimumTravelTime = 4.0 -- Ensure at least 4 seconds for safe steal completion
    
    -- Calculate speed to take exactly the minimum time, but make it even slower for medium distances
    local calculatedSpeed = totalDistance / minimumTravelTime
    local dynamicSpeed
    
    -- Make speeds reasonable for medium distances (twice as fast as previous)
    if calculatedSpeed < 40 then
        -- For very short distances, use minimum speed but extend time with phases
        dynamicSpeed = 40
    elseif calculatedSpeed <= 100 then
        -- For medium distances (50-400 studs), make it slightly slower but not too much
        dynamicSpeed = calculatedSpeed * 1.4  -- 40% faster than calculated (twice as fast as 0.7)
    elseif calculatedSpeed > 300 then
        -- For very long distances, cap speed but it will take longer (which is fine)
        dynamicSpeed = 300
    else
        -- Use calculated speed for other distances
        dynamicSpeed = calculatedSpeed
    end
    

    
    -- Underground teleport method (deep underground to avoid detection)
    local function undergroundTeleport(rootPart, finalPosition)
    local startPosition = rootPart.Position
    local undergroundDepth = 50 -- Deep underground for maximum stealth
    local finalPositionAbove = Vector3.new(finalPosition.X, finalPosition.Y + 5, finalPosition.Z) -- 5 studs above target
    local undergroundStart = Vector3.new(startPosition.X, startPosition.Y - undergroundDepth, startPosition.Z)
    local undergroundEnd = Vector3.new(finalPositionAbove.X, finalPositionAbove.Y - undergroundDepth, finalPositionAbove.Z)
        
        local totalDistance = (undergroundEnd - undergroundStart).Magnitude
        local phase1Distance = undergroundDepth
        local phase2Distance = totalDistance
        local phase3Distance = undergroundDepth -- Going up
        
        -- Phase 1: Go down subtly
        local phase1Time = phase1Distance / dynamicSpeed
        local downTween = TweenService:Create(rootPart, TweenInfo.new(phase1Time, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(undergroundStart)
        })
        
        downTween:Play()
        downTween.Completed:Wait()
        
        -- Phase 2: Travel underground to destination
        local phase2Time = phase2Distance / dynamicSpeed
        local undergroundTween = TweenService:Create(rootPart, TweenInfo.new(phase2Time, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(undergroundEnd)
        })
        
        undergroundTween:Play()
        undergroundTween.Completed:Wait()
        
        -- Phase 3: Go up to final position (5 studs above target)
        local phase3Time = phase3Distance / dynamicSpeed
        local upTween = TweenService:Create(rootPart, TweenInfo.new(phase3Time, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(finalPositionAbove)
        })
        
        upTween:Play()
        upTween.Completed:Wait()
        
        -- Fix character state after teleport to prevent ragdoll/falling
        task.wait(0.1) -- Small delay to ensure teleport is complete
        
        local humanoid = rootPart.Parent:FindFirstChild("Humanoid")
        if humanoid then
            -- Reset character state
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            
            -- Ensure character is upright
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            -- Set proper CFrame orientation (upright)
            local currentPos = rootPart.Position
            rootPart.CFrame = CFrame.new(currentPos, currentPos + Vector3.new(0, 0, -1))
        end
        
        return true
    end
    
    -- Air travel method (fast, avoids underground detection)
    local function airTeleport(rootPart, finalPosition)
        local startPosition = rootPart.Position
        local airHeight = airTravelHeight -- Use configurable air travel height
        local finalPositionAbove = Vector3.new(finalPosition.X, finalPosition.Y + 5, finalPosition.Z) -- 5 studs above target
        local airStart = Vector3.new(startPosition.X, startPosition.Y + airHeight, startPosition.Z)
        local airEnd = Vector3.new(finalPositionAbove.X, finalPositionAbove.Y + airHeight, finalPositionAbove.Z)
        
        local totalDistance = (airEnd - airStart).Magnitude
        local phase1Distance = airHeight
        local phase2Distance = totalDistance
        local phase3Distance = airHeight -- Going down
        
        -- Phase 1: Go up to air height (3x faster)
        local phase1Time = phase1Distance / (dynamicSpeed * 3) -- 3x faster ascending
        local upTween = TweenService:Create(rootPart, TweenInfo.new(phase1Time, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(airStart)
        })
        
        upTween:Play()
        upTween.Completed:Wait()
        
        -- Phase 2: Travel through air to destination (normal speed)
        local phase2Time = phase2Distance / dynamicSpeed
        local airTween = TweenService:Create(rootPart, TweenInfo.new(phase2Time, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(airEnd)
        })
        
        airTween:Play()
        airTween.Completed:Wait()
        
        -- Phase 3: Go down to final position (3x faster)
        local phase3Time = phase3Distance / (dynamicSpeed * 3) -- 3x faster descending
        local downTween = TweenService:Create(rootPart, TweenInfo.new(phase3Time, Enum.EasingStyle.Linear), {
            CFrame = CFrame.new(finalPositionAbove)
        })
        
        downTween:Play()
        downTween.Completed:Wait()
        
        -- Fix character state after teleport
        task.wait(0.1)
        
        local humanoid = rootPart.Parent:FindFirstChild("Humanoid")
        if humanoid then
            -- Reset character state
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
            
            -- Ensure character is upright
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            -- Set proper CFrame orientation (upright)
            local currentPos = rootPart.Position
            rootPart.CFrame = CFrame.new(currentPos, currentPos + Vector3.new(0, 0, -1))
        end
        
        return true
    end

    -- Find closest CashMultiplierDisplay.DisplayPart from any base
    local function findClosestCashMultiplierPart(playerPosition)
        local closestPart = nil
        local closestDistance = math.huge
        
        for _, baseInfo in pairs(allBases) do
            if baseInfo.base and baseInfo.base:FindFirstChild("_PERMANENT") then
                local permanent = baseInfo.base:FindFirstChild("_PERMANENT")
                local cashMultiplierDisplay = permanent:FindFirstChild("CashMultiplierDisplay")
                if cashMultiplierDisplay then
                    local displayPart = cashMultiplierDisplay:FindFirstChild("DisplayPart")
                    if displayPart and displayPart:IsA("BasePart") then
                        local distance = (displayPart.Position - playerPosition).Magnitude
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPart = displayPart.Position + Vector3.new(0, 5, 0) -- 5 studs above
                        end
                    end
                end
            end
        end
        
        if closestPart then
            return closestPart
        else
            return nil
        end
    end

    -- Use selected teleport method with staging
    local teleportStartTime = tick()
    local success, error = pcall(function()
        if teleportMethod == "instant" then
            -- Instant teleport (risky) - but add delay to reach minimum time
            humanoidRootPart.CFrame = CFrame.new(targetPosition)
            
            -- Add delay to ensure minimum 3.2 seconds total
            local remainingTime = minimumTravelTime - (tick() - teleportStartTime)
            if remainingTime > 0 then
                task.wait(remainingTime)
            end
        elseif teleportMethod == "underground" then
            -- Underground teleport (deep stealth)
        undergroundTeleport(humanoidRootPart, targetPosition)
        else
            -- Two-stage air teleport: closest CashMultiplier first, then final destination
            local stagingPoint = findClosestCashMultiplierPart(humanoidRootPart.Position)
            
            if stagingPoint then
                -- Stage 1: Instant teleport to closest staging point
                humanoidRootPart.CFrame = CFrame.new(stagingPoint)
                
                -- Small delay to ensure teleport registers
                task.wait(0.1)
                
                -- Stage 2: Air travel from staging point to final destination
                airTeleport(humanoidRootPart, targetPosition)
            else
                -- No staging point found, use normal air teleport
                airTeleport(humanoidRootPart, targetPosition)
            end
            
            -- Ensure minimum time is met for air travel too
            local totalElapsed = tick() - teleportStartTime
            local remainingTime = minimumTravelTime - totalElapsed
            if remainingTime > 0 then
                task.wait(remainingTime)
            end
        end
    end)
    
    -- Clear teleporting flag
    isTeleporting = false
    

    

end

-- Auto Teleport After Stealing Functions
local function enableAutoTeleport()
    if robberyConnection then
        robberyConnection:Disconnect()
    end
    
    local player = Players.LocalPlayer
    
    -- Monitor the player's "Stealing" attribute - this gets set immediately when they start stealing
    robberyConnection = player:GetAttributeChangedSignal("Stealing"):Connect(function()
        local isCurrentlyStealing = player:GetAttribute("Stealing")
        
        if isCurrentlyStealing and autoTeleportAfterSteal then
            -- TELEPORT IMMEDIATELY - NO WAITING
            if myBase and autoTeleportAfterSteal then
                teleportToMyBase()
            end
        end
    end)
end

local function disableAutoTeleport()
    if robberyConnection then
        robberyConnection:Disconnect()
        robberyConnection = nil
    end
end

-- Instant Interact Functions (Remove Hold Time)
local function enableInstantInteract()
    -- Set all proximity prompts to have 0 hold duration
    for _, prompt in pairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            if not originalHoldDurations[prompt] then
                originalHoldDurations[prompt] = prompt.HoldDuration
            end
            prompt.HoldDuration = 0
        end
    end
    
    -- Monitor for new proximity prompts
    if instantInteractConnection then
        instantInteractConnection:Disconnect()
    end
    
    instantInteractConnection = workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ProximityPrompt") and instantInteractEnabled then
            task.wait(0.1) -- Small delay to ensure prompt is fully loaded
            if descendant.Parent and instantInteractEnabled then
                originalHoldDurations[descendant] = descendant.HoldDuration
                descendant.HoldDuration = 0
            end
        end
    end)
end

local function disableInstantInteract()
    -- Restore original hold durations
    for prompt, originalDuration in pairs(originalHoldDurations) do
        if prompt and prompt.Parent then
            prompt.HoldDuration = originalDuration
        end
    end
    originalHoldDurations = {}
    
    if instantInteractConnection then
        instantInteractConnection:Disconnect()
        instantInteractConnection = nil
    end
end

-- Manual lock function (teleport to specific Lock button and back)
local function lockBaseNow()
    local success = false
    
    pcall(function()
        if myBase and myBase.base then
            local character = Players.LocalPlayer.Character
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            
            if not humanoidRootPart then
                return
            end
            
            -- Save current position
            local originalPosition = humanoidRootPart.CFrame
            
            local permanent = myBase.base:FindFirstChild("_PERMANENT")
            if permanent then
                local baseEntrance = permanent:FindFirstChild("BaseEntrance")
                if baseEntrance then
                    local lockPad = baseEntrance:FindFirstChild("LockPad")
                    if lockPad then
                        local lockTogglePad = lockPad:FindFirstChild("LockTogglePad")
                        if lockTogglePad and lockTogglePad:IsA("BasePart") then
                            -- Step 1: Teleport above the LockTogglePad
                            local padPosition = lockTogglePad.CFrame + Vector3.new(0, 5, 0) -- 5 studs above
                            humanoidRootPart.CFrame = padPosition
                            
                            -- Step 2: Wait a moment for game to register
                            task.wait(0.5)
                            
                            -- Step 3: Move down to touch the LockTogglePad
                            humanoidRootPart.CFrame = lockTogglePad.CFrame + Vector3.new(0, 2, 0) -- Just above pad
                            
                            -- Step 4: Try to trigger the pad
                            task.wait(0.1)
                            
                            -- Try multiple methods to activate the pad
                            pcall(function()
                                -- Method 1: Fire Touched event
                                if lockTogglePad.Touched then
                                    lockTogglePad.Touched:Fire(humanoidRootPart)
                                end
                            end)
                            
                            pcall(function()
                                -- Method 2: Check for ClickDetector
                                local clickDetector = lockTogglePad:FindFirstChildOfClass("ClickDetector")
                                if clickDetector then
                                    fireclickdetector(clickDetector)
                                end
                            end)
                            
                            pcall(function()
                                -- Method 3: Check for ProximityPrompt
                                local proximityPrompt = lockTogglePad:FindFirstChildOfClass("ProximityPrompt")
                                if proximityPrompt then
                                    fireproximityprompt(proximityPrompt)
                                end
                            end)
                            
                            -- Step 5: Wait for activation to register
                            task.wait(0.5)
                            
                            -- Step 6: Teleport back to original position
                            humanoidRootPart.CFrame = originalPosition
                            
                            success = true
                        end
                    end
                end
            end
        end
    end)
    

end

-- Auto Lock Base Functions
local function enableAutoLock()
    if lockConnection then
        lockConnection:Disconnect()
    end
    
    -- Check every second if base is locked, if not - lock it
    lockConnection = task.spawn(function()
        while autoLockEnabled do
            pcall(function()
                -- Skip auto-lock if currently teleporting
                if isTeleporting then
                    return
                end
                
                if myBase and myBase.base then
                    local permanent = myBase.base:FindFirstChild("_PERMANENT")
                    if permanent then
                        local baseEntrance = permanent:FindFirstChild("BaseEntrance")
                        if baseEntrance then
                            local lockPad = baseEntrance:FindFirstChild("LockPad")
                            if lockPad then
                                local lockTogglePad = lockPad:FindFirstChild("LockTogglePad")
                                if lockTogglePad then
                                    -- Check if base is locked by checking LockTogglePad attributes or other indicators
                                    local isLocked = lockTogglePad:GetAttribute("Locked") or lockPad:GetAttribute("Locked") or baseEntrance:GetAttribute("Locked")
                                    
                                    -- If base is NOT locked (nil or false means unlocked)
                                    if not isLocked then
                                        -- Call lockBaseNow with extra debugging
                                        local success, error = pcall(lockBaseNow)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            
            -- Check every second
            task.wait(1)
        end
    end)
end

local function disableAutoLock()
    if lockConnection then
        task.cancel(lockConnection)
        lockConnection = nil
    end
end

-- Auto Collect Money Functions
local function enableAutoCollect()
    if collectConnection then
        collectConnection:Disconnect()
    end
    
    -- Auto collect money using firetouchinterest on IncomeClaimPad parts
    collectConnection = task.spawn(function()
        while autoCollectEnabled do
            pcall(function()
                if myBase and myBase.base then
                    local permanent = myBase.base:FindFirstChild("_PERMANENT")
                    if permanent then
                        local unitsPads = permanent:FindFirstChild("UnitsPads")
                        if unitsPads then
                            local character = player.Character
                            if character then
                                local hrp = character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    -- Find all IncomeClaimPad parts and touch them
                                    for _, pad in ipairs(unitsPads:GetChildren()) do
                                        local claimPad = pad:FindFirstChild("IncomeClaimPad")
                                        if claimPad then
                                            firetouchinterest(hrp, claimPad, 0)
                                            task.wait(0.1)
                                            firetouchinterest(hrp, claimPad, 1)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end)
            
            -- Collect every 5 seconds
            task.wait(5)
        end
    end)
    

end

local function disableAutoCollect()
    if collectConnection then
        task.cancel(collectConnection)
        collectConnection = nil
    end
end

-- Modify initialize function to require key validation
local function initialize()
    -- Ensure HTTP requests are enabled
    if not HttpService.HttpEnabled then
        HttpService.HttpEnabled = true
    end
    
    -- Wait for character to load
    if not player.Character then
        player.CharacterAdded:Wait()
    end
    
    -- Show key input UI
    showKeyInputUI()
end

-- Create OverHeaven UI
local Window = OverHeavenLib:MakeWindow({
    Name = "Steal Everything Hub",
    ConfigFolder = "StealEverythingHub",
    SaveConfig = false,
    IntroEnabled = true,
    IntroText = "StealEverythingHub"
})

-- Create Main Tab
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "home"
})

local MainSection = MainTab:AddSection({
    Name = "Base Controls"
})

-- Teleport to Home Button
MainSection:AddButton({
    Name = "Teleport to Base",
    Callback = function()
        teleportToMyBase()
    end
})

-- Auto Teleport Toggle
MainSection:AddToggle({
    Name = "Auto Teleport After Steal",
    Default = false,
    Callback = function(Value)
        autoTeleportAfterSteal = Value
        if Value then
            enableAutoTeleport()
        else
            disableAutoTeleport()
        end
    end
})

-- Base Security Section
local SecuritySection = MainTab:AddSection({
    Name = "Base Locking"
})

-- Lock Base Now Button
SecuritySection:AddButton({
    Name = "Lock Base Now",
    Callback = function()
        lockBaseNow()
    end
})

-- Auto Lock Toggle
SecuritySection:AddToggle({
    Name = "Auto Lock Base",
    Default = false,
    Callback = function(Value)
        autoLockEnabled = Value
        if Value then
            enableAutoLock()
        else
            disableAutoLock()
        end
    end
})

-- Money Section
local MoneySection = MainTab:AddSection({
    Name = "Money Collection"
})

-- Auto Collect Toggle
MoneySection:AddToggle({
    Name = "Auto Collect Money",
    Default = false,
    Callback = function(Value)
        autoCollectEnabled = Value
        if Value then
            enableAutoCollect()
        else
            disableAutoCollect()
        end
    end
})

-- Settings Tab
local SettingsTab = Window:MakeTab({
    Name = "Settings",
    Icon = "settings"
})

local TeleportSection = SettingsTab:AddSection({
    Name = "Teleport Settings"
})

-- Air Travel Height Slider
TeleportSection:AddSlider({
    Name = "Air Travel Height",
    Min = 10,
    Max = 100,
    Default = airTravelHeight,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 5,
    Callback = function(Value)
        airTravelHeight = Value
    end
})

-- Run the initialization
-- Remove the direct call to initialize()
-- The initialization will now be triggered after key validation

-- Export functions for external use
return {
    identifyMyBase = identifyMyBase,
    teleportToMyBase = teleportToMyBase,
    getMyBase = function() return myBase end,
    getAllBases = function() return allBases end
}
