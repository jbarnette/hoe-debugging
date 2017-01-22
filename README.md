# hoe-debugging

* http://github.com/jbarnette/hoe-debugging


## Description

A Hoe plugin to help you debug your C extensions. This plugin provides `test:gdb` and `test:valgrind` tasks (plus a few variants).

See the `Hoe::Debugging` module for a few configuration options.

This plugin expects you to have `gdb` and `valgrind` available in your `PATH`.


## Examples

```
# in your Rakefile
Hoe.plugin :debugging

# in your shell
$ rake test:gdb
$ rake test:valgrind

# if you've got valgrind warnings you've deemed OK to suppress
$ rake test:valgrind:suppression
$ rake test:valgrind # this runs, suppressing the errors previously emitted by valgrind
```


## Installation

```
$ gem install hoe-debugging
```

You should also use your distro's package manager to install `gdb` and `valgrind`.


## License

MIT. See `LICENSE` file in this repository.
