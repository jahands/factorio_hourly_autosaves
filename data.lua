return data:extend({
  {
    type = "shortcut",
    name = "tagged_save",
    action = "lua",
    icon = "__hourly_autosaves_2__/graphics/icons/shortcut-toolbar/mip/tagged_save-x32.png",
    icon_size = 32,
    small_icon = '__hourly_autosaves_2__/graphics/icons/shortcut-toolbar/mip/tagged_save-x16.png',
    small_icon_size = 16,
    scale = 0.5,
    mipmap_count = 2,
    flags = {
      "gui-icon"
    },
    toggleable = false,
    associated_control_input = "tagged_save_hotkey"
  },
  {
    type = "custom-input",
    name = "tagged_save_hotkey",
    key_sequence = "SHIFT + F5"
  }
})
