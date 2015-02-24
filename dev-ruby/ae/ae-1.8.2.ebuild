# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 ruby22"

RUBY_FAKEGEM_TASK_TEST=""
RUBY_FAKEGEM_RECIPE_DOC="yard"
RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="Assertive Expressive is an assertions library designed for reuse"
HOMEPAGE="https://rubyworks.github.io/ae/"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

# Tests cause circular dependencies with dev-ruby/qed
RESTRICT="test"
