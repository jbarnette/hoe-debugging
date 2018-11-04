# hoe-debugging

* http://github.com/jbarnette/hoe-debugging


## Description

A Hoe plugin to help you debug your C extensions. This plugin provides `test:gdb` and `test:valgrind` tasks (plus a few variants). As of v1.5 it also can generate a valgrind suppression from a previous test suite's log file.

See the `Hoe::Debugging` module for a few configuration options.

This plugin expects you to have `gdb` and `valgrind` available in your `PATH`.


## Summary

In your Rakefile:

``` ruby
Hoe.plugin :debugging
```

Then you'll get the following rake tasks:

```
rake test:valgrind               # debugging # Run the test suite under Valgrind
rake test:valgrind:mem           # debugging # Run the test suite under Valgrind with memory-fill
rake test:valgrind:mem0          # debugging # Run the test suite under Valgrind with memory-zero
rake test:valgrind:suppression   # debugging # Generate a valgrind suppression file for your test suite
rake valgrind:suppression[file]  # debugging # Generate a valgrind suppression file from a previous run's log file
```


## Examples

Run your test suite under gdb:

``` sh
rake test:gdb
```

Run your test suite with valgrind's memcheck:

``` sh
rake test:valgrind
```

If you have repeatable valgrind warnings that you've decided it's OK to suppress:

``` sh
rake test:valgrind:suppression
rake test:valgrind # when this runs, the previous run's errors will be suppressed
```

If you have a log file containing hard-to-reproduce valgrind warnings (e.g., from CI) that you've decided it's OK to suppress:

``` sh
rake valgrind:suppression[path/to/file]
rake test:valgrind # when this runs, the errors from that log file will be suppressed
```


## Suppression files

Suppression files can be added to the `suppressions` subdirectory of your project.

As of v2.0.0, `hoe-debugging` will use all suppression files that match any part of your Ruby's version. It uses the Hoe project name and the ruby version name, with an optional trailing `/_.*/`.

For example, if:

* my Hoe project was named `myproject`
* and my Ruby version was `2.5.1.57` (the `57` is `RUBY_PATCHLEVEL`)

then the following would be found and used:

* `suppressions/myproject_ruby-2.5.1.57.supp`
* `suppressions/myproject_ruby-2.5.1.57_namespace_deref.supp`
* `suppressions/myproject_ruby-2.5.1.supp`
* `suppressions/myproject_ruby-2.5.supp`
* `suppressions/myproject_ruby-2.supp`
* `suppressions/myproject_ruby-2_exit_frees.supp`

and the following would **not** be used:

* `suppressions/otherproject_ruby-2.5.1.57.supp` because the project name is wrong
* `suppressions/myproject_ruby-2.5.1.58.supp` because the patchlevel is wrong
* `suppressions/myproject_ruby-2.5.2.supp` because the patch is wrong
* `suppressions/myproject_ruby-2.4.supp` because the minor is wrong
* `suppressions/myproject_ruby-1.supp` because the major is wrong


## Installation

```
$ gem install hoe-debugging
```

You should also use your distro's package manager to install `gdb` and `valgrind`.


## License

MIT. See `LICENSE` file in this repository.
