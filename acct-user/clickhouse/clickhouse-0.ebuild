# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="ClickHouse program user"
ACCT_USER_ID=160
ACCT_USER_GROUPS=( clickhouse )
ACCT_USER_HOME="/var/lib/clickhouse"

acct-user_add_deps
