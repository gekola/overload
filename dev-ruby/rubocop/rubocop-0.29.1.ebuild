# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
USE_RUBY="ruby19 ruby20 ruby21 ruby22"

RUBY_FAKEGEM_RECIPE_TEST="rspec"

RUBY_FAKEGEM_TASK_DOC=""
RUBY_FAKEGEM_EXTRADOC="README.md CHANGELOG.md"

inherit ruby-fakegem

DESCRIPTION="RuboCop is a Ruby static code analyzer."
HOMEPAGE="http://github.com/bbatsov/rubocop"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test"

ruby_add_rdepend virtual/rubygems
ruby_add_rdepend dev-ruby/rainbow
ruby_add_rdepend dev-ruby/parser
ruby_add_rdepend dev-ruby/powerpack
ruby_add_rdepend dev-ruby/astrolabe
ruby_add_rdepend dev-ruby/ruby-progressbar
