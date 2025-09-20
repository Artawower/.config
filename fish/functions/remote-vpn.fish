function remote-vpn --wraps="ssh -i ./wgvpn 'darkawower@146.59.44.175'" --description "alias remote-vpn=ssh -i ./wgvpn 'darkawower@146.59.44.175'"
  ssh -i ./wgvpn 'darkawower@146.59.44.175' $argv
        
end
