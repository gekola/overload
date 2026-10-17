# Gentoo environment for bumping and test-building this overlay.
# Built and run by scripts/in-gentoo, which mounts the overlay at
# /var/db/repos/overload.
FROM gentoo/portage:latest AS portage

FROM gentoo/stage3:latest
COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

# Unprivileged containers cannot unshare namespaces. The official binhost
# provides prebuilt toolchains and most dependencies.
RUN printf '%s\n' \
		'FEATURES="${FEATURES} getbinpkg -ipc-sandbox -network-sandbox -pid-sandbox"' \
		'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf \
	&& getuto \
	&& emerge --quiet --noreplace app-misc/jq dev-python/pip dev-util/pkgcheck \
		dev-util/pkgdev app-portage/pycargoebuild dev-vcs/git net-misc/curl \
	&& git config --system --add safe.directory '*' \
	&& mkdir -p /etc/portage/repos.conf /etc/portage/package.accept_keywords \
	&& cp /usr/share/portage/config/repos.conf /etc/portage/repos.conf/gentoo.conf \
	&& printf '[overload]\nlocation = /var/db/repos/overload\n' \
		> /etc/portage/repos.conf/overload.conf \
	&& echo '*/*::overload ~amd64' > /etc/portage/package.accept_keywords/overload
