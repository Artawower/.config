# Ensure $EDITOR/$VISUAL default to helix if not set
if status is-interactive
    if not set -q EDITOR
        if command -q hx
            set -gx EDITOR hx
        else if command -q helix
            set -gx EDITOR helix
        end
    end
    if not set -q VISUAL
        set -gx VISUAL $EDITOR
    end
end

