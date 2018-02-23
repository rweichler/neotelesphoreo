# Telesphoreo

An attempt at reviving saurik's Telesphoreo project. Huge WIP.

Right now this project is in the "find out what's even possible" stage. The only thing in this repo is GNU bash. The compile script [is currently a mess](https://github.com/rweichler/neotelesphoreo/blob/master/formula/bash/how2build.lua). The eventual goal is to make it look as nice and short as a [machomebrew forumla script](https://github.com/Homebrew/homebrew-core/blob/master/Formula/bash.rb).

The choice of GNU bash mostly comes from its difficulty to port to other platforms. I figure once we figure out bash, then everything else should fall into place pretty easily.

# How to cross-compile GNU bash for iOS

* Be on a Mac (sorry)
* Install the Xcode toolchain
* Install LuaJIT (Either run `brew install luajit`, or, if you don't have homebrew, download [the LuaJIT source](http://luajit.org/download.html) and install it using [these instructions](http://luajit.org/install.html))
* `git clone https://github.com/rweichler/aite`
* `git clone https://github.com/rweichler/neotelesphoreo`
* `cd neotelesphoreo/formula/bash`
* `luajit ../../../aite/main.lua update`
* `luajit ../../../aite/main.lua`


# Resources

Here's some stuff to put this repo into context:

* [saurik's initial motivations behind Telesphoreo](http://www.saurik.com/id/1)
* [Interview with Mike McQuaid (lead maintainer of machomebrew)](https://manifest.fm/1)

> **saurik:** my main concern about machomebrew, a "main concern" that also applies to fink/macports, is to maintain compatibility with the existing package set, both in the specifics of package dependencies and selection as well as the generalities of overall goal and focus
>
> **saurik:** fwiw, homebrew had (and mostly still "has") the incorrect (even "naive", as they failed to learn from their predecessors) goal of depending entirely on the underlying system whenever possible. but apple's underlying system has no interest in maintaining library backwards compatibility nor does it ship with good versions of any packages (apple ships what they do because "we need to ship SOMETHING" and "but we should avoid the good stuff for license reasons")
>
> **saurik:** on ios these concerns are even stronger, given that the underlying library set is something apple doesn't even think anyone has any legitimate reason to be using, so they have been pretty brutal with compatibility. and they also don't really ship anything. and they certainly barely ship any underlying utilities. so the premise of homebrew essentially falls apart: there's no stable underlying base on which to build some second overlay universe of packages
>
> **saurik:** so the goal was to build, using the good packages (as even a fifteen year old version of GNU coreutils is better than a one minute old version of the BSD equivalents), an underlying base that felt as powerful as a linux distribution, with the kind of full-blown package manager capable of supporting that environment. I have never for one minute been unhappy with my choice of dpkg
