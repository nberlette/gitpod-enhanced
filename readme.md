# gitpod-enhanced

This is based on the official [**gitpod/workspace-full**](https://hub.docker.com/r/gitpod/workspace-full) image, with some opinionated enhancements:

## Features

- [x] Git status with `git-prompt.sh`, ([from the git/git repo](https://github.com/git/git/raw/master/contrib/completion/git-prompt.sh))
- [x] Sensible defaults for `ls`, `diff`, `grep`, all with `--color=always` enabled
- [x] [GitHub CLI](https://cli.github.com), [`git-extras`](https://github.com/tj/git-extras), `fzf`, and `neovim`
- [x] Deduped `$PATH` variable
- [x] Prepend `yarn global bin` to `$PATH` (e.g. permits `svelte-kit` instead of `npx svelte-kit`)
- [x] `pnpm`, `typescript`, `ts-node`, `ts-standard`, `degit`, `@antfu/ni`
- [x] Aliases, utilities, and various other functional tweaks/upgrades

### Todo List

- Secure solution for PGP-signing commits from Gitpod

---  

## Git Prompt Configuration

Below is a list of all the available `GIT_PS1_` variables and their default values, which control the functionality and display of the integrated git prompt.

```bash
GIT_PS1_SHOWCOLORHINTS="1"
GIT_PS1_SHOWDIRTYSTATE="1"
GIT_PS1_SHOWSTASHSTATE="1"
GIT_PS1_SHOWUNTRACKEDFILES="1"
GIT_PS1_SHOWUPSTREAM=""
GIT_PS1_OMITSPARSESTATE="1"
GIT_PS1_STATESEPARATOR=""
GIT_PS1_DESCRIBE_STYLE="tag"
GIT_PS1_HIDE_IF_PWD_IGNORED=""

GIT_PS1_PREFIX="\[\e]0;\u \W\e\]\[\e[1;7;33m\] \u \[\e[0;7;36m\] \w \[\e[0;1m\] git:("
GIT_PS1_SUFFIX="\[\e[1m\])\[\e[0m\]\n\[\e[1;32;6m\]\$\[\e[0m\] "
GIT_PS1_FORMAT="%s"
```

### Overriding the Defaults

You can change or remove any of these from the Gitpod Dashboard Settings under `Environment Variables`. Alternatively, you can override in `.vscode/settings.json`, with the `terminal.integrated.env.linux` option:

```json
{
  "terminal.integrated.env.linux": {
    "GIT_PS1_SHOWUPSTREAM": "auto verbose name",
    "GIT_PS1_SHOWUNTRACKEDFILES": ""
  }
}
```

### `git config` overrides

Finally, **some** of the variables have an equivalent `git config` setting, which allows you to override on a per-repository level, right from the `.gitpod.yml` configuration file. Most of these only allow "false" for a value, if any.

```yaml
gitConfig:
  bash.showUpstream: "false"
  bash.hideIfPwdIgnored: "false"
```

### Customizing the `PS1` prompt string

The last three options listed, `GIT_PS1_PREFIX`, `GIT_PS1_SUFFIX`, `GIT_PS1_FORMAT` allow you to change the colors and format of the surrounding `PS1` prompt string. These have no `git config` equivalent, and must either be set in the `settings.json` file, the Gitpod Dashboard, or by exporting new values in your bash profile:

```bash
echo 'export GIT_PS1_PREFIX="..."' >> ~/.bashrc.d/20-profile
```

---  

## License

[MIT](https://mit-license.org) © 2021 [Nicholas Berlette](https://github.com/nberlette)
