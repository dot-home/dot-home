dot-home: Version-controlled Construction of Unix User Configuration
====================================================================

### Introduction

`dot-home` is a framework for version control, synchronization and
building of configuration and other files typically found in a `$HOME`
(often written `~`) directory.

Configuration and other information is stored in subdirectories under
`~/.home`; these subdirectories (which are usually working copies of
git repos) are called "modules." The dot-home system itself is placed
in `~/.home/dot-home`; it's the "master" module that handles dealing
with the building, installation and management of material found in
all the modules, including itself.

The setup script, `dot-home/bin/dot-home-setup`, runs the symlinker
which goes through all the files in `~/.home/*/{bin,dot}` and does the
following.

For directories under `~/.home/*/bin/` and `~/.home/*/share` it creates
a directory at the same path under `~/.local/bin/` or `~/.local/share`.
For files it creates a symlink at the same path under the same directory
whose target is a relative path back to the file under `~/.home`.
However, files ending in `.inb[0-9]` are not linked. (These are template
files used to build new files.)

For directories and files under `~/.home/*/dot/` the actions are the
same except that the path above is translated to `~/.`; i.e., the file
`~/.home/module/dot/foo/bar` will generate a symlink `~/.foo/bar`
pointing to it.

The modules and files within them are processed in lexical order with
the first directory or file encountered taking priority. Dangling
links created by the dot-home system will be removed before the new
link is created, but any other links, whether previously created by
this dot-home run or created from outside the dot-home system, will
generate a conflict warning and will be left untouched.


Usage of `~/.local/`
--------------------

`dot-home` opines that you should have `$HOME/.local/bin/` directory in
your path. This is an XDG standard (see below) and many, but not all, Linux
distributions do this automatically. The only user configuration included
in the `dot-home` repo itself is a `prepath()` function to cleanly
manipulate `$PATH` and an early addition of `~/.local/bin` to the front of
`$PATH`. These are in `dot/bashrc.inb1`, allowing the user to modify either
of these before or after this is run.

#### History of `~/.local/`

The idea of a `~/.local` directory with a structure parallel to
`/usr/local` (and by implication, `/usr`) may have originated with the
[XDG Base Directory Specification][xdg-base], which specifies that
`$XDG_DATA_HOME` defaults to `$HOME/.local/share`. The general idea
has since been adopted by other systems, including:

* Python: the [per-user site packages directory][py-PEP-370] is
  `~/.local`. (2008-01; v2.6+, v3.0+)
* Ubuntu 16.04: the default profile given to new users,
  `/etc/skel/.profile`, adds `$HOME/.local/bin` to the path. (2016-04)



[xdg-base]: https://specifications.freedesktop.org/basedir-spec/basedir-spec-0.6.html
[py-PEP-370]: https://www.python.org/dev/peps/pep-0370/
[py-userbase]: https://docs.python.org/2/library/site.html#site.USER_BASE
