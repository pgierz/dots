case $(hostname) in
  *bkli04m034* )
    # Allow modulefiles on MacBook
    source /usr/local/opt/modules/init/zsh
    ;;
  *)
    echo "No modulefile setup for $(hostname)"
    ;;
esac
