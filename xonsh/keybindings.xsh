from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import Condition, vi_insert_mode, vi_mode
from prompt_toolkit.key_binding.vi_state import InputMode
import re

# Define filter for NOT in insert mode (i.e., navigation mode)
@Condition
def not_in_insert_mode():
    return not vi_insert_mode()

# Also define filter for vi normal mode (command mode)
@Condition
def in_vi_navigation_mode():
    return vi_mode() and not vi_insert_mode()

@events.on_ptk_create
def custom_keybindings(bindings, **kw):
    # h = left - only in navigation mode (not insert)
    @bindings.add('h', filter=in_vi_navigation_mode, eager=True)
    def vi_h_left(event):
        buffer = event.current_buffer
        buffer.cursor_position = max(0, buffer.cursor_position - 1)
    
    # n = down (was j in QWERTY) - only in navigation mode
    @bindings.add('n', filter=in_vi_navigation_mode, eager=True)
    def vi_n_down(event):
        event.current_buffer.history_forward(count=1)
    
    # e = up (was k in QWERTY) - only in navigation mode
    @bindings.add('e', filter=in_vi_navigation_mode, eager=True)
    def vi_e_up(event):
        event.current_buffer.history_backward(count=1)
    
    # i = right - only in navigation mode (Colemak)
    @bindings.add('i', filter=in_vi_navigation_mode, eager=True)
    def vi_i_right(event):
        buffer = event.current_buffer
        buffer.cursor_position = min(len(buffer.text), buffer.cursor_position + 1)
    
    # l = enter insert mode (Colemak: l is where 'i' is in QWERTY)
    @bindings.add('l', filter=in_vi_navigation_mode, eager=True)
    def vi_l_insert(event):
        event.app.vi_state.input_mode = InputMode.INSERT
    
    # Colemak: Ctrl+E = history backward (was Ctrl+K in QWERTY)
    @bindings.add(Keys.ControlE)
    def history_backward_prefix(event):
        event.current_buffer.history_backward(count=1)

    # Colemak: Ctrl+N = history forward (was Ctrl+J in QWERTY)
    @bindings.add(Keys.ControlN)
    def history_forward_prefix(event):
        event.current_buffer.history_forward(count=1)
    
    @bindings.add(Keys.ControlA)
    def _(event):
        event.current_buffer.cursor_position = 0
    
    # Ctrl+U = clear line (delete from cursor to beginning) - works in both modes
    @bindings.add(Keys.ControlU)
    def _(event):
        buffer = event.current_buffer
        buffer.delete_before_cursor(count=buffer.cursor_position)
    
    @bindings.add(Keys.ControlB)
    def _(event):
        buffer = event.current_buffer
        buffer.cursor_position = buffer.document.find_previous_word_beginning() or 0
    
    @bindings.add(Keys.ControlW)
    def _(event):
        """Delete word back including separator (space, /, ., -, _, :, etc.)"""
        buffer = event.current_buffer
        # Cancel any active completion so delete_before_cursor
        # doesn't swallow the entire completion block.
        if buffer.complete_state:
            buffer.cancel_completion()
        text = buffer.document.text_before_cursor
        
        if not text:
            return
        
        # Separators: space, /, ., -, _, :, ;, ,, @, =, |
        separators_pattern = r'[\s/.\-_:;,@=|]'
        
        # Strip trailing separators to find the word boundary
        text_stripped = re.sub(f'{separators_pattern}+$', '', text)
        
        if not text_stripped:
            # Only separators left, delete all
            buffer.delete_before_cursor(count=len(text))
            return
        
        # Find last separator before the word
        match = None
        for m in re.finditer(separators_pattern, text_stripped):
            match = m
        
        if match:
            # Delete from last separator (inclusive) to cursor
            delete_count = len(text) - match.end()
        else:
            # No separator found, delete entire text
            delete_count = len(text)
        
        if delete_count > 0:
            buffer.delete_before_cursor(count=delete_count)
    
    @bindings.add(Keys.Escape, Keys.Delete)
    def _(event):
        """Delete word back (standard Ctrl+W: delete to whitespace)"""
        buffer = event.current_buffer
        pos = buffer.cursor_position
        text = buffer.text[:pos]
        
        if not text:
            return
        
        # Skip trailing whitespace
        i = len(text) - 1
        while i >= 0 and text[i] in ' \t':
            i -= 1
        
        # Delete word characters
        while i >= 0 and text[i] not in ' \t':
            i -= 1
        
        delete_count = len(text) - i - 1
        if delete_count > 0:
            buffer.delete_before_cursor(count=delete_count)
