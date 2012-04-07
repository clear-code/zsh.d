# -*- sh -*-

# キーバインド
## Emacsキーバインドを使う。
bindkey -e

# ディレクトリ移動
## ディレクトリ名だけでcdする。
setopt auto_cd
## cdで移動してもpushdと同じようにディレクトリスタックに追加する。
setopt auto_pushd
## カレントディレクトリ中に指定されたディレクトリが見つからなかった場合に
## 移動先を検索するリスト。
cdpath=(~)
## ディレクトリが変わったらディレクトリスタックを表示。
chpwd_functions=($chpwd_functions dirs)

# ヒストリ
## ヒストリを保存するファイル
HISTFILE=~/.zsh_history
## メモリ上のヒストリ数。
## 大きな数を指定してすべてのヒストリを保存するようにしている。
HISTSIZE=10000000
## 保存するヒストリ数
SAVEHIST=$HISTSIZE
## ヒストリファイルにコマンドラインだけではなく実行時刻と実行時間も保存する。
setopt extended_history
## 同じコマンドラインを連続で実行した場合はヒストリに登録しない。
setopt hist_ignore_dups
## スペースで始まるコマンドラインはヒストリに追加しない。
setopt hist_ignore_space
## すぐにヒストリファイルに追記する。
setopt inc_append_history
## zshプロセス間でヒストリを共有する。
setopt share_history
## C-sでのヒストリ検索が潰されてしまうため、出力停止・開始用にC-s/C-qを使わない。
setopt no_flow_control


# プロンプト
## PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
## PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
## コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

## 256色生成用便利関数
### red: 0-5
### green: 0-5
### blue: 0-5
color256()
{
    local red=$1; shift
    local green=$2; shift
    local blue=$3; shift

    echo -n $[$red * 36 + $green * 6 + $blue + 16]
}

fg256()
{
    echo -n $'\e[38;5;'$(color256 "$@")"m"
}

bg256()
{
    echo -n $'\e[48;5;'$(color256 "$@")"m"
}

## プロンプトの作成
### ↓のようにする。
###   -(user@debian)-(0)-<2011/09/01 00:54>------------------------------[/home/user]-
###   -[84](0)%                                                                   [~]

## バージョン管理システムの情報も表示する
autoload -Uz vcs_info
zstyle ':vcs_info:*' formats \
    '(%{%F{white}%K{green}%}%s%{%f%k%})-[%{%F{white}%K{blue}%}%b%{%f%k%}]'
zstyle ':vcs_info:*' actionformats \
    '(%{%F{white}%K{green}%}%s%{%f%k%})-[%{%F{white}%K{blue}%}%b%{%f%k%}|%{%F{white}%K{red}%}%a%{%f%k%}]'

### プロンプトバーの左側
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %{%F{cyan}%}...%{%f%}: 「...」をシアン色の文字にする。
###   %n: ユーザ名
###   %m: ホスト名（完全なホスト名ではなくて短いホスト名）
###   %{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%f%k%b%}:
###                           最後に実行したコマンドが正常終了していれば
###                           太字で白文字で緑背景にして異常終了していれば
###                           太字で白文字で赤背景にする。
###   %{%F{white}%}: 白文字にする。
###     %(x.true-text.false-text): xが真のときはtrue-textになり
###                                偽のときはfalse-textになる。
###       ?: 最後に実行したコマンドの終了ステータスが0のときに真になる。
###       %K{green}: 緑景色にする。
###       %K{red}: 赤景色を赤にする。
###   %?: 最後に実行したコマンドの終了ステータス
###   %{%k%}: 背景色を元に戻す。
###   %{%f%}: 文字の色を元に戻す。
###   %{%b%}: 太字を元に戻す。
###   %D{%Y/%m/%d %H:%M}: 日付。「年/月/日 時:分」というフォーマット。
prompt_bar_left_self="(%{%B%}%n%{%b%}%{%F{cyan}%}@%{%f%}%{%B%}%m%{%b%})"
prompt_bar_left_status="(%{%B%F{white}%(?.%K{green}.%K{red})%}%?%{%k%f%b%})"
prompt_bar_left_date="<%{%B%}%D{%Y/%m/%d %H:%M}%{%b%}>"
prompt_bar_left="-${prompt_bar_left_self}-${prompt_bar_left_status}-${prompt_bar_left_date}-"
### プロンプトバーの右側
###   %{%B%K{magenta}%F{white}%}...%{%f%k%b%}:
###       「...」を太字のマゼンタ背景の白文字にする。
###   %d: カレントディレクトリのフルパス（省略しない）
prompt_bar_right="-[%{%B%K{magenta}%F{white}%}%d%{%f%k%b%}]-"

### 2行目左にでるプロンプト。
###   %h: ヒストリ数。
###   %(1j,(%j),): 実行中のジョブ数が1つ以上ある場合だけ「(%j)」を表示。
###     %j: 実行中のジョブ数。
###   %{%B%}...%{%b%}: 「...」を太字にする。
###   %#: 一般ユーザなら「%」、rootユーザなら「#」になる。
prompt_left="-[%h]%(1j,(%j),)%{%B%}%#%{%b%} "

## プロンプトフォーマットを展開した後の文字数を返す。
## 日本語未対応。
count_prompt_characters()
{
    # print:
    #   -P: プロンプトフォーマットを展開する。
    #   -n: 改行をつけない。
    # sed:
    #   -e $'s/\e\[[0-9;]*m//g': ANSIエスケープシーケンスを削除。
    # wc:
    #   -c: 文字数を出力する。
    # sed:
    #   -e 's/ //g': *BSDやMac OS Xのwcは数字の前に空白を出力するので削除する。
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m | sed -e 's/ //g'
}

## プロンプトを更新する。
update_prompt()
{
    # プロンプトバーの左側の文字数を数える。
    # 左側では最後に実行したコマンドの終了ステータスを使って
    # いるのでこれは一番最初に実行しなければいけない。そうし
    # ないと、最後に実行したコマンドの終了ステータスが消えて
    # しまう。
    local bar_left_length=$(count_prompt_characters "$prompt_bar_left")
    # プロンプトバーに使える残り文字を計算する。
    # $COLUMNSにはターミナルの横幅が入っている。
    local bar_rest_length=$[COLUMNS - bar_left_length]

    local bar_left="$prompt_bar_left"
    # パスに展開される「%d」を削除。
    local bar_right_without_path="${prompt_bar_right:s/%d//}"
    # 「%d」を抜いた文字数を計算する。
    local bar_right_without_path_length=$(count_prompt_characters "$bar_right_without_path")
    # パスの最大長を計算する。
    #   $[...]: 「...」を算術演算した結果で展開する。
    local max_path_length=$[bar_rest_length - bar_right_without_path_length]
    # パスに展開される「%d」に最大文字数制限をつける。
    #   %d -> %(C,%${max_path_length}<...<%d%<<,)
    #     %(x,true-text,false-text):
    #         xが真のときはtrue-textになり偽のときはfalse-textになる。
    #         ここでは、「%N<...<%d%<<」の効果をこの範囲だけに限定させる
    #         ために用いているだけなので、xは必ず真になる条件を指定している。
    #       C: 現在の絶対パスが/以下にあると真。なので必ず真になる。
    #       %${max_path_length}<...<%d%<<:
    #          「%d」が「${max_path_length}」カラムより長かったら、
    #          長い分を削除して「...」にする。最終的に「...」も含めて
    #          「${max_path_length}」カラムより長くなることはない。
    bar_right=${prompt_bar_right:s/%d/%(C,%${max_path_length}<...<%d%<<,)/}
    # 「${bar_rest_length}」文字分の「-」を作っている。
    # どうせ後で切り詰めるので十分に長い文字列を作っているだけ。
    # 文字数はざっくり。
    local separator="${(l:${bar_rest_length}::-:)}"
    # プロンプトバー全体を「${bar_rest_length}」カラム分にする。
    #   %${bar_rest_length}<<...%<<:
    #     「...」を最大で「${bar_rest_length}」カラムにする。
    bar_right="%${bar_rest_length}<<${separator}${bar_right}%<<"

    # プロンプトバーと左プロンプトを設定
    #   "${bar_left}${bar_right}": プロンプトバー
    #   $'\n': 改行
    #   "${prompt_left}": 2行目左のプロンプト
    PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
    # 右プロンプト
    #   %{%B%F{white}%K{green}}...%{%k%f%b%}:
    #       「...」を太字で緑背景の白文字にする。
    #   %~: カレントディレクトリのフルパス（可能なら「~」で省略する）
    RPROMPT="[%{%B%F{white}%K{magenta}%}%~%{%k%f%b%}]"
    case "$TERM_PROGRAM" in
	Apple_Terminal)
	    # Mac OS Xのターミナルでは$COLUMNSに右余白が含まれていないので
	    # 右プロンプトに「-」を追加して調整。
	    ## 2011-09-05
	    RPROMPT="${RPROMPT}-"
	    ;;
    esac

    # バージョン管理システムの情報を取得する。
    LANG=C vcs_info >&/dev/null
    # バージョン管理システムの情報があったら右プロンプトに表示する。
    if [ -n "$vcs_info_msg_0_" ]; then
	RPROMPT="${vcs_info_msg_0_}-${RPROMPT}"
    fi
}

## コマンド実行前に呼び出されるフック。
precmd_functions=($precmd_functions update_prompt)


# 補完
## 初期化
autoload -U compinit
compinit

## 補完方法毎にグループ化する。
### 補完方法の表示方法
###   %B...%b: 「...」を太字にする。
###   %d: 補完方法のラベル
zstyle ':completion:*' format '%B%d%b'
zstyle ':completion:*' group-name ''

## 補完侯補をメニューから選択する。
### select=2: 補完候補を一覧から選択する。
###           ただし、補完候補が2つ以上なければすぐに補完する。
zstyle ':completion:*:default' menu select=2

## 補完候補に色を付ける。
### "": 空文字列はデフォルト値を使うという意味。
zstyle ':completion:*:default' list-colors ""

## 補完候補がなければより曖昧に候補を探す。
### m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する。
### r:|[._-]=*: 「.」「_」「-」の前にワイルドカード「*」があるものとして補完する。
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=*'

## 補完方法の設定。指定した順番に実行する。
### _oldlist 前回の補完結果を再利用する。
### _complete: 補完する。
### _match: globを展開しないで候補の一覧から補完する。
### _history: ヒストリのコマンドも補完候補とする。
### _ignored: 補完候補にださないと指定したものも補完候補とする。
### _approximate: 似ている補完候補も補完候補とする。
### _prefix: カーソル以降を無視してカーソル位置までで補完する。
zstyle ':completion:*' completer \
    _oldlist _complete _match _history _ignored _approximate _prefix

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
## 詳細な情報を使う。
zstyle ':completion:*' verbose yes
## sudo時にはsudo用のパスも使う。
zstyle ':completion:sudo:*' environ PATH="$SUDO_PATH:$PATH"

## カーソル位置で補完する。
setopt complete_in_word
## globを展開しないで候補の一覧から補完する。
setopt glob_complete
## 補完時にヒストリを自動的に展開する。
setopt hist_expand
## 補完候補がないときなどにビープ音を鳴らさない。
setopt no_beep
## 辞書順ではなく数字順に並べる。
setopt numeric_glob_sort


# 展開
## --prefix=~/localというように「=」の後でも
## 「~」や「=コマンド」などのファイル名展開を行う。
setopt magic_equal_subst
## 拡張globを有効にする。
## glob中で「(#...)」という書式で指定する。
setopt extended_glob
## globでパスを生成したときに、パスがディレクトリだったら最後に「/」をつける。
setopt mark_dirs


# ジョブ
## jobsでプロセスIDも出力する。
setopt long_list_jobs


# 実行時間
## 実行したプロセスの消費時間が3秒以上かかったら
## 自動的に消費時間の統計情報を表示する。
REPORTTIME=3

# ログイン・ログアウト
## 全てのユーザのログイン・ログアウトを監視する。
watch="all"
## ログイン時にはすぐに表示する。
log

## ^Dでログアウトしないようにする。
setopt ignore_eof


# 単語
## 「/」も単語区切りとみなす。
WORDCHARS=${WORDCHARS:s,/,,}
## 「|」も単語区切りとみなす。
## 2011-09-19
WORDCHARS="${WORDCHARS}|"


# alias
## ページャーを使いやすくする。
### grep -r def *.rb L -> grep -r def *.rb |& lv
alias -g L="|& $PAGER"
## grepを使いやすくする。
alias -g G='| grep'
## 後はおまけ。
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sed'

## 完全に削除。
alias rr="command rm -rf"
## ファイル操作を確認する。
alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"

## pushd/popdのショートカット。
alias pd="pushd"
alias po="popd"

## lsとpsの設定
### ls: できるだけGNU lsを使う。
### ps: 自分関連のプロセスのみ表示。
case $(uname) in
    *BSD|Darwin)
	if [ -x "$(which gnuls)" ]; then
	    alias ls="gnuls"
	    alias la="ls -lhAF --color=auto"
	else
	    alias la="ls -lhAFG"
	fi
	alias ps="ps -fU$(whoami)"
	;;
    SunOS)
	if [ -x "`which gls`" ]; then
	    alias ls="gls"
	    alias la="ls -lhAF --color=auto"
	else
	    alias la="ls -lhAF"
	fi
	alias ps="ps -fl -u$(/usr/xpg4/bin/id -un)"
	;;
    *)
	alias la="ls -lhAF --color=auto"
	alias ps="ps -fU$(whoami) --forest"
	;;
esac

## Emacsのショートカット。
### 2011-11-06
alias e="emacs &"
### -nw: ターミナル内でEmacsを起動する。
### 2011-11-06
alias enw="emacs -nw"

## exitのショートカット。
### 2011-11-06
alias x="exit"

## カスタムaliasの設定
### ~/.zsh.d/zshalias → ~/.zshaliasの順に探して
### 最初に見つかったファイルを読み込む。
### (N-.): 存在しないファイルは登録しない。
###    パス(...): ...という条件にマッチするパスのみ残す。
###            N: NULL_GLOBオプションを設定。
###               globがマッチしなかったり存在しないパスを無視する。
###            -: シンボリックリンク先のパスを評価。
###            .: 通常のファイルのみ残す。
### 2011-11-06
alais_files=(~/.zsh.d/zshalias(N-.)
             ~/.zshalias(N-.))
for alias_file in ${alias_files}; do
    source "${alias_file}"
    break
done

# ウィンドウタイトル
## 実行中のコマンドとユーザ名とホスト名とカレントディレクトリを表示。
update_title() {
    local command_line=
    typeset -a command_line
    command_line=${(z)2}
    local command=
    if [ ${(t)command_line} = "array-local" ]; then
	command="$command_line[1]"
    else
	command="$2"
    fi
    print -n -P "\e]2;"
    echo -n "(${command})"
    print -n -P " %n@%m:%~\a"
}
## X環境上でだけウィンドウタイトルを変える。
if [ -n "$DISPLAY" ]; then
    preexec_functions=($preexec_functions update_title)
fi
