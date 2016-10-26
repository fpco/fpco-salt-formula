## Python

### `python`

Uses the `pkg.installed` salt state to install the `python` and
`python-setuptools` packages from apt.


### `python.pip`

In order, the formula will:

* Include the `python` formula, ensuring those packages are installed first.
* Use `cmd.run` to execute `easy_install -U pip`, unless `pip` already exists in
  `$PATH`.
* Use `cmd.run` to execute `pip install --upgrade pip`, to use `pip` to upgrade
  itself.
* Use `cmd.run` to execute `pip --version`, giving the user that info in the log
* Use `module.wait` to execute the `saltutil.refresh_modules` salt module, which
  will reload all modules in salt so the pip states and modules are available when
  the formula completes.

