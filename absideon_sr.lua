local ffi = require("ffi")

local function normalize(angle)
    while angle > 180 do
        angle = angle - 360
    end
    while angle < -180 do
        angle = angle + 360
    end

    return angle
end

local function contains(table, val)
    for i = 1, #table do
        if table[i] == val then
            return true
        end
    end
    return false
end

local indicator = {}
local function on_indicator(i)
    table.insert(indicator, i)
end
client.set_event_callback("indicator", on_indicator)


local moving = false
local function ismoving(c)
    if c.sidemove == 0 and c.forwardmove == 0 then
        moving = false
    else
        moving = true
    end
end
client.set_event_callback("setup_command", ismoving)

local function GetDistanceInFeet(a_x, a_y, a_z, b_x, b_y, b_z)
    return math.ceil(math.sqrt(math.pow(a_x - b_x, 2) + math.pow(a_y - b_y, 2) + math.pow(a_z - b_z, 2)) * 0.0254 / 0.3048)
end

ffi.cdef[[ 
        typedef void***(__thiscall* FindHudElement_t)(void*, const char*); 
        typedef struct { 
            char pad[0x58];
            bool isChatOpen;
        } CCSGO_HudChat;
]]

    local signature_gHud = "\xB9\xCC\xCC\xCC\xCC\x88\x46\x09"
    local signature_FindElement = "\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x57\x8B\xF9\x33\xF6\x39\x77\x28"

    local match = client.find_signature("client.dll", signature_gHud) or error("sig1 not found")
    local char_match = ffi.cast("char*", match) + 1
    local hud = ffi.cast("void**", char_match)[0] or error("hud is nil")
    local match = client.find_signature("client.dll", signature_FindElement) or error("FindHudElement not found")
    local find_hud_element = ffi.cast("FindHudElement_t", match)
    local hudElement = find_hud_element(hud, "CCSGO_HudChat") or error("CCSGO_HudChat not found")
    local hudChat
    if (hudElement ~= nil) then
        hudChat = ffi.cast("CCSGO_HudChat*", hudElement)
    end

function initHudChat()
    hudElement = find_hud_element(hud, "CCSGO_HudChat") or error("CCSGO_HudChat not found")
    if (hudElement ~= nil) then
        hudChat = ffi.cast("CCSGO_HudChat*", hudElement)
    end
end
client.set_event_callback("player_connect_full", initHudChat)

--[[ 
MENU STUFF
 ]]

local dynFOV = ui.new_combobox("rage", "other", "Dynamic FOV", {"Off", "Low", "Medium", "High", "Maximum"})
local dynFOV_max = ui.new_slider("rage", "other", "Max FOV", 1, 16, 10, true, "")
local dynAWALL = ui.new_combobox("rage", "other", "Dynamic Autowall", {"Off", "On visible", "Always on"})
local dynAWALL_time = ui.new_slider("rage", "other", "Visible time", 1, 10, 2, true, "s")
local indicators = ui.new_multiselect("rage", "other", "Indicators", {"Antiaim", "Desync arrows", "Autowall", "Field of view", "Force body aim", "Safe point", "Fake lag"})
local indicator_size = ui.new_combobox("rage", "other", "Indicator size", {"Small", "Large"})
local resolver = ui.new_combobox("rage", "other", "Legit anti-aim correction", {"Off", "Bruteforce", "Opposite"})
local resolver_override = ui.new_hotkey("rage", "other", "override", true)
local resolver_override_delay = ui.new_slider("rage", "other", "Override delay", 1, 100, 10, true, "ms")
local legitaa_mode = ui.new_combobox("aa", "anti-aimbot angles", "Mode", {"Off", "Manual", "Freestanding"})
local legitaa_key = ui.new_hotkey("aa", "anti-aimbot angles", "keybind", true)
local legitaa_lbyt = ui.new_combobox("aa", "anti-aimbot angles", "Lowerbody yaw target", {"Off", "Opposite", "Eye yaw"})
local legitaa_moving = ui.new_combobox("aa", "anti-aimbot angles", "Lowerbody yaw target moving", {"Off", "Opposite", "Eye yaw"})
local legitaa_jitter = ui.new_checkbox("aa", "anti-aimbot angles", "Jitter")
local legitaa_jitter_v = ui.new_slider("aa", "anti-aimbot angles", "\n", 0, 60, 7, true, "°")
local legitaa_fyl = ui.new_slider("aa", "anti-aimbot angles", "Fake yaw limit", 0, 60, 59, true, "°")

local target_switch = ui.new_checkbox("rage", "other", "Target switch delay")
local target_switch_delay = ui.new_slider("rage", "other", "\n", 0, 1000, 500, true, "ms")
local force_aw = ui.new_hotkey("rage", "other", "Force autowall", false)
local logging = ui.new_multiselect("rage", "other", "Logs", {"Bruteforce", "Damage taken"})

local easteregg = ui.new_checkbox("misc", "settings", "Easter egg")
local fakelag_flags = ui.new_combobox("aa", "fake lag", "Flags", {"Default", "On peek"})
local fakelag_peek_time = ui.new_slider("aa", "fake lag", "On peek time", 1, 100, 10, true, "ms")
local fakelag_override = ui.new_checkbox("aa", "fake lag", "Override limit on peek")

local menu = {
    rage_autowall = ui.reference("rage", "aimbot", "automatic penetration"),
    rage_fov = ui.reference("rage", "aimbot", "maximum fov"),

    fakelag_enabled = ui.reference("aa", "fake lag", "enabled"),
    fakelag_amount = ui.reference("aa", "fake lag", "amount"),
    fakelag_varience = ui.reference("aa", "fake lag", "variance"),
    fakelag_limit = ui.reference("aa", "fake lag", "limit"),

    antiaim_pitch = ui.reference("aa", "anti-aimbot angles", "pitch"),
    antiaim_yawbase = ui.reference("aa", "anti-aimbot angles", "yaw base"),
    antiaim_yaw = {ui.reference("aa", "anti-aimbot angles", "yaw")},
    antiaim_jitter = {ui.reference("aa", "anti-aimbot angles", "yaw jitter")},
    antiaim_bodyyaw = {ui.reference("aa", "anti-aimbot angles", "body yaw")},
    antiaim_byfreestanding = ui.reference("aa", "anti-aimbot angles", "freestanding body yaw"),
    antiaim_lbyt = ui.reference("aa", "anti-aimbot angles", "lower body yaw target"),
    antiaim_fyl = ui.reference("aa", "anti-aimbot angles", "fake yaw limit"),
    antiaim_edge = ui.reference("aa", "anti-aimbot angles", "edge yaw"),
    antiaim_freestanding = {ui.reference("aa", "anti-aimbot angles", "freestanding")}
}

client.set_event_callback("paint_ui", function()
    ui.set_visible(menu.fakelag_amount, false)
    ui.set_visible(menu.fakelag_varience, false)
    ui.set_visible(menu.fakelag_limit, false)
    
    ui.set_visible(dynFOV_max, ui.get(dynFOV) == "Low")
    ui.set_visible(target_switch_delay, ui.get(target_switch))
    ui.set_visible(legitaa_jitter_v, ui.get(legitaa_jitter))
    ui.set_visible(dynAWALL_time, ui.get(dynAWALL) == "On visible")
    ui.set_visible(indicator_size, contains(ui.get(indicators), "Desync arrows"))
    ui.set_visible(fakelag_peek_time, ui.get(fakelag_flags) == "On peek")
    ui.set_visible(fakelag_override, ui.get(fakelag_flags) == "On peek")
    ui.set_visible(legitaa_key, ui.get(legitaa_mode) == "Manual")
    ui.set_visible(resolver_override, ui.get(resolver) == "Bruteforce")
    ui.set_visible(legitaa_fyl, not ui.get(legitaa_jitter))
    ui.set_visible(resolver_override_delay, ui.get(resolver) == "Bruteforce")

    ui.set_visible(menu.antiaim_pitch, false)
    ui.set_visible(menu.antiaim_yawbase, false)
    
    ui.set_visible(menu.antiaim_byfreestanding, false)
    
    ui.set_visible(menu.antiaim_lbyt, false)
    ui.set_visible(menu.antiaim_fyl, false)
    ui.set_visible(menu.antiaim_edge, false)

    for i=1, #menu.antiaim_yaw do
        ui.set_visible(menu.antiaim_yaw[i], false)
    end
    
    for i=1, #menu.antiaim_jitter do
        ui.set_visible(menu.antiaim_jitter[i], false)
    end
    for i=1, #menu.antiaim_bodyyaw do
        ui.set_visible(menu.antiaim_bodyyaw[i], false)
    end
    for i=1, #menu.antiaim_freestanding do
        ui.set_visible(menu.antiaim_freestanding[i], false)
    end
end)

--[[ FAKE LAG ON PEEK ]]
local fakelag_limit = 4
local fakelag_visible = false
ffi.cdef[[
    typedef bool(__thiscall* lgts)(float, float, float, float, float, float, short);
]]

local signature = "\x55\x8B\xEC\x83\xEC\x08\x8B\x15\xCC\xCC\xCC\xCC\x0F\x57"
local match = client.find_signature("client.dll", signature)
local through_smoke = ffi.cast("lgts", match)
local function on_peek()
    ui.set(menu.fakelag_limit, fakelag_limit)
    if ui.get(fakelag_flags) == "On peek" then
        for _, v in pairs(entity.get_players(true)) do
            local hitbox_position = {entity.hitbox_position(v, 0)}
            local eye_pos = {client.eye_position()}
            local fraction, v_hit = client.trace_line(entity.get_local_player(), eye_pos[1], eye_pos[2], eye_pos[3], hitbox_position[1], hitbox_position[2], hitbox_position[3])
            local insmoke = through_smoke(eye_pos[1], eye_pos[2], eye_pos[3], hitbox_position[1], hitbox_position[2], hitbox_position[3], 1)
            if (v_hit == v or fraction == 1) and not insmoke then
                fakelag_visible = true
            else
                client.delay_call(ui.get(fakelag_peek_time)/100, function()
                    fakelag_visible = false
                end)
            end
            ui.set(menu.fakelag_enabled, fakelag_visible)
            if ui.get(fakelag_override) then
                ui.set(menu.fakelag_limit, fakelag_visible and 14 or 4 )
            end
        end
    end
end
client.set_event_callback("run_command", on_peek)

--[[ 
SOME AUTISTIC AA STUFF
 ]]

local function aa_stuff()
    if ui.get(ui.reference("rage", "other", "duck peek assist")) then fakelag_limit = 14 else fakelag_limit = 4 end
    local key = ui.get(legitaa_key)
    local mode = ui.get(legitaa_mode)
    local lbyt = ui.get(legitaa_lbyt)
    local lbyt_moving = ui.get(legitaa_moving)
    local jitter = ui.get(legitaa_jitter)
    ui.set(menu.antiaim_yawbase, false and "At targets" or "Local view")
    ui.set(menu.antiaim_lbyt, false and "Off" or "Opposite")
    ui.set(menu.antiaim_pitch, false and "Off" or "Off")
    ui.set(menu.antiaim_byfreestanding, false)
    ui.set(menu.antiaim_yaw[1], false and "Off" or "Off")
    ui.set(menu.antiaim_bodyyaw[1], false and "Off" or "Static")
    ui.set(menu.antiaim_freestanding[1], false and "" or "")
    ui.set(menu.antiaim_edge, false)
    ui.set(menu.antiaim_bodyyaw[1], ui.get(legitaa_jitter) and "Jitter" or "Static")
    ui.set(menu.antiaim_fyl, ui.get(legitaa_jitter) and 59 or ui.get(legitaa_fyl))
    ui.set(menu.antiaim_bodyyaw[2], ui.get(legitaa_jitter) and ui.get(legitaa_jitter_v) or 60)

    ui.set(menu.antiaim_byfreestanding, mode == "Freestanding")
    ui.set(menu.antiaim_lbyt, moving and lbyt_moving or lbyt)
    ui.set(menu.antiaim_bodyyaw[2], mode == "Manual" and key and 60 or -60 )
end
client.set_event_callback("run_command", aa_stuff)

client.register_esp_flag("BAIM", 230, 126, 34, function(i)
    if plist.get(i, "Override prefer body aim") == "On" then return true end
end)

client.register_esp_flag("FBAIM", 231, 76, 60, function(i)
    if plist.get(i, "Override prefer body aim") == "Force" then return true end
end)

client.register_esp_flag("SP", 241, 196, 15, function(i)
    if plist.get(i, "Override safe point") == "On" then return true end
end)

client.register_esp_flag("LEFT", 231, 76, 60, function(e)
    if plist.get(e, "Force body yaw value") == -60 then
        return true end
end)

client.register_esp_flag("RIGHT", 231, 76, 60, function(e)
    if plist.get(e, "Force body yaw value") == 60 then
        return true end
end)

--[[ 
LEGITAACORRECTION & OVERRIDE
 ]]

local delay = true
local missed = {}
local meme = 0
client.set_event_callback("run_command", function()
    local enemies = entity.get_players(true)
    if ui.get(resolver_override) and delay and ui.get(resolver) == "Bruteforce" then
        for i=1, #enemies do
            local enemy = enemies[i]
            delay = false
            client.delay_call(ui.get(resolver_override_delay)/100, function()
                delay = true
            end)
            if plist.get(enemy, "Force body yaw value") == 0 then
                plist.set(enemy, "Force body yaw", true)
                plist.set(enemy, "Force body yaw value", -60)
            elseif plist.get(enemy, "Force body yaw value") == -60 then
                plist.set(enemy, "Force body yaw value", 60)
            elseif plist.get(enemy, "Force body yaw value") == 60 then
                plist.set(enemy, "Force body yaw value", 0)
            end
        end
    end
end)

client.set_event_callback("run_command", function()
    if ui.get(resolver) == "Opposite" and not ui.get(resolver_override) then
        local enemies = entity.get_players(true)
        for i=1, #enemies do
            local enemy = enemies[i]
            local velocity = { entity.get_prop(enemy, "m_vecVelocity") }
            if 1 > math.abs(math.sqrt(velocity[1]^2+velocity[2]^2)) then
                plist.set(enemy, "Force body yaw", true)
                plist.set(enemy, "Force body yaw value", -math.min(60, math.max(-60, normalize(entity.get_prop(enemy, "m_angEyeAngles[1]")-entity.get_prop(enemy, "m_flLowerBodyYawTarget")))))
            else
                local body_yaw = math.floor(entity.get_prop(enemy, "m_flPoseParameter", 11) * 120 - 60)
                if body_yaw > 44 then
                    meme = 60
                elseif body_yaw < -44 then
                    meme = -60
                else
                    meme = body_yaw
                end
                plist.set(enemy, "Force body yaw value", math.min(60, math.max(-60, normalize(meme + entity.get_prop(enemy, "m_angEyeAngles[1]")-entity.get_prop(enemy, "m_flLowerBodyYawTarget")))))
            end
        end
    end
end)

client.set_event_callback("aim_miss", function(e)
    if ui.get(resolver) == "Bruteforce" and not ui.get(resolver_override) then
        if not e.reason == "?" then return end
        if missed[e.target] == nil then
            missed[e.target] = 1
        else
            missed[e.target] = missed[e.target] + 1
            plist.set(e.target, "Force body yaw", true)
        end
        if missed[e.target] == 1 then
            plist.set(e.target, "Force body yaw value", 60)
        elseif missed[e.target] == 2 then
            plist.set(e.target, "Force body yaw value", -60)
        elseif missed[e.target] == 3 then
            plist.set(e.target, "Force body yaw value", 0)
            missed[e.target] = 0
        end
        if contains(ui.get(logging), "Bruteforce") then
            client.color_log(236, 240, 241, "[\0") client.color_log(241, 196, 15, "absideon\0") client.color_log(236, 240, 241, "] \0")
            client.color_log(236, 240, 241, string.format("Shot missed %s due to bad resolve [r:%s | b:%s | s:%s]", entity.get_player_name(e.target), plist.get(e.target, "Force body yaw"), plist.get(e.target, "Force body yaw value"), missed[e.target]))
        end
    end
end)

--[[ 
AIMBOT STUFF
 ]]

local visible = false
local function on_visible()
    ui.set(menu.rage_autowall, ui.get(force_aw))
    if ui.get(dynAWALL) == "On visible" and not ui.get(force_aw) then
        for _, v in pairs(entity.get_players(true)) do
            local hitbox_position = {entity.hitbox_position(v, 0)}
            local eye_pos = {client.eye_position()}
            local fraction, v_hit = client.trace_line(entity.get_local_player(), eye_pos[1], eye_pos[2], eye_pos[3], hitbox_position[1], hitbox_position[2], hitbox_position[3])
            local insmoke = through_smoke(eye_pos[1], eye_pos[2], eye_pos[3], hitbox_position[1], hitbox_position[2], hitbox_position[3], 1)
            if (v_hit == v or fraction == 1) and not insmoke then
                visible = true
            else
                client.delay_call(ui.get(dynAWALL_time), function()
                    visible = false
                end)
            end
        end
        if visible == nil then return end
        ui.set(menu.rage_autowall, visible)
    elseif ui.get(dynAWALL) == "Always on" then
        ui.set(menu.rage_autowall, true)
    end
end
client.set_event_callback("run_command", on_visible)

local function dynfieldofview()
    local enemies = entity.get_players(true)
    for i=1, #enemies do
        local enemy = enemies[i]
        local epx, epy, epz = entity.get_prop(enemy, "m_vecOrigin")
        local lpx, lpy, lpz = entity.get_prop(entity.get_local_player(), "m_vecOrigin")
        local distance = GetDistanceInFeet(lpx, lpy, lpz, epx, epy, epz)
        if ui.get(dynFOV) == "Low" then
            ui.set(menu.rage_fov, math.min(ui.get(dynFOV_max), math.max(1, 3800 / distance * 7 * 0.01)))
        elseif ui.get(dynFOV) == "Medium" then
            ui.set(menu.rage_fov, math.min(45, math.max(1, 3800 / distance * 25 * 0.01)))
        elseif ui.get(dynFOV) == "High" then
            ui.set(menu.rage_fov, math.min(90, math.max(1, 3800 / distance * 55 * 0.01)))
        elseif ui.get(dynFOV) == "Maximum" then
            ui.set(menu.rage_fov, math.min(180, math.max(1, 3800 / distance * 85 * 0.01)))
        end
    end
end

client.set_event_callback("run_command", dynfieldofview)

client.set_event_callback("paint", function()
    local x,y = client.screen_size()
    for i = 1, #indicator do 
        cur_i = indicator[i]
        if cur_i.text == "DT" then cur_i.text = "Double Tap"
        elseif cur_i.text == "LC" then cur_i.text = "Lag Compensation"
        elseif cur_i.text == "DUCK" then cur_i.text = "Fake Duck"
        elseif cur_i.text == "FATAL" then cur_i.text = "LETHAL" end
        renderer.text(x/y+4, (y/x+655)+(i * 16)+2, 15, 15, 15, 255, "b", nil, string.format("%s", cur_i.text))
        renderer.text(x/y+3, (y/x+655)+(i * 16)+1, cur_i.r, cur_i.g, cur_i.b, 255, "b", nil, string.format("%s", cur_i.text))
        
    end
    indicator = {}
    if (hudChat ~= nil and hudChat.isChatOpen == true) then return end
    if contains(ui.get(indicators), "Antiaim") and ui.get(ui.reference("aa", "anti-aimbot angles", "enabled")) then
        renderer.indicator(255, 255, 255, 255, ui.get(menu.antiaim_lbyt))
    end
    if contains(ui.get(indicators), "Desync arrows") and ui.get(ui.reference("aa", "anti-aimbot angles", "enabled")) then
        local by = math.floor(entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60)
        local color = { 255-(math.abs(by)*2.29824561404), math.abs(by)*3.42105263158, math.abs(by)*0.22807017543 }
        if ui.get(indicator_size) == "Small" then
            renderer.text(x/2-25, y/2-3, 25, 25, 25, 25, "c+", nil, "◂")
            renderer.text(x/2+25, y/2-3, 25, 25, 25, 25, "c+", nil, "▸")
            if by >= 44 then
                renderer.text(x/2-25, y/2-3, color[1], color[2], color[3], 255, "c+", nil, "◂")
            elseif by <= -24 then
                renderer.text(x/2+25, y/2-3, color[1], color[2], color[3], 255, "c+", nil, "▸")
            end
        elseif ui.get(indicator_size) == "Large" then
            renderer.text(x/2-45, y/2-3, 25, 25, 25, 25, "c+", nil, "◀")
            renderer.text(x/2+45, y/2-3, 25, 25, 25, 25, "c+", nil, "▶")
            if by >= 44 then
                renderer.text(x/2-45, y/2-3, color[1], color[2], color[3], 255, "c+", nil, "◀")
            elseif by <= -24 then
                renderer.text(x/2+45, y/2-3, color[1], color[2], color[3], 255, "c+", nil, "▶")
            end
        end
    end
    if contains(ui.get(indicators), "Autowall") then
        renderer.indicator(255, 255, 255, 255, string.format("AW: %s", ui.get(menu.rage_autowall)))
    end
    if contains(ui.get(indicators), "Field of view") then
        renderer.indicator(255, 255, 255, 255, string.format("FOV: %s", ui.get(menu.rage_fov)))
    end
    if contains(ui.get(indicators), "Force body aim") then
        renderer.indicator(230, 126, 34, 255, string.format("FBaim: %s", ui.get(ui.reference("rage", "other", "force body aim"))))
    end
    if contains(ui.get(indicators), "Safe point") then
        renderer.indicator(241, 196, 15, 255, string.format("SP: %s", ui.get(ui.reference("rage", "aimbot", "force safe point"))))
    end
    if contains(ui.get(indicators), "Fake lag") then
        local fakelag_type
        if ui.get(menu.fakelag_limit) == 14 then fakelag_type = client.get_cvar("sv_maxusrcmdprocessticks")-2 else fakelag_type = ui.get(menu.fakelag_limit) end
        renderer.indicator(241, 196, 15, 255, string.format("FL: %s - %s", globals.chokedcommands(), fakelag_type))
    end
end)

local function shutdown()
    ui.set_visible(menu.fakelag_amount, true)
    ui.set_visible(menu.fakelag_varience, true)
    ui.set_visible(menu.fakelag_limit, true)

    ui.set_visible(fakelag_peek_time, false)
    ui.set_visible(fakelag_flags, false)
    ui.set_visible(legitaa_lbyt, false)
    ui.set_visible(legitaa_mode, false)
    ui.set_visible(legitaa_key, false)

    ui.set_visible(menu.antiaim_pitch, true)
    ui.set_visible(menu.antiaim_yawbase, true)
    ui.set_visible(menu.antiaim_byfreestanding, true)
    ui.set_visible(menu.antiaim_lbyt, true)
    ui.set_visible(menu.antiaim_fyl, true)
    ui.set_visible(menu.antiaim_edge, true)
    for i=1, #menu.antiaim_yaw do
        ui.set_visible(menu.antiaim_yaw[i], true)
    end
    for i=1, #menu.antiaim_jitter do
        ui.set_visible(menu.antiaim_jitter[i], true)
    end
    for i=1, #menu.antiaim_bodyyaw do
        ui.set_visible(menu.antiaim_bodyyaw[i], true)
    end
    for i=1, #menu.antiaim_freestanding do
        ui.set_visible(menu.antiaim_freestanding[i], true)
    end
end
client.set_event_callback("shutdown", shutdown)

local hitgroups = { "body", "head", "chest", "stomach", "left arm", "right arm", "left leg", "right leg", "neck", "?", "gear" }

client.set_event_callback("player_hurt", function(e)
    if contains(ui.get(logging), "Damage taken") then
        if client.userid_to_entindex(e.userid) == entity.get_local_player() then
            client.color_log(236, 240, 241, "[\0") client.color_log(241, 196, 15, "absideon\0") client.color_log(236, 240, 241, "] \0")
            client.color_log(236, 240, 241, string.format("%s damaged you in the %s for %s damage", entity.get_player_name(client.userid_to_entindex(e.attacker)), hitgroups[e.hitgroup + 1], e.dmg_health))
        end
    end
end)

client.set_event_callback("round_end", function(e)
    if not ui.get(easteregg) then return end
    if e.winner == entity.get_prop(entity.get_local_player(), "m_iTeamNum") then
        client.delay_call(0.1, function()
            client.exec("play music/survival_review_victory.wav")
        end)
    end
    if e.winner ~= entity.get_prop(entity.get_local_player(), "m_iTeamNum") then
        client.delay_call(0.1, function()
            client.exec("play survival/rocketalarmclose.wav")
        end)
    end
end)

client.set_event_callback("player_death", function(e)
    if ui.get(target_switch) then
        if client.userid_to_entindex(e.attacker) == entity.get_local_player() then
            local enemies = entity.get_players(true)
            for i=1, #enemies do
                local enemy = enemies[i]
                plist.set(enemy, "add to whitelist", true)
                client.delay_call(ui.get(target_switch_delay)/1000, function()
                    plist.set(enemy, "add to whitelist", false)
                end)
            end
        end
    end

    if not ui.get(easteregg) then return end
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
        client.delay_call(0.1, function()
            local random = client.random_int(1, 10)
            if random <= 2 then
                client.exec("play commander/train_failure_03.wav")
            else
                client.exec("play commander/commander_comment_"..client.random_int(17, 23)..".wav")
            end
        end)
    end
end)

client.set_event_callback("bomb_pickup", function(e)
    if not ui.get(easteregg) then return end
    if client.userid_to_entindex(e.userid) == entity.get_local_player() then
        client.delay_call(0.1, function()
            client.exec("play commander/gamecommander_20.wav")
        end)
    end
end)
