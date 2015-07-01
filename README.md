perl6-Dancer2
=======

Dancer2 provides an alternative to Bailador, in that I'm going to try to keep this as close to perl5 as reasonable, to make migration simpler.

Installation
============

* Using panda (a module management tool bundled with Rakudo Star):

```
    panda update && panda install Dancer2
```

* Using ufo (a project Makefile creation script bundled with Rakudo Star) and make:

```
    ufo                    
    make
    make test
    make install
```

## Testing

To run tests:

```
    prove -e perl6
```

## Author

Jeffrey Goff, DrForr on #perl6, https://github.com/drforr/

## License

Artistic License 2.0
