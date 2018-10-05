# Igor
Igor is an Addon for RIFT

## Getting Started

    /igor -help                                 prints help
    /igor dump <dumpparams> <target>            prints lua globals
    where dumpparams is any mix of
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
    /igor dumpall md
    prints the entire doc set to the console using #markdown.
    
# Using dumpall
Dumpall is intended to be used to create your own copy of the full RIFT API documentation for any version of RIFT.

From within rift execute the following commands, waiting for igor to finish writing out before the final `/log`.

    /log
    /igor dumpall md
    /log

Your ~/Documents/RIFT folder should now contain a log.txt with minimal processing can be saved as a valid markdown file.
It is very long - cutting it up into section or function sized chunks is an exercise left to the reader :)
    
# Using list and doc
List and doc are a way, in RIFT, to search the available documentation, and show a doc for a specific documentation entry.

    /igor list .
    /igor list ^UI%.
    
Using list with no parameters will show help. Pass just a period and igor will list the entire doc set.
You can get a filtered list by passing a lua pattern. lua string patterns are similar to regex but differ in some ways. The above pattern will show a filtered list of documentation for items that start with "UI.".

doc just shows the documentable.readable entry for a specific item and the name simply has to match and is case senstive.

    /igor doc UI.Context

# Using dump
I expect to change this function a lot.

The purpose of dump is to dump to console the entries of a named Lua global variable.
It is very similar to the provided `dump` function, so the following two commands are largely similar

    /script dump(UI.Context)
    /igor dump v r p UI.Context

# Built in stuff
RIFT actually has some interesting lua related debugging features built in.

Slash command script can be passed a lua expression that it will run. If you want to see output you need to use print().

    /script print(1+2)

Global function dump() is also added. Pass it an list of in scope objects (probably global) and it will emit them to the console. Being a lua function it can be paired with `/script` to be useful from the console window

    /script dump(UI.Context,UI.CreateFrame)
