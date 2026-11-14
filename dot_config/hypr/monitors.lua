-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

-- Monitor scale is Hyprland's scale for the output. It sizes everything
-- Wayland-native, accepts fractions (1.6, 1.75), and applies immediately.
-- "auto" lets Hyprland pick per display.
local omarchy_monitor_scale = "1.2"

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Laptop display (center)
hl.monitor({ output = "desc:AU Optronics 0xDE8E", disabled = false, mode = "preferred", position = "0x0", scale = omarchy_monitor_scale })

-- Left monitor (portrait, rotated 90°; transform: 1 = 90°, 3 = 270°)
hl.monitor({ output = "desc:BOE Display 000000001", mode = "preferred", position = "auto-left", scale = omarchy_monitor_scale, transform = 1 })

-- Right monitor (LG portable display)
hl.monitor({ output = "desc:LG Electronics 16MQ70 302NZAU063480", mode = "preferred", position = "auto-right", scale = omarchy_monitor_scale })

-- GDK scale is GDK_SCALE, the factor GTK draws its own UI at. It's what
-- sizes X11/XWayland windows, which Omarchy leaves unscaled so they stay
-- crisp instead of being stretched by the compositor. GTK only honors whole
-- numbers, so use the nearest integer to the monitor scale, and restart an
-- app for a change to reach it.
local omarchy_gdk_scale = 2
hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
