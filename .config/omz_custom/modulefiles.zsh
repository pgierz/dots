case $(hostname) in
  *bkli04m034* | 134-1-32-35.awi.de | vpn-*.awi.de )
    # Allow modulefiles on MacBook
    source /usr/local/opt/modules/init/zsh
    ;;
  Pauls-MacBook-Air.local)
    source /opt/homebrew/opt/modules/init/zsh
    ;;
  *)
    echo "No modulefile setup for $(hostname)"
    ;;
esac
