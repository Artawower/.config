function dublog --wraps='ssh darkawower@49.12.98.254' --wraps='ssh -i ~/.ssh/dublog darkawower@49.12.98.254' --description 'alias dublog=ssh -i ~/.ssh/dublog darkawower@49.12.98.254'
  ssh -i ~/.ssh/dublog darkawower@49.12.98.254 $argv
        
end
