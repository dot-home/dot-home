dot-home: Version-controlled Construction of Unix User Configuration
====================================================================

### Current State

This is still in the early design stages; both documentation and code
are woefully incomplete.

### Introduction

`dot-home` is a framework for version control, synchronization and
building of configuration and other files typically found in a home
directory.

Configuration and other information is stored in subdirectories under
`~/.home`; these subdirectories (which are typically checkouts of git
repos) are called "modules." The dot-home system itself is placed in
`~/.home/_dot-home`; it's the "master" repo that handles dealing with
the building and installation of material found in all the modules,
including itself.

Running `dh setup`, runs the symlinker
which goes through all the files in `~/.home/*/{bin,dot}` and
does the following.

For directories under `~/.home/*/bin` it creates a directory at the
same path under `~/bin`. For files it creates a symlink at the same
path under `~/bin` whose target is a relative path back to the file
under `~/.home`. However, files ending in `.inb[0-9]` are not linked.
(These are template files used to build new files.)

For directories in files under `~/.home/*/dot` the actions are the
same except that the path above is translated to `~/.`; i.e., the file
`~/.home/module/dot/foo/bar` will generate a symlink `~/.foo/bar`
pointing to it.

The modules and files within them are processed in lexical order with
the first directory or file encountered taking priority. Dangling
links created by the dot-home system will be removed before the new
link is created, but any other links, whether previously created by
this dot-home run or created from outside the dot-home system, will
generate a conflict warning and will be left untouched.
