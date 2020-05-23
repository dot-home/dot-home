Python Support in dot-home
==========================

This will not be implemented before we rewrite dot-home no longer to
use symlinks, but instead copy files (for Windows support).


Per-module Virtual Environments
-------------------------------

Each module that has a `dh/requirements.txt` file will have it's own
Python venv (or virtualenv?) created for it, as follows:

1. Create the venv `--without-pip` if a version of python with venv is
   available.
   - If not, do we bootstrap virtualenv?
   - Provide an option to ask that dot-home use a specific Python
     interpreter on this host, e.g., `$(pythonz locate 3.7.3)` ==
     `~/.pythonz/pythons/CPython-3.7.3/bin/python3`?

2. Bootstrap `pip` into the venv with `get-pip.py` from
   <https://bootstrap.pypa.io/get-pip.py>. We probably want
   `--no-setuptools`, and may want `--no-wheel`.

3. `pip install -r $module/dh/requirements.txt` (or put "python" in
   the name of that file?).

4. Find a list of any binaries installed into the virtualenv that
   should be made globally available, and add shims from them in
   `~/.local/bin/`.

5. For all files in `$module/bin/` that contain `python` in the
   shebang, install a shim in `~/.local/bin/`.
   - Linux: copy the file and change only the shebang to point to the
     venv's interpreter.
   - [Windows][win]: figure out what pip does for its shims (they're
     Windows executables) and do something similar. Or perhaps
     generate a `.cmd` version of the file from `$module/bin/` that
     contains the kind of header that `aws-cli/bin/aws.cmd` contains.

Some of the work being done here (especially the bootstrap stuff) is
similar to what the [sedoc activate][virtualenv] script does. Consider
extracting that to its own repo, adding a test framework, and re-using
that code for dot-home's support of this stuff. (Perhaps it can be
extended to offer direct support to "clients" like dot-home.)


References
----------

- [Python on Windows references][win]
- [Virtualenv reference][virtualenv] (probably needs venv info added)
- The [`site` module][site] has most of the path etc. setup code that
  uses `sys.executable` (always an absolute path) to figure out to add
  the virtualenv's `lib/python3.5/site-packages/` path.



<!-------------------------------------------------------------------->
[site]: https://docs.python.org/3/library/site.html
[win]: https://github.com/0cjs/sedoc/blob/master/lang/python/runtime/win.md
[virtualenv]: https://github.com/0cjs/sedoc/blob/master/lang/python/runtime/virtualenv.md
