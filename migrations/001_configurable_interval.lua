if storage.autosave_interval == nil then
  storage.autosave_interval = settings.global["hourly_autosaves_interval"].value
end
