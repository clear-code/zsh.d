# -*- sh -*-

# パスの設定
## 重複したパスを登録しない。
typeset -U path
## (N-/): 存在しないパスは登録しない。
path=(# システム用
      /bin(N-/)
      # 自分用
      $HOME/local/bin(N-/)
      # Debian GNU/Linux用
      /var/lib/gems/*/bin(N-/)
      # MacPorts用
      /opt/local/bin(N-/)
      # Solaris用
      /opt/csw/bin(N-/)
      /usr/sfw/bin(N-/)
      # Cygwin用
      /cygdrive/c/meadow/bin(N-/)
      # システム用
      /usr/local/bin(N-/)
      /usr/bin(N-/)
      /usr/games(N-/))

# man用パスの設定
## 重複したパスを登録しない。
typeset -U manpath
## (N-/) 存在しないパスは登録しない。
manpath=(# 自分用
         $HOME/local/share/man(N-/)
         # MacPorts用
         /opt/local/share/man(N-/)
         # Solaris用
         /opt/csw/share/man(N-/)
         /usr/sfw/share/man(N-/)
         # システム用
         /usr/local/share/man(N-/)
         /usr/share/man(N-/))

# Rubyの設定
## ライブラリのロードパス
### -x: export RUBYLIBも一緒に行う。
### -T: RUBYLIBとruby_pathを連動する。
typeset -xT RUBYLIB ruby_path
### 重複したパスを登録しない。
typeset -U ruby_path
### パスを設定
ruby_path=(# カレントディレクトリのライブラリを優先する
           ./lib)

# Pythonの設定
### ライブラリのロードパス
### -x: export PYTHONPATHも一緒に行う。
### -T: PYTHONPATHとpython_pathを連動する。
typeset -xT PYTHONPATH pyhon_path
### 重複したパスを登録しない。
typeset -U python_path
### パスを設定。
python_path=(# カレントディレクトリのライブラリを優先する
             ./lib)

# ページャの設定
if type lv > /dev/null 2>&1; then
    ## lvを優先する。
    export PAGER="lv"
else
    ## lvがなかったらlessを使う。
    export PAGER="less"
fi

# lvの設定
if type lv > /dev/null 2>&1; then
    ## -c: ANSIエスケープシーケンスの色付けなどを有効にする。
    ## -l: 1行が長くと折り返されていても1行として扱う。
    ##     （コピーしたときに余計な改行を入れない。）
    export LV="-c -l"
else
    ## lvがなくてもlvでページャーを起動する。
    alias lv="$PAGER"
fi

# grepの設定
## GNU grepがあったら優先して使う。
if type ggrep > /dev/null 2>&1; then
    alias grep=ggrep
fi
## デフォルトオプションの設定
export GREP_OPTIONS
### バイナリファイルにはマッチさせない。
GREP_OPTIONS="--binary-files=without-match"
### grep対象としてディレクトリを指定したらディレクトリ内を再帰的にgrepする。
GREP_OPTIONS="--directories=recurse $GREP_OPTIONS"
### 拡張子が.tmpのファイルは無視する。
GREP_OPTIONS="--exclude=\*.tmp $GREP_OPTIONS"
### 管理用ディレクトリを無視する。
if grep --help | grep -- --exclude-dir > /dev/null; then
    GREP_OPTIONS="--exclude-dir=.svn $GREP_OPTIONS"
    GREP_OPTIONS="--exclude-dir=.git $GREP_OPTIONS"
    GREP_OPTIONS="--exclude-dir=.deps $GREP_OPTIONS"
    GREP_OPTIONS="--exclude-dir=.libs $GREP_OPTIONS"
fi
### 可能なら色を付ける。
if grep --help | grep -- --color > /dev/null; then
    GREP_OPTIONS="--color=auto $GREP_OPTIONS"
fi


# エディタの設定
## vimを使う。
export EDITOR=vim
## vimがなくてもvimでviを起動する。
if ! type vim > /dev/null 2>&1; then
    alias vim=vi
fi

# メールアドレスの設定
## ~/.zsh.d/email → ~/.emailの順に探して最初に見つかったファイルから読み込む。
email_files=(~/.zsh.d/email(N-/)
             ~/.email(N-/))
for email_file in email_file; do
    export EMAIL=$(cat "$email_file")
    break
done

# gitの設定
## メールアドレスを設定
export GIT_AUTHOR_EMAIL="$EMAIL"
export GIT_COMMITTER_EMAIL="$EMAIL"
