local GUI, gui_handlers
gui_handlers = {}
GUI = {

  register_handler = function(element, handler, ...)
    local player_gui_handlers = gui_handlers[element.player_index]
    if not (player_gui_handlers) then
      player_gui_handlers = {}
      gui_handlers[element.player_index] = player_gui_handlers
    end
    local params = {
      ...
    }
    player_gui_handlers[element.index] = {
      handler,
      params
    }
  end,

  deregister_handlers = function(element)
    local player_gui_handlers = gui_handlers[element.player_index]
    if not (player_gui_handlers) then
      return
    end
    player_gui_handlers[element.index] = nil
    for _, child_element in pairs(element.children) do
      GUI.deregister_handlers(child_element)
    end
  end,

  on_gui_event = function(event)
    local element
    element = event.element
    if not ((element and element.valid)) then
      return
    end
    local player_gui_handlers = gui_handlers[element.player_index]
    if not (player_gui_handlers) then
      return
    end
    local registration = player_gui_handlers[element.index]
    if registration then
      local handler, params
      handler, params = registration[1], registration[2]
      return handler(event, table.unpack(params))
    end
  end,

  setup = function()
    script.on_event(defines.events.on_gui_checked_state_changed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_click, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_closed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_confirmed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_elem_changed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_location_changed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_opened, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_selected_tab_changed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_selection_state_changed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_switch_state_changed, GUI.on_gui_event)
    script.on_event(defines.events.on_gui_text_changed, GUI.on_gui_event)
    return script.on_event(defines.events.on_gui_value_changed, GUI.on_gui_event)
  end
}
return GUI
