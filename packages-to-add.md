# Packages Not Translatable to apt

These Brewfile entries have no standard apt equivalent and need alternative installation methods.

## Not in standard apt — needs custom installers

| Brew entry | Reason | Suggested alternative |
|---|---|---|
| `asdf` | No apt package | `git clone` from official repo |
| `beads` | Custom tap `anomalyco/tap` | Brew or binary release |
| `deno` | No apt package | Official install script |
| `devcontainer` | npm package | `npm install -g @devcontainers/cli` |
| `diskus` | Rust binary, not packaged | `cargo install diskus` or GitHub release |
| `dolt` | No apt package | GitHub release binary |
| `dust` | Rust binary, not packaged | `cargo install du-dust` or GitHub release |
| `eza` | Not in standard apt | GitHub release or `cargo install eza` |
| `gemini-cli` | No apt package | Official install script / npm |
| `gastown` | Custom/internal tool | Source or binary release |
| `glow` | No apt package | GitHub release binary |
| `hyperfine` | Rust binary, not in apt | `cargo install hyperfine` or GitHub release |
| `mkcert` | No apt package | GitHub release binary |
| `moor` | Custom pager | Source or binary release |
| `opencode` | Custom tap `anomalyco/tap` | GitHub release |
| `oh-my-posh` | Custom tap | Official install script |
| `postgresql@18` | Needs PGDG apt repo | `echo "deb ... pgdg ..." + apt-key` |
| `procs` | Rust binary, not in apt | `cargo install procs` or GitHub release |
| `sad` | Rust binary, not in apt | `cargo install sad` or GitHub release |
| `sqlfluff` | Python package | `pipx install sqlfluff` |
| `step` | Smallstep CLI | Official Smallstep apt repo or GitHub release |
| `stringer` | Custom tap `davetashner/tap` | Source or binary release |
| `supabase` | Custom tap | Official Supabase install script |
| `uv` | Not in apt | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| `volta` | Not in apt | Official install script |
| `csvkit` | Python package | `pipx install csvkit` |
| `pillow` | Python package | `pip install Pillow` (also added `python3-pil` to aptfile) |

## Notes

- **`postgresql@18`** specifically needs the [PGDG apt repository](https://www.postgresql.org/download/linux/ubuntu/) — likely warrants its own script section.
- **Rust binaries** (`diskus`, `dust`, `eza`, `hyperfine`, `procs`, `sad`) could all be handled together with a `cargo install` block if Rust is available.
- **pipx-installable tools** (`sqlfluff`, `csvkit`) can share a single post-apt step.
