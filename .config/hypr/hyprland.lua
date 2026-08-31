-------------------------
--- UTILITY FUNCTIONS ---
-------------------------
local defaultScaleFac = 1.25
local edp1 = { res = "1920x1080@60", scale = defaultScaleFac } -- initial resolution and scale

-- UI looks blurry in some electron applications.
-- this function can be called to switch resolution and scale in those situations.
local toggle_edp1_resolution = function()
    hl.monitor({
        output    = "eDP-1",
        mode      = edp1.res,
        position  = "0x0",
        scale     = edp1.scale,
        transform = 0,
    })

    local full = "1920x1080@60"
    local scaled = "1600x900@60"

    if edp1.res == full then
        edp1.res = scaled
        edp1.scale = 1.0
    else
        edp1.res = full
        edp1.scale = defaultScaleFac
    end
end

---@param path string path to directory containing wallpapers
---@return string file name of randomly selected wallpaper from specified directory
local function getrandom_wallp(path)
    path = path:gsub("~", tostring(os.getenv("HOME")))
    local handle = io.popen("ls " .. path .." | grep -E '\\.(png|jpg|webp|gif)$'")
    if not handle then
        hl.notification.create({ text = "ERROR: wallpaper directory - " .. path .. "  was not found.", timeout = 3000 })
        return ""
    end

    local files = {}
    for file in handle:lines() do
        table.insert(files, file)
    end
    handle:close()

    if #files <= 0 then
        hl.notification.create({ text = "ERROR: wallpaper list appear empty. ", timeout = 3000 })
        return ""
    end

    local RANDOM_WALLP = math.random(1, #files)
    return path .. "/" .. files[RANDOM_WALLP]
end

---handles zooming in and out
---@param fac number multiplicative factor to zoom
local function zoom(fac)
    local MAX_ZOOM = 3
    local MIN_ZOOM = 1
    local ZOOM_TOGGLE_FACTOR = 1.5
    local current = hl.get_config("cursor.zoom_factor")
    if fac ~= nil then
        current = current + fac
    elseif current ~= MIN_ZOOM then
        current = MIN_ZOOM
    else
        current = ZOOM_TOGGLE_FACTOR
    end
    current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
    hl.config({ cursor = { zoom_factor = current } })
end


--[======================================================[
    __  ____  ______  ____  _      ___    __  __ ___
   / / / / / / / __ \/ __ \/ |    /   |  / | / / __ \ 
  / /_/ / /_/ / /_/ / /_/ /  |   / /| | /  |/ / / / /
 / __  /\__, / ____/ _, _/ /| | / ___ |/ /|  / /_/ /   
/_/ /_/____/_/    /_/ |_/_/ |_/_/  |_/_/ |_/_____/    
                                                      
]======================================================]

------------------
---- MONITORS ----
------------------
toggle_edp1_resolution()
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
    mirror   = "eDP-1"
})

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("sleep 1 && awww img " .. getrandom_wallp("~/Pictures/walls"))
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("swayidle")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("wl-paste --watch cliphist store")
    hl.exec_cmd("ashell")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("HYPRCURSOR_SIZE", 24)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        border_size = 1,
        gaps_in     = 0,
        gaps_out    = 0,
        col = {
            active_border   = "rgb(808080)",
            inactive_border = "rgba(00000000)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding         = 8,
        active_opacity   = 1.0,
        inactive_opacity = 0.92,
        -- screen_shader = "crt.frag",
        shadow = { enabled = false },
        blur = { enabled = false, size = 8, passes = 2},
    },

    animations = { enabled = true },

    input = {
        kb_layout     = "us",
        follow_mouse  = 1,
        repeat_delay  = 222,
        repeat_rate   = 35,
        sensitivity   = -0.45,
        accel_profile = "flat",
        scroll_factor = 0.85,
        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
        },
        tablet = {
            output = "current", -- can be eDP-1 (specific monitor)
        },
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        animate_manual_resizes  = true,
        font_family = "Adwaita Sans",
    },

    dwindle = { preserve_split = true, },

    master = { new_status = "master", },

    scrolling = {
        fullscreen_on_one_column = true,
        column_width = 0.56,
        wrap_focus = false,
    },

    ecosystem = {
        enforce_permissions = true,
        no_donation_nag     = true,
    },
})


---------------
---- INPUT ----
---------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "resize" })
hl.gesture({ fingers = 4, direction = "vertical",   action = "resize" })

hl.device({
    name = "elan2304:00-04f3:3122-touchpad",
    sensitivity = 0.6,
})


---------------------
---- KEYBINDINGS ----
---------------------
-- SPAWNERS
hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + B", hl.dsp.exec_cmd("zen"))
hl.bind("F2", hl.dsp.exec_cmd("ashell msg toggle-visibility"), { long_press = true})
hl.bind("SUPER + C", hl.dsp.exec_cmd("pkill -x fuzzel || cliphist list | fuzzel  -w 48 --dmenu --mesg='Clipboard history' | cliphist decode | wl-copy"))
hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd('pkill fuzzel || fuzzel --placeholder=" Launch using integrated graphics"'))
hl.bind("SUPER + D", hl.dsp.exec_cmd('pkill fuzzel || fuzzel --launch-prefix="nvidia-offload" --placeholder=" Launch using discrete graphics"'))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("hyprpicker | wl-copy"))
hl.bind("SUPER + PERIOD", hl.dsp.exec_cmd("pkill fuzzel || ~/.config/hypr/emoji-picker.sh"))
-- screenshot
hl.bind("PRINT", hl.dsp.exec_raw("~/.config/hypr/shot"))
-- screen recording
hl.bind("PRINT", hl.dsp.exec_raw("~/.config/hypr/cast"), { long_press = true })
hl.bind("SUPER + F10", hl.dsp.exec_raw("~/.config/hypr/cast stop"))
hl.bind("XF86Search", hl.dsp.exec_raw("~/.config/hypr/search-word.sh"))
hl.bind("XF86Calculator", hl.dsp.exec_cmd("gnome-calculator"))
hl.bind("XF86HomePage", hl.dsp.exec_cmd("nautilus"))
hl.bind("XF86Tools", hl.dsp.exec_cmd("xdg-open https://music.youtube.com"))
hl.bind("XF86Mail", hl.dsp.exec_cmd("xdg-open https://mail.google.com"))

-- WINDOW CONTROLS
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SHIFT + V", function()
    hl.dispatch(hl.dsp.window.float())
    hl.dispatch(hl.dsp.window.pin())
end)
hl.bind("SUPER + F", hl.dsp.window.fullscreen())
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + L",   hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + H",   hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + K",   hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J",   hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + mouse_up",    hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + mouse_down",  hl.dsp.focus({ direction = "left", }))
hl.bind("SUPER + TAB",         hl.dsp.focus({ direction = "right" }), { repeating = true })
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ direction = "left" }),  { repeating = true })

-- MONITOR
hl.bind("SUPER + right", hl.dsp.focus({monitor = "r"}))
hl.bind("SUPER + left", hl.dsp.focus({monitor = "l"}))
hl.bind("SUPER + RETURN", function()
    hl.notification.create({text = "Current resolution: "..edp1.res.."::"..edp1.scale, timeout = 3000})
    hl.dispatch(toggle_edp1_resolution)
end)

-- WORKSPACES
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i}))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind("SUPER + GRAVE", hl.dsp.workspace.toggle_special("Ref"))
hl.bind("SUPER + SHIFT + GRAVE", hl.dsp.window.move({ workspace = "special:Ref" }))
hl.bind("SUPER + TAB", function()
    local current_layout = hl.get_active_workspace().tiled_layout
    local id = hl.get_active_workspace().id
    local new_layout = current_layout == "dwindle" and "scrolling" or "dwindle"

    hl.workspace_rule({workspace = tostring(id), layout = new_layout})
    hl.notification.create({ text = "Current layout: " .. new_layout, timeout = 2000})
end)
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- MULTIMEDIA KEYS
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("ashell msg volume-up"),{ locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("ashell msg volume-down"),       { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 3%+"),                   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 3%-"),                   { locked = true, repeating = true })
hl.bind("SUPER + BRACKETRIGHT",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 3%+"),                   { locked = true, repeating = true })
hl.bind("SUPER + BRACKETLEFT",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 3%-"),                   { locked = true, repeating = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),                                  { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"),                            { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),                              { locked = true })

-- RESIZE MODE --
hl.bind("SUPER + R", function()
    hl.notification.create({text = 'Entered Resize Mode. Use H-J-K-L to resize, ESC to leave', timeout = 2500})
    hl.dispatch(hl.dsp.submap("resize"))
end)

hl.define_submap("resize", function()
    hl.bind("L", hl.dsp.window.resize({ x = 25 , y = 0  , relative = true}), { repeating = true })
    hl.bind("H", hl.dsp.window.resize({ x = -25, y = 0  , relative = true}), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0  , y = 25 , relative = true}), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0  , y = -25, relative = true}), { repeating = true })

    hl.bind("ESCAPE", function()
        hl.notification.create({text = 'Left resize mode.', timeout = 2500})
        hl.dispatch(hl.dsp.submap("reset"))
    end)
end)

-- NUMB HYPRLAND KEYBINDS --
hl.bind("ALT + SPACE", function()
    hl.notification.create({text = "Entered NUMB mode. press SUPER + ALT + SPACE to release", timeout = 2000})
    hl.dispatch(hl.dsp.submap("numb"))
end)

hl.define_submap("numb", function()
    hl.bind("SUPER + ALT + SPACE", function()
        hl.notification.create({text = "NUMB mode disabled.", timeout = 2000})
        hl.dispatch(hl.dsp.submap("reset"))
    end)
end)

-- GENERAL --
hl.bind("SUPER + SHIFT + Q", hl.dsp.exit())
hl.bind("ALT + L", hl.dsp.exec_cmd("hyprlock"))

hl.bind("SUPER + Z", function() zoom(0.5) end,  { repeating = true })
hl.bind("SUPER + X", function() zoom(-0.5) end, { repeating = true })

-- GLOBAL BINDINGS --
-- hl.bind("SUPER + F10", hl.dsp.pass({ window = "class:^(com\\.obsproject\\.Studio)$" }))


--------------------------------------
---- WINDOWS AND WORKSPACES RULES ----
--------------------------------------
hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})


hl.window_rule({ match = { title = "Calculator" }, float = true })
hl.layer_rule({ match = { namespace = "launcher" }, dim_around = true, no_anim = true, })

hl.workspace_rule({workspace = "1", layout = "scrolling"})
-- smart gaps
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "w[tv1]s[false]" }, rounding = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, border_size = 0 })
hl.window_rule({ match = { float = false, workspace = "f[1]s[false]" }, rounding = 0 })

-----------------------
----- PERMISSIONS -----
-----------------------
hl.permission({ binary = "^/nix/store/[a-z0-9]{32}-xdg-desktop-portal-hyprland-[0-9.]+.*/libexec/xdg-desktop-portal-hyprland$", type = "screencopy", mode = "allow" })
hl.permission({ binary = "^/nix/store/[a-z0-9]{32}-grim-[0-9.]+.*/bin/grim$",                                                   type = "screencopy", mode = "allow" })
hl.permission({ binary = "^/nix/store/[a-z0-9]{32}-hyprpicker-[0-9.]+.*/bin/hyprpicker$",                                       type = "screencopy", mode = "allow" })
hl.permission({ binary = "^/nix/store/[a-z0-9]{32}-hyprlock-[0-9.]+.*/bin/hyprlock$",                                           type = "screencopy", mode = "allow" })

----------------
-- ANIMATIONS --
----------------
local SPEED_FAC = 0.8
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("snappySpring",   { type = "spring", mass = 1, stiffness = 1000, dampening = 46 })

hl.animation({ leaf = "global",        enabled = true,  speed = 3.0 * SPEED_FAC,    bezier = "quick" })

hl.animation({ leaf = "windows",       enabled = true,  speed = 3.5 * SPEED_FAC,  spring = "snappySpring" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 3.0 * SPEED_FAC,  spring = "snappySpring",  style = "popin 93%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 2.0 * SPEED_FAC,  bezier = "quick",         style = "popin 93%" })

hl.animation({ leaf = "fade",          enabled = true,  speed = 2.0 * SPEED_FAC,  bezier = "quick" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.5 * SPEED_FAC,  bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.5 * SPEED_FAC,  bezier = "almostLinear" })

hl.animation({ leaf = "layers",        enabled = true,  speed = 3.0 * SPEED_FAC,  bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 2.5 * SPEED_FAC,  bezier = "easeOutQuint",  style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5 * SPEED_FAC,  bezier = "quick",         style = "fade" })

hl.animation({ leaf = "workspaces",    enabled = true,  speed = 3.0 * SPEED_FAC,  bezier = "easeOutQuint",  style = "slidevert" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 2.5 * SPEED_FAC,  bezier = "easeOutQuint",  style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 2.5 * SPEED_FAC,  bezier = "easeOutQuint",  style = "slide" })

hl.animation({ leaf = "border",        enabled = true,  speed = 3.0 * SPEED_FAC,  bezier = "quick" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 4.0 * SPEED_FAC,  bezier = "quick" })
