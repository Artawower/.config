from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import vi_insert_mode, vi_navigation_mode

@events.on_ptk_create
def custom_keybindings(bindings, **kw):
    @bindings.add(Keys.ControlA)
    def _(event):
        event.current_buffer.cursor_position = 0
    
    @bindings.add(Keys.ControlE)
    def _(event):
        event.current_buffer.cursor_position = len(event.current_buffer.text)
    
    @bindings.add(Keys.ControlB)
    def _(event):
        buffer = event.current_buffer
        buffer.cursor_position = buffer.document.find_previous_word_beginning() or 0
