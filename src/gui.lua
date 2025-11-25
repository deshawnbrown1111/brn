-- // GUI System
-- // Handles all UI elements and interactions
-- // Load: loadstring(game:HttpGet("GUI_URL"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Config = _G.AltConfig

local gui = Instance.new("ScreenGui")
gui.Name = "AltController"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Multiple shadow layers for smooth black glow effect
local shadows = {}
local shadowOffsets = {20, 15, 10, 7, 5, 3, 2} -- Progressive offsets for smooth glow
local shadowTransparencies = {0.95, 0.90, 0.85, 0.80, 0.75, 0.70, 0.65} -- Outer to inner

for i = 1, #shadowOffsets do
    local offset = shadowOffsets[i]
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(0, 640 + (offset * 2), 0, 56 + (offset * 2))
    shadow.Position = UDim2.new(0.5, -(320 + offset), 0.5, -(28 + offset))
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = shadowTransparencies[i]
    shadow.BorderSizePixel = 0
    shadow.Visible = false
    shadow.ZIndex = 0
    shadow.Parent = gui
    
    -- Add gradient for smooth fade-out glow effect
    local shadowGradient = Instance.new("UIGradient", shadow)
    shadowGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })
    -- Create smooth radial-like fade from center to edges
    local baseTransparency = shadowTransparencies[i]
    shadowGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, baseTransparency), -- Center
        NumberSequenceKeypoint.new(0.15, baseTransparency + 0.05), -- Slight fade
        NumberSequenceKeypoint.new(0.4, baseTransparency + 0.15), -- More fade
        NumberSequenceKeypoint.new(0.7, baseTransparency + 0.3), -- Strong fade
        NumberSequenceKeypoint.new(1, 1) -- Fully transparent at edges
    })
    shadowGradient.Rotation = 0 -- No rotation for radial effect
    
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 18 + offset)
    table.insert(shadows, shadow)
end

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, 640, 0, 56)
bar.Position = UDim2.new(0.5, -320, 0.5, -28)
bar.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
bar.BackgroundTransparency = 1
bar.BorderSizePixel = 0
bar.Visible = false
bar.ZIndex = 1
bar.Parent = gui

local corner = Instance.new("UICorner", bar)
corner.CornerRadius = UDim.new(0, 18)

-- Gradient background
local gradient = Instance.new("UIGradient", bar)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 28))
})
gradient.Rotation = 90

-- Theme selector at the top
local themeSelector = Instance.new("TextButton", bar)
themeSelector.Size = UDim2.new(0, 80, 0, 20)
themeSelector.Position = UDim2.new(1, -90, 0, 4)
themeSelector.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
themeSelector.BackgroundTransparency = 0.3
themeSelector.BorderSizePixel = 0
themeSelector.Text = Config.altSettings["Theme"] or "Dark"
themeSelector.TextColor3 = Color3.fromRGB(200, 200, 210)
themeSelector.Font = Enum.Font.Gotham
themeSelector.TextSize = 12
themeSelector.ZIndex = 10
Instance.new("UICorner", themeSelector).CornerRadius = UDim.new(0, 6)

-- Theme colors
local themes = {
    Dark = {
        bg1 = Color3.fromRGB(25, 25, 35),
        bg2 = Color3.fromRGB(18, 18, 28),
        text = Color3.fromRGB(240, 240, 250),
        placeholder = Color3.fromRGB(120, 120, 130),
        prefix = Color3.fromRGB(200, 200, 210),
        auto = Color3.fromRGB(150, 150, 160)
    },
    Light = {
        bg1 = Color3.fromRGB(240, 240, 245),
        bg2 = Color3.fromRGB(250, 250, 255),
        text = Color3.fromRGB(20, 20, 25),
        placeholder = Color3.fromRGB(100, 100, 110),
        prefix = Color3.fromRGB(40, 40, 50),
        auto = Color3.fromRGB(80, 80, 90)
    }
}

local function applyTheme(themeName)
    local theme = themes[themeName] or themes.Dark
    Config.altSettings["Theme"] = themeName
    themeSelector.Text = themeName
    
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, theme.bg1),
        ColorSequenceKeypoint.new(1, theme.bg2)
    })
    input.TextColor3 = theme.text
    input.PlaceholderColor3 = theme.placeholder
    prefixLabel.TextColor3 = theme.prefix
    auto.TextColor3 = theme.auto
end

themeSelector.MouseButton1Click:Connect(function()
    local current = Config.altSettings["Theme"] or "Dark"
    local nextTheme = current == "Dark" and "Light" or "Dark"
    applyTheme(nextTheme)
end)

-- Prefix label with better styling
local prefixLabel = Instance.new("TextLabel", bar)
prefixLabel.Size = UDim2.new(0, 60, 1, 0)
prefixLabel.Position = UDim2.new(0, 20, 0, 0)
prefixLabel.BackgroundTransparency = 1
prefixLabel.Text = "K"
prefixLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
prefixLabel.Font = Enum.Font.GothamBold
prefixLabel.TextSize = 28
prefixLabel.TextStrokeTransparency = 0.7
prefixLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local input = Instance.new("TextBox", bar)
input.Size = UDim2.new(1, -100, 1, -16)
input.Position = UDim2.new(0, 88, 0, 8)
input.BackgroundTransparency = 1
input.PlaceholderText = "tp • attach [name] • rotate [name] • unattach • kill • sandwich [name] • fling [name]"
input.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
input.TextColor3 = Color3.fromRGB(240, 240, 250)
input.Font = Enum.Font.GothamSemibold
input.TextSize = 20
input.TextXAlignment = Enum.TextXAlignment.Left
input.ClearTextOnFocus = false
input.TextStrokeTransparency = 0.8
input.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- AUTOCOMPLETE
local auto = Instance.new("TextLabel")
auto.Parent = bar
auto.BackgroundTransparency = 1
auto.Position = UDim2.new(0, 88, 1, -2)
auto.Size = UDim2.new(1, -100, 0, 22)
auto.Font = Enum.Font.Gotham
auto.TextSize = 18
auto.TextXAlignment = Enum.TextXAlignment.Left
auto.TextColor3 = Color3.fromRGB(150, 150, 160)
auto.Text = ""
auto.TextStrokeTransparency = 0.9
auto.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local commands = {"tp", "attach", "rotate", "unattach", "kill", "sandwich", "fling"}

-- helper: find best player match from partial (prefix)
local function findBestPlayerMatch(prefix)
    if not prefix or prefix == "" then return nil end
    prefix = prefix:lower()
    local exact = nil
    local starts = nil
    for _, p in ipairs(Players:GetPlayers()) do
        local name = p.Name or ""
        local dname = p.DisplayName or ""
        if name:lower() == prefix or dname:lower() == prefix then
            exact = name
            break
        end
        if name:lower():sub(1, #prefix) == prefix or dname:lower():sub(1, #prefix) == prefix then
            if not starts then starts = name end
        end
    end
    return exact or starts
end

local function updateAuto()
    local txt = input.Text
    local trimmed = txt:match("^%s*(.-)%s*$") or ""
    if trimmed == "" then
        auto.Text = ""
        return
    end

    -- split into tokens
    local tokens = {}
    for part in trimmed:gmatch("%S+") do table.insert(tokens, part) end
    local first = tokens[1] and tokens[1]:lower() or ""

    -- if user is typing the first token -> suggest commands
    if #tokens == 1 then
        if first == "" then auto.Text = "" return end
        for _, cmd in ipairs(commands) do
            if cmd:sub(1, #first) == first then
                auto.Text = cmd
                return
            end
        end
        auto.Text = ""
        return
    end

    -- if typing second token (username) -> suggest player names
    if #tokens >= 2 then
        local partial = tokens[2]
        local match = findBestPlayerMatch(partial)
        if match then
            auto.Text = first .. " " .. match
            return
        end
        auto.Text = ""
        return
    end
end

-- Remove "K" prefix if typed as first character and update autocomplete
input:GetPropertyChangedSignal("Text"):Connect(function()
    local txt = input.Text
    -- Remove K if it's the first character (case insensitive)
    if txt:len() > 0 and txt:sub(1, 1):upper() == "K" then
        -- If it's just "K" or "K " or "K" followed by more text, remove the K
        if txt:len() == 1 then
            input.Text = ""
            return
        else
            -- Remove K and any space after it
            local rest = txt:sub(2)
            if rest:sub(1, 1) == " " then
                rest = rest:sub(2)
            end
            input.Text = rest
            return
        end
    end
    updateAuto()
end)

-- TAB completion: completes command OR username depending on where caret is
UserInputService.InputBegan:Connect(function(key, gp)
    if gp then return end
    if key.KeyCode == Enum.KeyCode.Tab and auto.Text ~= "" then
        local current = input.Text
        local trimmed = current:match("^%s*(.-)%s*$") or ""
        -- if there's a space -> complete second token only
        if trimmed:find("%s") then
            -- split
            local tokens = {}
            for part in trimmed:gmatch("%S+") do table.insert(tokens, part) end
            local first = tokens[1] and tokens[1]:lower() or ""
            -- auto.Text contains "first match" or "first matchname"
            local parts = {}
            for part in auto.Text:gmatch("%S+") do table.insert(parts, part) end
            if #parts >= 2 then
                input.Text = first .. " " .. parts[2]
                auto.Text = ""
            else
                input.Text = auto.Text
                auto.Text = ""
            end
        else
            -- no space -> complete command
            input.Text = auto.Text
            auto.Text = ""
        end
    end
end)

-- DRAGGING - move bar and all shadows together
local dragging = false
local dragConnection = nil
bar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        local startPos = bar.Position
        local startMouse = inp.Position
        local con
        con = inp.Changed:Connect(function()
            if inp.UserInputState == Enum.UserInputState.End then
                dragging = false
                if dragConnection then
                    dragConnection:Disconnect()
                    dragConnection = nil
                end
                con:Disconnect()
            end
        end)
        dragConnection = UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = i.Position - startMouse
                local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                bar.Position = newPos
                -- Move all shadows with the bar (maintain relative offsets)
                for idx, shadow in ipairs(shadows) do
                    local offset = shadowOffsets[idx]
                    shadow.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - offset, newPos.Y.Scale, newPos.Y.Offset - offset)
                end
            end
        end)
    end
end)

-- parse and execute input text
local function parseTokens(text)
    local tokens = {}
    for part in text:gmatch("%S+") do table.insert(tokens, part) end
    return tokens
end

local function execute(text)
    local tokens = parseTokens(text)
    if #tokens == 0 then return false end
    local cmd = tokens[1]:lower()

    -- helper to resolve a target player name from optional partial
    local function resolveTarget(partial)
        if partial and partial ~= "" then
            local match = findBestPlayerMatch(partial)
            return match or partial
        end
        return LocalPlayer.Name
    end

    if cmd == "tp" then
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("tpToMe", { LocalPlayer.Name })
        end
        return true
    elseif cmd == "attach" then
        local target = resolveTarget(tokens[2])
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("attach", { target })
        end
        if _G.AltAttachment then
            _G.AltAttachment.startAttach(target, false, 1)
        end
        return true
    elseif cmd == "rotate" then
        local target = resolveTarget(tokens[2])
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("rotate", { target })
        end
        if _G.AltAttachment then
            _G.AltAttachment.startAttach(target, true, 1)
        end
        return true
    elseif cmd == "unattach" then
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("unattach", {})
        end
        if _G.AltAttachment then
            _G.AltAttachment.stopAttach()
        end
        return true
    elseif cmd == "kill" then
        -- IMPORTANT: do NOT self-kill on main; only instruct alts
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("kill", {})
        end
        return true
    elseif cmd == "sandwich" then
        local target = resolveTarget(tokens[2])
        local distance = tonumber(tokens[3]) or 4 -- Default distance of 4 studs
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("sandwich", { target, distance })
        end
        return true
    elseif cmd == "fling" then
        local target = resolveTarget(tokens[2])
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("fling", { target })
        end
        return true
    end

    return false
end

-- OPEN / HIDE
local open = false
local function show()
    if open then return end
    open = true
    -- Show all shadows
    for _, shadow in ipairs(shadows) do
        shadow.Visible = true
    end
    bar.Visible = true
    input:CaptureFocus()
    input.Text = "" -- Clear text when opening
    auto.Text = ""
    TweenService:Create(bar, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 }):Play()
    -- Animate all shadows with their respective transparencies
    for idx, shadow in ipairs(shadows) do
        TweenService:Create(shadow, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = shadowTransparencies[idx] }):Play()
    end
end

local function hide()
    if not open then return end
    open = false
    TweenService:Create(bar, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    -- Hide all shadows
    for _, shadow in ipairs(shadows) do
        TweenService:Create(shadow, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    end
    local t = TweenService:Create(bar, TweenInfo.new(0.2), {})
    t:Play()
    t.Completed:Wait()
    bar.Visible = false
    for _, shadow in ipairs(shadows) do
        shadow.Visible = false
    end
end

-- OPEN HOTKEY
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if inp.KeyCode == Config.OPEN_KEY then
        if open then
            -- If already open, prevent K from being typed
            return
        end
        show()
    elseif inp.KeyCode == Enum.KeyCode.E then
        if _G.AltCommands then
            _G.AltCommands.sendToAlts("kill", {})
        end
    end
end)

-- CLEAR TEXT AFTER EXECUTE
input.FocusLost:Connect(function(enter)
    if enter and input.Text ~= "" then
        if execute(input.Text) then
            input.Text = ""
            auto.Text = ""
        end
    end
    task.wait(0.15)
    hide()
end)

-- Apply initial theme
applyTheme(Config.altSettings["Theme"] or "Dark")

print("Alt Controller Active → Press K anytime to control alts")

