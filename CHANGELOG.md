# Changelog

## v0.3-0

- [**Breaking**] In v0.2-x, variables in URL paths would be captured using `...` (i.e. `/user/...`) but now a more legible and common format of `{variable}` is used (i.e. `/user/{userName}`). The former is unsupported now.
- [**Breaking**] `add_handler` is deprecated in favor of `get`, `post`, `put`, etc.
- The default host is no longer `localhost` but `0.0.0.0`, to make it easier to run on Docker containers without extra configuration.
- The logs printed upon handlers loading have been removed.