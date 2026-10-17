# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Jupyter notebooks as Markdown documents, Julia, Python or R scripts"
HOMEPAGE="
	https://github.com/jupytext/jupytext
	https://pypi.org/project/jupytext/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/markdown-it-py-1.0[${PYTHON_USEDEP}]
	dev-python/mdit-py-plugins[${PYTHON_USEDEP}]
	dev-python/nbformat[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
"
# The JupyterLab extension ships prebuilt in the sdist; its build hook is
# disabled by default but still listed in build-system.requires.
BDEPEND="
	dev-python/hatch-jupyter-builder[${PYTHON_USEDEP}]
	dev-python/jupyter-builder[${PYTHON_USEDEP}]
"
