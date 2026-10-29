<div align="center">

# asdf-pgschema [![Build](https://github.com/jgburet/asdf-pgschema/actions/workflows/build.yml/badge.svg)](https://github.com/jgburet/asdf-pgschema/actions/workflows/build.yml) [![Lint](https://github.com/jgburet/asdf-pgschema/actions/workflows/lint.yml/badge.svg)](https://github.com/jgburet/asdf-pgschema/actions/workflows/lint.yml)

[pgschema](https://www.pgschema.com) (declarative schema migration for PostgreSQL) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `sha256sum` or `shasum`, to verify downloads against the release checksums.
- Supported platforms: Linux and macOS, on `amd64` and `arm64`.

Not every release ships every platform:

| Platform       | First version |
| -------------- | ------------- |
| `linux-amd64`  | 1.0.0         |
| `darwin-arm64` | 1.0.0         |
| `linux-arm64`  | 1.3.0         |
| `darwin-amd64` | 1.5.1         |

Releases before 1.13.3 publish no checksums; those downloads are installed unverified, with a warning.

# Install

Plugin:

```shell
asdf plugin add pgschema https://github.com/jgburet/asdf-pgschema.git
```

pgschema:

```shell
# Show all installable versions
asdf list all pgschema

# Install specific version
asdf install pgschema latest

# Set a version in your home directory's .tool-versions file
asdf set -u pgschema latest

# Now pgschema commands are available
pgschema --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! Test locally with:

```shell
asdf plugin test pgschema https://github.com/jgburet/asdf-pgschema.git "pgschema --version"
```

The same test runs in GitHub Actions on push and PR.

[Thanks goes to these contributors](https://github.com/jgburet/asdf-pgschema/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Jean-Guillaume Buret](https://github.com/jgburet/)
