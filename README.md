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


## Installation

```
$ gem install hoe-debugging
```

You should also use your distro's package manager to install `gdb` and `valgrind`.


## License

MIT. See `LICENSE` file in this repository.
