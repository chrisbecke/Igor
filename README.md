# Igor
Igor is an Addon for RIFT

## Getting Started

/igor -help                                 prints help
/igor dump <dumpparams> <target>            prints lua globals
where dumpparams is any mix of
    md - wrap output with markdown friendly syntax
    values - show the values of each enumerated member
    recurse - enumerate into tables
    path - print members with the full root relative name
    meta - if the target has a metatable, with a valid __index, recurse against that.
and target is a valid lua global
/igor list [<pattern>]                      searches documentation
where pattern is a lua style matching pattern.
lists the names of Inspector Documentation entries that match the pattern.
/igor doc <docname>                         shows a documentation entry
where docname is the name of an Inspector Documentation entry
prints the full human readable doc of the entry to the console