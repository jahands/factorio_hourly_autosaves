local GUI = require("lib/gui")
local TICKS_PER_MINUTE = 60 * 60
local TICKS_PER_HOUR = TICKS_PER_MINUTE * 60
local close_gui_button_handler, debug_print, hourly_autosave, manual_save, message_gui, mod_init, mod_print, permissions_error_gui, prefix_reminder, save_gui, save_hotkey, save_shortcut, tagged_save_gui_handler, timestamped_save, tick_to_hours, tick_to_minutes, tick_to_save_name, tick_to_suffix, update_save_interval
local main

main = function()
  script.on_init(mod_init)
  script.on_nth_tick(settings.global["hourly_autosaves_interval"].value * TICKS_PER_MINUTE, hourly_autosave)
  script.on_event(defines.events.on_runtime_mod_setting_changed, update_save_interval)
  script.on_event(defines.events.on_lua_shortcut, save_shortcut)
  script.on_event("tagged_save_hotkey", save_hotkey)
  script.on_event(defines.events.on_player_joined_game, prefix_reminder)
  GUI.setup()
end

mod_init = function()
  if storage.autosave_interval == nil then
    storage.autosave_interval = settings.global["hourly_autosaves_interval"].value
  end
end

hourly_autosave = function(nth_tick_event)
  local tick = nth_tick_event.tick
  if tick == 0 then
    return
  end
  timestamped_save(tick)
end

timestamped_save = function(tick, suffix)
  local save_name = tick_to_save_name(tick)
  if suffix then
    save_name = save_name .. "-" .. tostring(suffix)
  end
  debug_print({
    "debug.saving_game",
    save_name
  })
  if not (game.is_multiplayer()) then
    game.auto_save(save_name)
  else
    game.server_save(save_name)
  end
end

update_save_interval = function(on_runtime_mod_setting_changed_event)
  if on_runtime_mod_setting_changed_event.setting ~= "hourly_autosaves_interval" then
    return
  end
  local new_interval = settings.global["hourly_autosaves_interval"].value
  local old_interval = storage.autosave_interval
  debug_print({
    "debug.update_save_interval",
    old_interval,
    new_interval
  })
  script.on_nth_tick(old_interval * TICKS_PER_MINUTE, nil)
  script.on_nth_tick(new_interval * TICKS_PER_MINUTE, hourly_autosave)
  storage.autosave_interval = new_interval
end

save_hotkey = function(tagged_save_hotkey_event)
  local player_index, tick
  player_index, tick = tagged_save_hotkey_event.player_index, tagged_save_hotkey_event.tick
  local player = game.players[player_index]
  return manual_save(player, tick)
end

save_shortcut = function(on_lua_shortcut_event)
  local player_index, prototype_name, tick
  player_index, prototype_name, tick = on_lua_shortcut_event.player_index, on_lua_shortcut_event.prototype_name,
      on_lua_shortcut_event.tick
  if not (prototype_name == "tagged_save") then
    return
  end
  local player = game.players[player_index]
  return manual_save(player, tick)
end

manual_save = function(player, tick)
  if player.admin then
    save_gui(player, tick)
  else
    permissions_error_gui(player, {
      "ha-gui.server_save_permission"
    })
  end
end

prefix_reminder = function(on_player_joined_game_event)
  local player_index
  player_index = on_player_joined_game_event.player_index
  local player = game.players[player_index]
  if not (player.admin and settings.global["hourly_autosaves_prefix"].value == "") then
    return
  end
  message_gui(player, {
    "ha-gui.set_autosaves_prefix",
    {
      "mod-setting-name.hourly_autosaves_prefix"
    }
  })
end

save_gui = function(player, tick)
  local frame = player.gui.screen.add({
    type = "frame",
    direction = "vertical",
    caption = {
      "ha-gui.save_dialog"
    }
  })
  frame.auto_center = true
  local text_frame = frame.add({
    type = "frame",
    style = "inside_deep_frame",
    direction = "horizontal"
  })
  text_frame.style.padding = 8
  local text_flow = text_frame.add({
    type = "flow",
    direction = "horizontal"
  })
  text_flow.style.vertical_align = "center"
  local label = text_flow.add({
    type = "label",
    caption = {
      "ha-gui.save_suffix_label",
      tostring(tick_to_save_name(tick)) .. "-"
    }
  })
  label.style.horizontally_stretchable = false
  label.style.horizontally_squashable = true
  local name_field = text_flow.add({
    type = "textfield"
  })
  local button_flow = frame.add({
    type = "flow"
  })
  button_flow.style.top_padding = 8
  button_flow.style.vertical_align = "center"
  local back_button = button_flow.add({
    type = "button",
    caption = {
      "ha-gui.back_button"
    },
    style = "back_button"
  })
  local pusher = button_flow.add({
    type = "empty-widget",
    style = "draggable_space"
  })
  pusher.style.horizontally_stretchable = true
  pusher.style.height = 32
  pusher.drag_target = frame
  local save_button = button_flow.add({
    type = "button",
    caption = {
      "ha-gui.save_button"
    },
    style = "confirm_button"
  })
  GUI.register_handler(back_button, close_gui_button_handler, frame)
  GUI.register_handler(save_button, tagged_save_gui_handler, defines.events.on_gui_click, frame, name_field)
  GUI.register_handler(name_field, tagged_save_gui_handler, defines.events.on_gui_confirmed, frame, name_field)
end

permissions_error_gui = function(player, action)
  local frame = player.gui.screen.add({
    type = "frame",
    direction = "vertical",
    caption = {
      "ha-gui.permissions_error_dialog"
    }
  })
  frame.auto_center = true
  frame.add({
    type = "label",
    caption = {
      "ha-gui.permissions_error_text",
      {
        "ha-gui.server_save_permission"
      }
    }
  })
  local button_flow = frame.add({
    type = "flow"
  })
  button_flow.style.top_padding = 8
  button_flow.style.vertical_align = "center"
  local back_button = button_flow.add({
    type = "button",
    caption = {
      "ha-gui.back_button"
    },
    style = "back_button"
  })
  local pusher = button_flow.add({
    type = "empty-widget",
    style = "draggable_space",
    right_margin = 0
  })
  pusher.style.horizontally_stretchable = true
  pusher.style.height = 32
  pusher.drag_target = frame
  GUI.register_handler(back_button, close_gui_button_handler, frame)
end

message_gui = function(player, message)
  local frame = player.gui.screen.add({
    type = "frame",
    direction = "vertical",
    caption = {
      "ha-gui.message_dialog"
    }
  })
  frame.auto_center = true
  frame.add({
    type = "label",
    caption = message
  })
  local button_flow = frame.add({
    type = "flow"
  })
  button_flow.style.top_padding = 8
  button_flow.style.vertical_align = "center"
  local pusher = button_flow.add({
    type = "empty-widget",
    style = "draggable_space",
    left_margin = 0
  })
  pusher.style.horizontally_stretchable = true
  pusher.style.height = 32
  pusher.drag_target = frame
  local ok_button = button_flow.add({
    type = "button",
    caption = {
      "ha-gui.ok_button"
    },
    style = "confirm_button"
  })
  GUI.register_handler(ok_button, close_gui_button_handler, frame)
end

close_gui_button_handler = function(event, gui_frame)
  if not (event.name == defines.events.on_gui_click) then
    return
  end
  GUI.deregister_handlers(gui_frame)
  return gui_frame.destroy()
end

tagged_save_gui_handler = function(event, event_filter, gui_frame, save_name_field)
  if not (event.name == event_filter) then
    return
  end
  timestamped_save(event.tick, save_name_field.text)
  GUI.deregister_handlers(gui_frame)
  return gui_frame.destroy()
end

debug_print = function(msg)
  if settings.global["hourly_autosaves_debug"].value then
    mod_print(msg)
  end
end

mod_print = function(msg)
  game.print({
    "",
    {
      "messages.hourly_autosaves_name"
    },
    ": ",
    msg
  })
end

tick_to_save_name = function(tick)
  local prefix = settings.global["hourly_autosaves_prefix"].value
  return tostring(prefix) .. "-" .. tostring(tick_to_suffix(tick))
end

tick_to_suffix = function(tick)
  return string.format("%05dh%02dm", tick_to_hours(tick), tick_to_minutes((tick % TICKS_PER_HOUR)))
end

tick_to_hours = function(tick)
  return math.floor(tick / TICKS_PER_HOUR)
end

tick_to_minutes = function(tick)
  return math.floor(tick / TICKS_PER_MINUTE)
end
main()
