# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 ruby22"

RUBY_FAKEGEM_TASK_TEST=""
RUBY_FAKEGEM_RECIPE_DOC="yard"
RUBY_FAKEGEM_EXTRADOC="README.md"

inherit ruby-fakegem

DESCRIPTION="BRASS is a very basic assertions framework for Ruby"
HOMEPAGE="https://rubyworks.github.io/brass/"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""