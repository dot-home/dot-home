dot-home Tutorial
=================

Dot-home is careful not to overwrite files it did not install, so it's
quite safe to use regardless of what you currently have in your home
directory.

#### Initial Setup

The easiest way to get started is to use the `bootstrap-user` script, which
can be run directly from the web:

    $ curl -sfL https://raw.githubusercontent.com/dot-home/dot-home/main/bootstrap-user | bash
    dot-home bootstrap for user joe
    Reading https://raw.githubusercontent.com/dot-home/dot-home/main/dh/bootstrap-users
    Warning: cannot find user joe in https://raw.githubusercontent.com/dot-home/dot-home/main/dh/bootstrap-users
    Cloning dot-home from https://github.com/dot-home/dot-home
    Running dot-home-setup
    ===== Building files
    .home WARNING: Conflict: .home/_inb4/dot/bashrc
    ===== Running dh/setup scripts
    Test in a new window, or 'source ~/.bashrc'.
    $ 

(After doing this, you can see further information about what this script
does by running it with the -h parameter to see the help text:
`~/.home/dot-home/bootstrap-user -h`.)

You'll note two warnings here: that it cannot find your user name in the
`dh/bootstrap-users` file and that there's a conflict for `.bashrc`. These
are expected, and will be further explained below.

What this has done is created a `~/.home/dot-home` directory containing the
dot-home base module and run `dot-home-setup` from that module to do the
intial setup. At this point, the only thing it will have done is create
`~/.local/bin/` (if it doesn't already exist) and link the `dot-home-setup`
script back to `~/.home/dot-home/bin/dot-home-setup`:

    $ ls -l .local/bin/dot-home-setup
    lrwxrwxrwx 1 joe joe 39 Sep 29 21:51 .local/bin/dot-home-setup -> ../../.home/dot-home/bin/dot-home-setup

This is an example of how it installs files from `.home/<MODULE>/bin`
directories: any file in one of those directories has a symlink in your
path pointing to it.

#### Bringing Dot Files into Dot-Home

The message `.home WARNING: Conflict: .home/_inb4/dot/bashrc` indicates
that it wants to build a `~/.bashrc` from files in dot-home modules
(in this case, `~/.home/dot-home/dot/bashrc.inb1`) but there's an existing
`~/.bashrc` that it `dot-home-setup` won't overwrite because it did not
originally create that file.

To combine the code in that file with the `.bashrc` code from the
`dot-home` module, you need to create a new module containing that
code as a fragment to be combined:

    $ git init ~/.home/joe
    $ mkdir ~/.home/joe/dot
    $ mv ~/.bashrc ~/.home/joe/dot/bashrc.inb4
    $ ~/.local/bin/dot-home-setup
    ===== Building files
    ===== Running dh/setup scripts
    $ 

You'll note that here we gave an explicit path to `dot-home-setup`. You
may be able to simply type `dot-home-setup`, but whether that will work
depends on whether your default configuration includes `~/.local/bin/`
in your `$PATH` environment variable. Once you're using dot-home to build
your `~/.bashrc`, the `dot-home` module will be adding this to your path
so it will always work.

Now, if you look at your `~/.bashrc` you'll see that it's a symlink pointing
to the file generated by dot-home:

    $ ls -l ~/.bashrc
    lrwxrwxrwx 1 joe joe 22 Sep 29 22:35 /home/joe/.bashrc -> .home/_inb4/dot/bashrc

This file was generated by taking the contents of the files matching
`~/.home/*/dot/bashrc.inb[0-9]` and concatenating them all in order of
the number at the end (`*.inb0`, `*.inb1`, ..., `*.inb9`), giving:

    $ cat ~/.bashrc
    ##### This file was generated by inb4.

    ##### dot-home/dot/bashrc.inb1
    ...

    ##### joe/dot/bashrc.inb4
    ...

    ##### End of inb4 generated content.

This file is now under dot-home control and will be updated as you update
the modules (usually repositories) under `~/.home`.

To be able to distribute the `.bashrc` changes you're merging with the
`.bashrc` code in the dot-home module, you need to add and commit your
new `.bashrc` fragment and make it available elsewhere:

    $ cd ~/.home/joe
    $ git add dot/bashrc.inb4
    $ git commit
    ...
     create mode 100644 dot/bashrc.inb4
    #   Set up a repo on GitHub or anywhere else you like, and then
    #   add it as a remote here.
    $ git remote add origin https://github.com/joe/joe.git
    $ git push -u origin main
    $ 

#### Files Changed Outside of Dot-Home

Some programs may change the files generated by dot-home. These changes
will be detected and dot-home will refuse to overwrite them. Let's look
at an example.

    $ dot-home-setup
    ===== Building files
    ===== Running dh/setup scripts
    $ echo 'echo a change' >> ~/.bashrc
    $ dot-home-setup
    ===== Building files
    .home WARNING: dot/bashrc has been changed from version built by inb4
    ===== Running dh/setup scripts
    $ 

When this happens, you can examine the file to see what's been changed,
move the changes into one of your dot-home modules, and then regenerate the
file:

    $ cat ~/.bashrc
    ##### This file was generated by inb4.
    ...
    ##### End of inb4 generated content.
    echo a change
    $ vi ~/.bashrc ~/.home/joe/dot/bashrc.inb9
    #   In your editor, remove the change from the first file and add
    #   it to the second.
    $ dot-home-setup 
    ===== Building files
    ===== Running dh/setup scripts
    $ cat ~/.bashrc
    ##### This file was generated by inb4.
    ...

    ##### joe/dot/bashrc.inb9
    echo a change

    ##### End of inb4 generated content.

You'll of course want to commit the changes to your dot-home module.
