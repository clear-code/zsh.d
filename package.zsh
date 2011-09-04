# -*- sh -*-

: ${PACKAGE_BASE_DIR:="$HOME/.zsh.d/packages"}

package-directory()
{
    local name=$1
    echo -n "${PACKAGE_BASE_DIR}/${name:t}"
}

package-run-command()
{
    "$@"
    if test $? -eq 0; then
	return 0
    else
	echo "Failed: $@"
	return 1
    fi
}

package-install-github()
{
    local name=$1
    local package_dir="$2"

    package-run-command git clone https://github.com/${name}.git "${package_dir}"
}

package-install()
{
    local type=$1; shift
    local spec=$1; shift

    local package_dir="$(package-directory $spec)"

    if [ ! -d "${package_dir}" ]; then
	mkdir -p "${package_dir}"
	case "${type}" in
	    github)
		package-install-github "${spec}" "${package_dir}"
		;;
	    *)
		return
		;;
	esac
    fi
}
