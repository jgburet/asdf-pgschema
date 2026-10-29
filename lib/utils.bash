#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/pgplex/pgschema"
TOOL_NAME="pgschema"
TOOL_TEST="pgschema --version"

# Releases before this one name assets without the version (pgschema-<os>-<arch>).
FIRST_VERSIONED_ASSET=1.4.2
# Releases before this one publish no checksums file.
FIRST_CHECKSUMMED_RELEASE=1.13.3

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

version_at_least() {
	local version="$1"
	local minimum="$2"
	[ "$(printf "%s\n%s\n" "$minimum" "$version" | sort_versions | head -n1)" = "$minimum" ]
}

# Excludes non-release tags such as ir/v0.1.0 (Go submodule).
list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		grep -E '^v[0-9]+\.[0-9]+\.[0-9]+' |
		sed 's/^v//'
}

list_all_versions() {
	list_github_tags
}

get_platform() {
	local platform
	platform="$(uname -s | tr '[:upper:]' '[:lower:]')"

	case "$platform" in
	darwin | linux) echo "$platform" ;;
	*) fail "Unsupported platform: $platform" ;;
	esac
}

get_arch() {
	local arch
	arch="$(uname -m)"

	case "$arch" in
	x86_64 | amd64) echo "amd64" ;;
	aarch64 | arm64) echo "arm64" ;;
	*) fail "Unsupported architecture: $arch" ;;
	esac
}

get_asset_name() {
	local version="$1"

	if version_at_least "$version" "$FIRST_VERSIONED_ASSET"; then
		echo "pgschema-${version}-$(get_platform)-$(get_arch)"
	else
		echo "pgschema-$(get_platform)-$(get_arch)"
	fi
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url="$GH_REPO/releases/download/v${version}/$(get_asset_name "$version")"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" ||
		fail "Could not download $url (some releases do not ship every platform, see README)"
}

sha256() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | cut -d' ' -f1
	elif command -v shasum >/dev/null 2>&1; then
		shasum -a 256 "$1" | cut -d' ' -f1
	else
		fail "Neither sha256sum nor shasum is available to verify the download."
	fi
}

# Gated on version rather than on the checksums file's presence, so that a missing
# file on a recent release fails the install instead of silently skipping verification.
verify_release() {
	local version filename asset url expected actual
	version="$1"
	filename="$2"
	asset="$(get_asset_name "$version")"
	url="$GH_REPO/releases/download/v${version}/pgschema-${version}-checksums.txt"

	if ! version_at_least "$version" "$FIRST_CHECKSUMMED_RELEASE"; then
		echo "* Warning: $TOOL_NAME $version publishes no checksums, skipping verification." >&2
		return
	fi

	echo "* Verifying checksum..."
	expected="$(curl "${curl_opts[@]}" "$url" | awk -v asset="$asset" '$2 == asset { print $1 }')" ||
		fail "Could not download $url"
	[ -n "$expected" ] || fail "No checksum found for $asset in $url"

	actual="$(sha256 "$filename")"
	[ "$expected" = "$actual" ] || fail "Checksum mismatch for $asset: expected $expected, got $actual"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_root="${3%/bin}"
	local install_path="$install_root/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"

		mkdir -p "$install_path"
		cp "$ASDF_DOWNLOAD_PATH/$tool_cmd" "$install_path/$tool_cmd"

		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_root"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
