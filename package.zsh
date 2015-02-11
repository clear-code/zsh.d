# -*- sh -*-
#
# Copyright (C) 2011  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this library.  If not, see <http://www.gnu.org/licenses/>.

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
