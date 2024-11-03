if storage.gui_frames == nil then
  storage.gui_frames = {}
end

if storage.save_gui_open == nil then
  ---player_index -> is_open
  ---@type table<uint, boolean>
  storage.save_gui_open = {}
end
