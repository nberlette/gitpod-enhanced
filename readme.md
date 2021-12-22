# gitpod-enhanced

This is based on the official [**gitpod/workspace-full**](https://hub.docker.com/r/gitpod/workspace-full) image, with some opinionated enhancements:

## Features

- [x] Git branch + status via `git-prompt.sh`, ([from the git/git repo](https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh))
- [x] Dedupes `$PATH` environment variable
- [x] Prepends `yarn global bin` to `$PATH` for easier CLI (allows calling `svelte-kit` instead of `npx svelte-kit`, for example)
- [x] Sensible defaults for `ls`, `diff`, `grep` — and all with `--color=always` enabled.
- [x] Adds [`git-extras`](https://github.com/tj/git-extras), `fzf`, and `neovim`
- [x] Aliases, utilities, and various other functional tweaks/upgrades

## Todo List

- [ ] Securely integrate PGP signatures for all commits made from Gitpod (that green "Verified" tag on GitHub)
- [ ] ... have any ideas?

## License

[MIT](https://mit-license.org) © 2021 [Nicholas Berlette](https://github.com/nberlette)
