# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="Official Kaggle API"
HOMEPAGE="https://github.com/Kaggle/kaggle-api"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64 ~x86"
IUSE="test"

RDEPEND="
	dev-python/bleach[${PYTHON_USEDEP}]
	dev-python/charset-normalizer[${PYTHON_USEDEP}]
	dev-python/certifi[${PYTHON_USEDEP}]
	dev-python/idna[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/python-slugify[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/text-unidecode[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/urllib3[${PYTHON_USEDEP}]
	dev-pytonn/webencodings[${PYTHON_USEDEP}]
"

DEPEND="${RDEPEND}"

BDEPEND="test? (
	${RDEPEND}
	dev-python/pytest[${PYTHON_USEDEP}]
)"

python_test() {
	export KAGGLE_API_ENDPOINT=http://localhost
	export KAGGLE_API_ENVIRONMENT=LOCALHOST
	export KAGGLE_CONFIG_DIR="${PWD}"
	export KAGGLE_KEY=local_api_token
	export KAGGLE_USERNAME="joe"
	export KAGGLE_KEY="local_api_token"
	echo "{\"username\":\"$KAGGLE_USERNAME\",\"key\":\"$KAGGLE_KEY\"}" > kaggle.json || die "Cannot generate test credentials."
	chmod 600 kaggle.json
	epytest --import-mode=importlib
}
