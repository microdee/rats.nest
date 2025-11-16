--[[                      /@@             
                         | @@             
      /@@@@@@  /@@@@@@  /@@@@@@   /@@@@@@@
     /@@__  @@|____  @@|_  @@_/  /@@_____/
    | @@  \__/ /@@@@@@@  | @@   |  @@@@@@ 
    | @@      /@@__  @@  | @@ /@@\____  @@
    | @@     |  @@@@@@@  |  @@@@//@@@@@@@/
    |__/      \_______/   \___/ |_______/ 
    yet another C++ framework for creative coding probably.
    
    # The rats project model

    A rats project is a collection of so called "rats packs" or just packs for short. Packs are
    folders with one `xmake.lua` build script describing what exactly that pack should build.
    They can depend on each other, but no assumptions should be made about them outside of their
    dependency graph. In English that means the root project (this file) for example should not
    have any explicit knowledge about what packs are available and what they might bring to the
    table, as they're discovered automatically.

    ## Rats packs

    As mentioned a pack is defined at least with a subfolder inside `packs` and an `xmake.lua` file.
    All the amenities available what XMake can offer, but rats provides some extra features on top
    of that.

    ### Namespacing

    The folder hierarchy starting at the `packs` folder implicitly defines a namespace for the
    packs. So a pack contained in `/packs/rats/core/app` will reside in `rats.core` namespace
    (`rats.core.app` will be its fully qualified name). This is expressed for XMake with the API
    defined in `/_build/xmake/namespaces.lua`.

    Namespaces allows us to have compartmentalized build configurations as well in the form of
    `_build` subfolders containing `*.lua` files. Namespace inference from folder structure stops
    at these `_build` folders. So a script can provide common configuration to everything inside
    `rats.core` namespace if it is placed in `/packs/rats/core/_build` folder and uses the
    namespace API.

    ## Intended usage

    Clone / fork the rats::nest repository and organize your project in the packs folder as its own
    collection of packs in `packs/<my_project>` folder.

    ## Why XMake? Why not CMake? Or why not __blank__?

    First I have considered CMake and I made the same kind of "rats packs" architecture with it.
    That implementation was pretty comfortable to use, as comfortable as CMake can get, however
    XMake advertises some features which can reduce boilerplate significantly, without imparing
    the freedom CMake provides, like

    * Support for multiplé package managers, including their own which also provides dependency
      management
    * Support for multiple languages and their package managers (Rust + Cargo for example)
    * Handholding for cross-compiling

    All of which I found painful to handle in CMake or alternatives.

    # License

    Mozilla Public License Version 2.0
    See text in LICENSE file.
]]

set_project("rats")

includes("config.lua")

set_version("0.0.1")

includes("_build/xmake/rats/**.lua")
includes("packs/**/_build/**.lua")
includes("packs/**/*.xm.lua")