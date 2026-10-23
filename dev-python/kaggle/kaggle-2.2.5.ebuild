# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1 pypi

DESCRIPTION="Official Kaggle API"
HOMEPAGE="https://github.com/Kaggle/kaggle-api"

LICENSE="Apache-2.0"
SLOT=0
KEYWORDS="~amd64"

RDEPEND="
	dev-python/bleach[${PYTHON_USEDEP}]
	dev-python/jupytext[${PYTHON_USEDEP}]
	>=dev-python/kagglesdk-0.1.35[${PYTHON_USEDEP}]
	<dev-python/kagglesdk-1.0[${PYTHON_USEDEP}]
	dev-python/packaging[${PYTHON_USEDEP}]
	dev-python/protobuf[${PYTHON_USEDEP}]
	dev-python/python-dateutil[${PYTHON_USEDEP}]
	dev-python/python-dotenv[${PYTHON_USEDEP}]
	dev-python/python-slugify[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	>=dev-python/urllib3-1.15.1[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

python_test() {
	export KAGGLE_API_ENDPOINT=http://localhost
	export KAGGLE_API_ENVIRONMENT=LOCALHOST
	# test_config_actions expects the directory to be named "kaggle".
	export KAGGLE_CONFIG_DIR="${T}/kaggle"
	mkdir -p "${KAGGLE_CONFIG_DIR}" || die
	export KAGGLE_USERNAME=joe
	export KAGGLE_KEY=local_api_token
	printf '{"username":"%s","key":"%s"}' "${KAGGLE_USERNAME}" "${KAGGLE_KEY}" \
		> "${KAGGLE_CONFIG_DIR}"/kaggle.json || die "Cannot generate test credentials."
	chmod 600 "${KAGGLE_CONFIG_DIR}"/kaggle.json || die
	epytest --import-mode=importlib
}
