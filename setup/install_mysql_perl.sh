#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-02-22 22:53:05 +0000 (Sat, 22 Feb 2020)
#
#  https://github.com/harisekhon/nagios-plugins
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(dirname "$0")"

if [ "$(uname -s)" != Darwin ]; then
    "OS is not Mac, skipping mysql_config workaround, install DBD::mysql normally via cpanm"
    exit 0
fi

if perl -e 'use DBD::mysql;' &>/dev/null; then
    echo "Perl DBD::mysql already installed, skipping mysql_config workaround"
    exit 0
fi

set +e
mysql_config="$(type -P mysql_config)"
set -e
if [ -z "$mysql_config" ]; then
    echo "mysql_config not found in \$PATH!! ($PATH)"
    exit 1
fi

"$mysql_config" || :

echo
echo "patching $mysql_config"
# shellcheck disable=SC2016
sed -ibak 's/^libs="$libs -lssl/libs="$libs -lmysqlclient -lssl/' "$mysql_config"
echo

"$mysql_config" || :

"$srcdir/../bash-tools/perl_cpanm_install_if_absent.sh" DBD::mysql
