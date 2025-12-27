from prompt_toolkit.keys import Keys
from prompt_toolkit.filters import Condition
import re

@events.on_ptk_create
def custom_keybindings(bindings, **kw):
    @bindings.add(Keys.ControlK)
    def history_backward_prefix(event):
        event.current_buffer.history_backward(count=1)

    @bindings.add(Keys.ControlJ)
    def history_forward_prefix(event):
        event.current_buffer.history_forward(count=1)
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
    
    @bindings.add(Keys.ControlW)
    def _(event):
        """Delete word back including separator (space, /, ., -, _, :, etc.)"""
        buffer = event.current_buffer
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
