-- /* ---- KooLit Hyprland Configuration (Lua) ---- */
-- Single-file config. https://wiki.hypr.land/Configuring/Start/

local home       = os.getenv("HOME")
local scriptsDir = home .. "/.config/hypr/scripts"
local UserScripts= home .. "/.config/hypr/UserScripts"
local mainMod    = "SUPER"
local term       = "kitty"
local files      = "thunar"

-- ─── monitors ─────────────────────────────────────────────
hl.monitor({ output = "", mode = "highrr", position = "auto", scale = 1 })

-- ─── environment variables ────────────────────────────────
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QUICK_CONTROLS_STYLE", "org.hyprland.style")
hl.env("GDK_SCALE", "1")
hl.env("QT_SCALE_FACTOR", "1")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("GSK_RENDERER", "ngl")
hl.env("EDITOR", "nvim")

-- ─── autostart ────────────────────────────────────────────
-- Phase 1: environment setup — MUST complete before apps launch.
-- Using os.execute (blocking) so dbus/systemd are ready first.
os.execute("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland 2>/dev/null")
os.execute("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_SESSION_DESKTOP 2>/dev/null")
os.execute("systemctl --user start graphical-session-bind.service 2>/dev/null")

-- Patch wlogout: use pkill instead of hyprctl dispatch (bypasses broken IPC)
os.execute("sed -i 's|hyprctl dispatch exit 0|pkill -TERM -x Hyprland|; s|loginctl terminate-session|pkill -TERM -x Hyprland|' " .. home .. "/.config/wlogout/layout 2>/dev/null")

-- ═══════════════════════════════════════════════════════════
--  WAYBAR WORKSPACE CLICKING — IMPORTANT NOTE
-- ═══════════════════════════════════════════════════════════
-- Waybar v0.15.0's hyprland/workspaces module sends old-style
-- dispatcher strings ("dispatch workspace N") over IPC.
-- With Lua config, hyprctl dispatch parses arguments as Lua,
-- so "workspace 2" becomes "hl.dispatch(workspace 2)" which
-- is a syntax error.
--
-- This CANNOT be fixed from this Lua file. You have 3 options:
-- 1. Use waybar-git (has the fix merged)
-- 2. Switch Waybar config to use "wlr/workspaces" instead of
--    "hyprland/workspaces" (uses Wayland protocol, not hyprctl)
-- 3. Build Waybar from source with the Lua-dispatch patch
--
-- The old timer+file-polling workaround has been removed
-- because hyprland/workspaces handles clicks internally in
-- C++ and ignores any "on-click" config on workspace buttons.
-- ═══════════════════════════════════════════════════════════

-- Phase 2: apps — launched immediately (dbus/systemd already done via os.execute above)
hl.on("hyprland.start", function()
    hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/KeybindsLayoutInit.sh"))
    hl.dispatch(hl.dsp.exec_cmd("awww-daemon --format xrgb"))
    hl.dispatch(hl.dsp.exec_cmd("awww img ~/.config/hypr/wallpaper_effects/.wallpaper_current"))
    hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/Polkit.sh"))
    hl.dispatch(hl.dsp.exec_cmd("kwalletd6"))
    hl.dispatch(hl.dsp.exec_cmd("blueman-applet"))
    hl.dispatch(hl.dsp.exec_cmd("nm-applet --indicator"))
    hl.dispatch(hl.dsp.exec_cmd("swaync"))
    hl.dispatch(hl.dsp.exec_cmd("waybar"))
    hl.dispatch(hl.dsp.exec_cmd("qs"))
    hl.dispatch(hl.dsp.exec_cmd("wl-paste --type text --watch cliphist store"))
    hl.dispatch(hl.dsp.exec_cmd("wl-paste --type image --watch cliphist store"))
    hl.dispatch(hl.dsp.exec_cmd(UserScripts .. "/RainbowBorders.sh"))
    hl.dispatch(hl.dsp.exec_cmd("hypridle"))
    hl.dispatch(hl.dsp.exec_cmd(scriptsDir .. "/Hyprsunset.sh init"))
end)

-- ─── settings ─────────────────────────────────────────────
hl.config({
    general = {
        gaps_in = 2, gaps_out = 4, border_size = 2,
        resize_on_border = true, layout = "dwindle",
        col = { active_border = "rgb(8D7272)", inactive_border = "rgb(231D1F)" },
    },
    decoration = {
        rounding = 2, active_opacity = 1.0, inactive_opacity = 0.9,
        fullscreen_opacity = 1.0, dim_inactive = true, dim_strength = 0.1, dim_special = 0.8,
        shadow = { enabled = true, range = 3, render_power = 1, color = "rgb(8D7272)" },
        blur = { enabled = true, size = 6, passes = 2, ignore_opacity = true, new_optimizations = true, special = true, popups = true },
    },
    dwindle = { preserve_split = true, special_scale_factor = 0.8 },
    master = { new_status = "master", new_on_top = true, mfact = 0.5 },
    input = {
        kb_layout = "us", kb_variant = "", kb_model = "", kb_options = "", kb_rules = "",
        repeat_rate = 50, repeat_delay = 300, sensitivity = 0,
        numlock_by_default = true, left_handed = false, follow_mouse = 1,
        float_switch_override_focus = false,
        touchpad = { disable_while_typing = true, natural_scroll = true, clickfinger_behavior = false, middle_button_emulation = false, tap_to_click = true, drag_lock = false },
        touchdevice = { enabled = true },
        tablet = { transform = 0, left_handed = false },
    },
    gestures = {
        workspace_swipe_distance = 500, workspace_swipe_invert = true,
        workspace_swipe_min_speed_to_force = 30, workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = true, workspace_swipe_forever = true,
    },
    misc = {
        disable_hyprland_logo = true, disable_splash_rendering = true, vrr = 2,
        mouse_move_enables_dpms = true, enable_swallow = false, swallow_regex = "^(kitty)$",
        focus_on_activate = false, initial_workspace_tracking = 0,
        middle_click_paste = false, enable_anr_dialog = true, anr_missed_pings = 15,
    },
    binds = { workspace_back_and_forth = true, allow_workspace_cycles = true, pass_mouse_when_bound = false },
    xwayland = { enabled = true, force_zero_scaling = true },
    cursor = { sync_gsettings_theme = true, no_hardware_cursors = true, enable_hyprcursor = true, warp_on_change_workspace = 2, no_warps = true },
    debug = { disable_logs = false },
})

-- ─── animations ───────────────────────────────────────────
hl.config({ animations = { enabled = true } })
hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("linear",   { type = "bezier", points = { {0.0, 0.0}, {1.0, 1.0} } })
hl.curve("wind",     { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })
hl.curve("winOut",   { type = "bezier", points = { {0.3, -0.3}, {0, 1} } })
hl.curve("slow",     { type = "bezier", points = { {0, 0.85}, {0.3, 1} } })
hl.curve("overshot", { type = "bezier", points = { {0.7, 0.6}, {0.1, 1.1} } })
hl.curve("bounce",   { type = "bezier", points = { {1.1, 1.6}, {0.1, 0.85} } })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 5,   bezier = "slow",    style = "popin" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5,   bezier = "winOut",  style = "popin" })
hl.animation({ leaf = "windowsMove",enabled = true, speed = 5,   bezier = "wind",    style = "slide" })
hl.animation({ leaf = "border",     enabled = true, speed = 10,  bezier = "linear" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 90, bezier = "linear", style = "loop" })
hl.animation({ leaf = "fade",       enabled = true, speed = 5,   bezier = "overshot" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5,   bezier = "wind" })
hl.animation({ leaf = "windows",    enabled = true, speed = 5,   bezier = "bounce",  style = "popin" })

-- ─── window rules ─────────────────────────────────────────
hl.window_rule({ name = "email-ws",      workspace = "1",        match = { class = [[^([Tt]hunderbird|org\.gnome\.Evolution|eu\.betterbird\.Betterbird)$]] } })
hl.window_rule({ name = "browser-ws",    workspace = "2",        match = { class = [[^([Ff]irefox|org\.mozilla\.firefox|google-chrome(-beta|-dev|-unstable)?|chrome-.+-Default|[Cc]hromium|Brave-browser(-beta|-dev|-unstable)?|[Tt]horium-browser|zen)$]] } })
hl.window_rule({ name = "screenshare-ws",workspace = "4 silent", match = { class = [[^(com\.obsproject\.Studio)$]] } })
hl.window_rule({ name = "gamestore-ws",  workspace = "5",        match = { class = [[^([Ss]team|com\.heroicgameslauncher\.hgl)$]] } })
hl.window_rule({ name = "virtmgr-ws",    workspace = "6 silent", match = { class = [[^(virt-manager|org\.virt-manager\.virt-manager)$]] } })
hl.window_rule({ name = "im-ws",         workspace = "7",        match = { class = [[^([Dd]iscord|[Ww]ebCord|[Vv]esktop|[Ff]erdium|[Ww]hatsapp-for-linux|org\.telegram\.desktop|teams-for-linux|Element)$]] } })
hl.window_rule({ name = "games-ws",      workspace = "8",        match = { class = [[^(gamescope|steam_app_\d+)$]] } })
hl.window_rule({ name = "media-ws",      workspace = "9 silent", match = { class = [[^([Aa]udacious|[Mm]pv|vlc)$]] } })

-- Dropdown terminal window rule — spawns silently on special:dropdown
-- size/position mirror Dropterminal.sh: WIDTH_PERCENT=65, HEIGHT_PERCENT=65,
-- Y_PERCENT=10 (centered horizontally, sitting 10% down from the top —
-- NOT dead-center, which is what `center = true` used to give it).
hl.window_rule({ name = "dropdown-term", match = { class = "kitty-dropterm" }, float = true, size = "50% 50%", move = "(monitor_w-window_w)/2 monitor_h*0.10", workspace = "special:dropdown silent" })

-- ═══════════════════════════════════════════════════════════
--  FLOATING TERMINAL — uses native toggle_special dispatcher
--  No hyprctl/IPC needed, no deadlock.
--  Hyprland's togglespecialworkspace already shows/hides on
--  whichever monitor is currently focused, so (unlike
--  Dropterminal.sh) there's no need to manually detect the
--  focused monitor and reposition the window each time.
-- ═══════════════════════════════════════════════════════════

local function toggle_dropdown()
    local ok, wins = pcall(hl.get_windows, { class = "kitty-dropterm" })

    if not ok or not wins or #wins == 0 then
        local mon = hl.get_active_monitor()
            local w = math.floor(mon.width * 0.45 / mon.scale)
            local h = math.floor(mon.height * 0.45 / mon.scale)
            -- x: centered on screen
            local x = math.floor((mon.width / mon.scale - w) / 2)
            -- y: 5% from top (adjust 0.05 to taste: 0.02 = very high, 0.10 = lower)
            local y = math.floor(mon.height * 0.05 / mon.scale)
            hl.dispatch(hl.dsp.exec_cmd("kitty --class kitty-dropterm", {
                float = true,
                size  = w .. " " .. h,
                move  = x .. " " .. y,
            }))
        return
    end

    local win = wins[1]

    if win.workspace.name == "special:dropdown" then
        -- Pull dropdown onto the workspace we're currently using.
        local active = hl.get_active_workspace()

        hl.dispatch(hl.dsp.window.move({
            window = win,
            workspace = active.name,
            follow = true
        }))
    else
        -- Put it back into the special workspace.
        hl.dispatch(hl.dsp.window.move({
            window = win,
            workspace = "special:dropdown",
            follow = false
        }))
    end
end

-- ═══════════════════════════════════════════════════════════
--  KEYBINDS
-- ═══════════════════════════════════════════════════════════

-- System
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(scriptsDir .. "/KillActiveProcess.sh"))
hl.bind("CTRL + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/LockScreen.sh"))
hl.bind("CTRL + ALT + P", hl.dsp.exec_cmd(scriptsDir .. "/Wlogout.sh"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(scriptsDir .. "/Kool_Quick_Settings.sh"))

-- Master / Dwindle
hl.bind(mainMod .. " + CTRL + D", hl.dsp.layout("removemaster"))
hl.bind(mainMod .. " + I", hl.dsp.layout("addmaster"))
hl.bind(mainMod .. " + CTRL + Return", hl.dsp.layout("swapwithmaster"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + M", hl.dsp.layout("splitratio 0.3"))

-- Group
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + CTRL + tab", hl.dsp.group.next())

-- Apps
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("pkill rofi || true && rofi -show drun -modi drun,filebrowser,run,window"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd('xdg-open "https://"'))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(files))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd(scriptsDir .. "/KeyHints.sh"))

-- ─── floating terminal (Super+Shift+Return) ───────────────
hl.bind(mainMod .. " + SHIFT + Return", toggle_dropdown)

-- Fullscreen / Float
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SPACE", hl.dsp.window.float({ action = "toggle" }))

-- Features
hl.bind(mainMod .. " + ALT + R", hl.dsp.exec_cmd(scriptsDir .. "/Refresh.sh"))
hl.bind(mainMod .. " + ALT + E", hl.dsp.exec_cmd(scriptsDir .. "/RofiEmoji.sh"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd(scriptsDir .. "/RofiSearch.sh"))
hl.bind(mainMod .. " + ALT + O", hl.dsp.exec_cmd(scriptsDir .. "/ChangeBlur.sh"))
hl.bind(mainMod .. " + SHIFT + G", hl.dsp.exec_cmd(scriptsDir .. "/GameMode.sh"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd(scriptsDir .. "/ChangeLayout.sh"))
hl.bind(mainMod .. " + ALT + V", hl.dsp.exec_cmd(scriptsDir .. "/ClipManager.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperSelect.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(UserScripts .. "/WallpaperEffects.sh"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --swappy"))

-- Media keys
hl.bind("xf86audioraisevolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --inc"), { locked = true, repeating = true })
hl.bind("xf86audiolowervolume", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --dec"), { locked = true, repeating = true })
hl.bind("xf86AudioMicMute", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle-mic"), { locked = true })
hl.bind("xf86audiomute", hl.dsp.exec_cmd(scriptsDir .. "/Volume.sh --toggle"), { locked = true })
hl.bind("xf86AudioPause", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true })
hl.bind("xf86AudioPlay", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --pause"), { locked = true })
hl.bind("xf86AudioNext", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --nxt"), { locked = true })
hl.bind("xf86AudioPrev", hl.dsp.exec_cmd(scriptsDir .. "/MediaCtrl.sh --prv"), { locked = true })

-- Screenshots
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --now"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd(scriptsDir .. "/ScreenShot.sh --area"))

-- Resize (converted from old resizeactive dispatcher)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50,  y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0, y = 50,  relative = true }), { repeating = true })

-- Move windows (converted from old movewindow dispatcher)
hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.move({ direction = "d" }))

-- Swap windows (converted from old swapwindow dispatcher)
hl.bind(mainMod .. " + ALT + left",  hl.dsp.window.swap({ direction = "l" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.swap({ direction = "r" }))
hl.bind(mainMod .. " + ALT + up",    hl.dsp.window.swap({ direction = "u" }))
hl.bind(mainMod .. " + ALT + down",  hl.dsp.window.swap({ direction = "d" }))

-- Move focus
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspace navigation
hl.bind(mainMod .. " + tab",       hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mainMod .. " + SHIFT + tab", hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Special workspace
hl.bind(mainMod .. " + SHIFT + U", hl.dsp.window.move({ workspace = "special" }))
hl.bind(mainMod .. " + U", hl.dsp.workspace.toggle_special())

-- Switch + move to workspaces [0-9]
for i = 1, 10 do
    local key = tostring(i % 10)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i) }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = tostring(i) }))
    -- Silent move: move window to target, ALWAYS switch back to current workspace
    local target = tostring(i)
    hl.bind(mainMod .. " + CTRL + " .. key, function()
        local aws = hl.get_active_workspace()
        local ws_id = aws and tostring(aws.id) or "1"
        hl.dispatch(hl.dsp.window.move({ workspace = target }))
        hl.dispatch(hl.dsp.focus({ workspace = ws_id }))
    end)
end

-- Mouse move/resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Keyboard layout switching (non_consuming so keys still reach apps like Zed)
hl.bind("ALT_L + SHIFT_L", hl.dsp.exec_cmd(scriptsDir .. "/SwitchKeyboardLayout.sh"), { locked = true, non_consuming = true })
hl.bind("SHIFT_L + ALT_L", hl.dsp.exec_cmd(scriptsDir .. "/Tak0-Per-Window-Switch.sh"), { locked = true, non_consuming = true })
