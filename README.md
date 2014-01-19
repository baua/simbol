[![views](https://sourcegraph.com/api/repos/github.com/nima/site/counters/views.png)](https://sourcegraph.com/github.com/nima/site)
[![authors](https://sourcegraph.com/api/repos/github.com/nima/site/badges/authors.png)](https://sourcegraph.com/github.com/nima/site)
[![status](https://sourcegraph.com/api/repos/github.com/nima/site/badges/status.png)](https://sourcegraph.com/github.com/nima/site)

# Site (Unstable Release) README
This is the unstable/development branch `README`; for the stable release [`README`](https://github.com/nima/site/blob/gh-pages/README.md):
* If you're viewing this on the web, then please visit the [site homepage](http://nima.github.io/site/)
* If you're viewing this on a terminal, then see [`gh-pages/README.md`](https://github.com/nima/site/blob/gh-pages/README.md).

## Development Status
Here are the currently developing site modules:
<!--
:new_moon:
:waxing_crescent_moon:
:first_quarter_moon:
:waxing_gibbous_moon:
:full_moon:
:waning_gibbous_moon:
:last_quarter_moon:
:waning_crescent_moon:
:new_moon:
-->

| Module        | Code-Complete           | Description                                                         |
| ------------- | ----------------------- | ------------------------------------------------------------------- |
| unit          | :last_quarter_moon:     | Core Unit-Testing module                                            |
| hgd           | :waning_gibbous_moon:   | Core HGD (Host-Group Directive) module                              |
| net           | :full_moon:             | Core networking module                                              |
| util          | :last_quarter_moon:     | Core utilities module                                               |
| gpg           | :full_moon:             | Core GNUPG module                                                   |
| tutorial      | :waning_crescent_moon:  | The site module aims to serve as a tutorial for new site users      |
| remote        | :last_quarter_moon:     | The site remote access/execution module (ssh, ssh/sudo, tmux, etc.) |
| vault         | :last_quarter_moon:     | Core vault and secrets management module                            |
| ng            | :last_quarter_moon:     | Core Netgroup module                                                |
| git           | :last_quarter_moon:     | Auxiliary Git helper module                                         |
| dns           | :last_quarter_moon:     | Core DNS module                                                     |
| mongo         | :last_quarter_moon:     | MongoDB helper module                                               |
| help          | :last_quarter_moon:     | Core help module                                                    |
| ldap          | :last_quarter_moon:     | The site LDAP module                                                |
| softlayer     | :last_quarter_moon:     | Core Softlayer API module                                           |

---

# Build Status
Here are the current build statuses of the various GitHub branches of site:

| Branch     | Status |
|------------|--------|
| `unstable` | [![Build Status](https://travis-ci.org/nima/site.png?branch=unstable)](https://travis-ci.org/nima/site/branches) |
| `frozen`   | [![Build Status](https://travis-ci.org/nima/site.png?branch=frozen)](https://travis-ci.org/nima/site/branches) |
| `stable`   | [![Build Status](https://travis-ci.org/nima/site.png?branch=stable)](https://travis-ci.org/nima/site/branches) |
