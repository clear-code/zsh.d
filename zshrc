# -*- sh -*-

# Emamcsキーバインドを使う。
bindkey -e

# ディレクトリ移動
## ディレクトリ名だけでcdする。
setopt auto_cd
## cdで移動してもpushdと同じようにディレクトリスタックに追加する。
setopt auto_pushd

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


# プロンプト
## PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
## PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
## コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

## 256色生成用便利関数
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
###       「...」を太字のマジェンタ背景の白文字にする。
###   %d: カレントディレクトリのフルパス（省略しない）
prompt_bar_right="-[%{%B%K{magenta}%F{white}%}%d%{%f%k%b%}]-"

## プロンプトフォーマットを展開した後の文字数を返す。
count_prompt_string_characters()
{
    # print:
    #   -P: プロンプトフォーマットを展開する。
    #   -n: 改行をつけない。
    # sed:
    #   -e $'s/\e\[[0-9;]*m//g': ANSIエスケープシーケンスを削除。
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m
}

## プロンプトを更新する。
update_prompt()
{
    # プロンプトバーの左側の文字数を数える。
    # 左側では最後に実行したコマンドの終了ステータスを使って
    # いるのでこれは一番最初に実行しなければいけない。そうし
    # ないと、最後に実行したコマンドの終了ステータスが消えて
    # しまう。
    local bar_left_length=$(count_prompt_string_characters "$prompt_bar_left")
    # プロンプトバーの右側の文字数を数える。
    local bar_right_length=$(count_prompt_string_characters "$prompt_bar_right")
    # プロンプトバーに使える残り文字を計算する。
    # $COLUMNSにはターミナルの横幅が入っている。
    local bar_rest_length=$[COLUMNS - bar_left_length - bar_right_length]

    local bar_left="$prompt_bar_left"
    local bar_right="$prompt_bar_right"
    local bar_center=
    if [ $bar_rest_length -ge 0 ]; then
        # スペースが余る場合はバーの真ん中に「---...---」を入れる。
	bar_center=${(l:${bar_rest_length}::-:)}
    else
        # スペースが余っていない場合は右側に表示するパスの前半を省略して
	# 「-[.../logn/path/]-」にする。
	local bar_right_without_path=${bar_right:s/%d//}
	local max_path_length=$[COLUMNS - bar_left_length - $#bar_right_without_path]
	bar_right=${bar_right:s/%d/%${max_path_length}<...<%d%<</} #
    fi

    # プロンプトバーと左プロンプトを設定
    #   "${bar_left}${bar_center}${bar_right}": プロンプトバー
    #   $'\n': 改行
    #   "-[%h](%j)%{%B%}%#%{%b%} ": 2行目左にでるプロンプト
    #     %h: ヒストリ数。
    #     %j: 実行中のジョブ数。
    #     %{%B%}...%{%b%}: 「...」を太字にする。
    #     %#: 一般ユーザなら「%」、rootユーザなら「#」になる。
    PROMPT="${bar_left}${bar_center}${bar_right}"$'\n'"-[%h](%j)%{%B%}%#%{%b%} "
    # 右プロンプト
    #  %{%B%F{white}%K{green}}...%{%k%f%b%}: 「...」を太字で緑背景の白文字にする。
    #  %~: カレントディレクトリのフルパス（可能なら「~」で省略する）
    RPROMPT="[%{%B%F{white}%K{magenta}%}%~%{%k%f%b%}]"
}

## コマンド実行前に呼び出されるフック。
precmd()
{
    ## プロンプトを動的に更新する。
    update_prompt
}
