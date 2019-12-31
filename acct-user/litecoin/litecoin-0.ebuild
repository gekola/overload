# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit acct-user

DESCRIPTION="System-wide Litecoin services user"
ACCT_USER_ID=583
ACCT_USER_GROUPS=( litecoin )
ACCT_USER_HOME="/var/lib/litecoin"

acct-user_add_deps
