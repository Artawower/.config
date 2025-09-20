function remote-amnezia --wraps='ssh -i ~/.ssh/wgvpn debian@146.59.44.175' --description 'alias remote-amnezia=ssh -i ~/.ssh/wgvpn debian@146.59.44.175'
  ssh -i ~/.ssh/wgvpn debian@146.59.44.175 $argv
        
end
