<!-- -*- gfm -*- -->

# Zshのオススメ設定集 #

## 使い方 ##

	% git clone https://github.com/clear-code/zsh.d.git ~/.zsh.d
	% echo "source ~/.zsh.d/zshrc" > ~/.zshrc
	% echo "source ~/.zsh.d/zshenv" > ~/.zshenv

## カスタマイズ ##

### Eメールアドレス ###

~/.zsh.d/emailまたは~/emailにメールアドレスを書いておくと、そ
のファイルの中身が環境変数EMAILに設定されます。

### その他のカスタマイズ ###

~/.zshenvや~/.zshrcの最後に追記してください。

## パッケージ管理システム ##

package.zshはGitHub上にあるパッケージを簡単にインストールする
パッケージ管理システムです。設定ファイルは以下のようなディレ
クトリ構成とし、パッケージの設定は~/.zshrcではな
く、~/.zsh.d/config/packages.zshで行うことをオススメします。
このように設定ファイルをキレイに整理してメンテナンスしやすく
します。

	~
	├── .zshrc                    # シェルを起動する毎に読み込まれる。
	│                               # ~/.zsh.d/zshrcを読み込んで
	│                               # 標準機能の追加設定を行う。
	├── .zshenv                   # ログイン時に一度だけ読み込まれる。
	│                               # ~/.zsh.d/zshenvを読み込んで
	│                               # 追加設定を行う。
	└── .zsh.d                    # zsh関連のファイル置き場。
	       ├── config             # 標準機能以外の設定を置くディレクトリ。
	       │    └── packages.zsh # 追加パッケージの設定をするファイル。
	       ├── zshrc              # オススメ~/.zshrc設定。
	       ├── zshenv             # オススメ~/.zshenv設定。
	       ├── package.zsh        # パッケージ管理システム。
	       └── packages           # パッケージをインストールするディレクトリ。

[auto-fu](https://github.com/hchbaw/auto-fu.zsh/)の設定例を以
下に示します。まず、以下のようなパッケージ用の設定ファイル
~/.zsh.d/config/packages.zshを作成します。

~/.zsh.d/config/packages.zsh:

	# -*- sh -*-
	
	# パッケージ管理システムを読み込む。
	source ~/.zsh.d/package.zsh
	
	# パッケージがインストールされていなければGitHubからcloneしてくる。
	package-install github hchbaw/auto-fu.zsh
	# パッケージを読み込む。
	source $(package-directory hchbaw/auto-fu.zsh)/auto-fu.zsh
	# auto-fuを初期化する。
	zle-line-init() {
	    auto-fu-init
	}
	zle -N zle-line-init
	zle -N zle-keymap-select auto-fu-zle-keymap-select
	
	# auto-fuをカスタマイズする。
	## Enterを押したときは自動補完された部分を利用しない。
	afu+cancel-and-accept-line() {
	    ((afu_in_p == 1)) && { afu_in_p=0; BUFFER="$buffer_cur" }
	    zle afu+accept-line
	}
	zle -N afu+cancel-and-accept-line
	bindkey -M afu "^M" afu+cancel-and-accept-line

そして、~/.zshrcからこの設定ファイルを読み込みます。

~/.zshrc:

	source ~/.zsh.d/zshrc
	source ~/.zsh.d/config/packages.zsh

これで、次にシェルを立ち上げるとauto-fuが使えるようになります。
