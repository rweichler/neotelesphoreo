-- this is what is called when you run `aite`.
function default()
    if not(jit.os == 'OSX') then
        error('You need to be on a Mac. Sorry.')
    end
    download()
    run_autotools()
    compile()
    link()
    print(CYAN('IT WORKED!!!! YAY! Your binary is in ')..GREEN('aite_build/bash')..CYAN('.'))
end

-- Here be dragons. I wouldn't try to understand this code.
-- If you *really* want to try to understand this, a high level
-- description is:
--      Download bash
--      Compile it for Mac (so it generates everything we need)
--      Cross compile it for iOS using our own build system
-- TODO: cut all of this down to < 50 LOC

local mobile = true

local function builder()
    local b = _G.builder('apple')
    if mobile then
        b.sdk = 'iphoneos'
        b.archs = {
            'armv7',
            'arm64',
        }
    end
    b.defines = {
        HAVE_CONFIG_H = true,
        SHELL = true,
        MACOSX = true,
    }
    b.compiler = 'clang'
    b.build_dir = 'aite_build'
    b.cflags = '-Wno-implicit-function-declaration -g -O2 -Wno-parentheses -Wno-format-security -mios-version-min=7.0'
    function b:ar(obj)
        print(YELLOW('---> ')..GREEN(self.build_dir..'/'..self.output))
        os.execute('ar cr '..self.build_dir..'/'..self.output..' '..table.concat(obj, ' '))
        os.execute('ranlib '..self.build_dir..'/'..self.output)
    end
    return b
end

local prefix = '/usr/local'
local libdir = prefix..'/lib'
local localedir = prefix..'/share/locale'

function intl()
    local b = builder()
    b.defines = table.merge(b.defines, {
        LOCALEDIR = '"'..localedir..'"',
        LOCALE_ALIAS_PATH = '"'..localedir..'"',
        LIBDIR = '"/usr/local/libdata"',
        IN_LIBINTL = true,
        ENABLE_RELOCATABLE = 1,
        IN_LIBRARY = true,
        INSTALLDIR = libdir,
        NO_XMALLOC = true,
        set_relocation_prefix = 'libitnl_set_relocation_prefix',
        relocate = 'libitnl_relocate',
        DEPENDS_ON_LIBICONV = 1,
    })
    b.include_dirs = {
        'bash-4.4/lib/intl',
        'bash-4.4',
    }
    b.src = fs.scandir('bash-4.4/lib/intl/*.c')
    table.removecontents(b.src, 'bash-4.4/lib/intl/os2compat.c')
    b.output = 'libintl.a'
    b:ar(b:compile())
end

function termcap()
    local b = builder()
    b.include_dirs = {
        'bash-4.4/lib/termcap',
        'bash-4.4',
    }
    b.src = fs.scandir('bash-4.4/lib/termcap/*.c')
    b.output = 'libtermcap.a'
    b:ar(b:compile())
end

function readline()
    local b = builder()
    b.include_dirs = {
        'bash-4.4/lib/readline',
        'bash-4.4/lib/termcap',
        'bash-4.4',
        'bash-4.4/lib',
    }
    b.src = fs.scandir('bash-4.4/lib/readline/*.c')
    table.removecontents(b.src, {
        'bash-4.4/lib/readline/emacs_keymap.c',
        'bash-4.4/lib/readline/vi_keymap.c',
    })
    b.output = 'libreadline.a'
    b:ar(b:compile())
end

function bash()
    local b = builder()
    b.defines = table.merge(b.defines, {
        PROGRAM = '"bash"',
        CONF_HOSTTYPE = '"x86_64"',
        CONF_OSTYPE = '"darwin15.6.0"',
        CONF_MACHTYPE = '"x86_64-apple-darwin15.6.0"',
        CONF_VENDOR = '"apple"',
        LOCALEDIR = '"/usr/local/share/locale"',
        PACKAGE = '"bash"',
    })
    b.include_dirs = {
        'bash-4.4',
        'bash-4.4/include',
        'bash-4.4/lib',
        'bash-4.4/lib/intl',
    }
    b.src = fs.scandir('bash-4.4/*.c')
    table.removecontents(b.src, 'bash-4.4/mksyntax.c')
    b.output = 'libbash.a'
    b:ar(b:compile())
end

function builtins()
    local b = builder()
    b.include_dirs = {
        'bash-4.4/builtins',
        'bash-4.4',
        'bash-4.4/include',
        'bash-4.4/lib',
        'bash-4.4/lib/intl',
    }
    local defs = fs.scandir('bash-4.4/builtins/*.def')
    for i,v in ipairs(defs) do
        os.execute('cd bash-4.4/builtins && ./mkbuiltins -D . ../../'..v)
    end
    b.src = fs.scandir('bash-4.4/builtins/*.c')
    table.removecontents(b.src, 'bash-4.4/builtins/inlib.c')
    table.removecontents(b.src, 'bash-4.4/builtins/gen-helpfiles.c')
    table.removecontents(b.src, 'bash-4.4/builtins/mkbuiltins.c')
    b.output = 'libbuiltins.a'
    b:ar(b:compile())
end

function glob()
    local b = builder()
    b.include_dirs = {
        'bash-4.4/lib/glob',
        'bash-4.4',
        'bash-4.4/include',
        'bash-4.4/lib',
    }
    b.src = fs.scandir('bash-4.4/lib/glob/*.c')
    table.removecontents(b.src, 'bash-4.4/lib/glob/glob_loop.c')
    table.removecontents(b.src, 'bash-4.4/lib/glob/sm_loop.c')
    b.output = 'libglob.a'
    b:ar(b:compile())
end

function sh()
    local b = builder()
    b.include_dirs = {
        'bash-4.4/lib/sh',
        'bash-4.4',
        'bash-4.4/lib',
        'bash-4.4/include',
        'bash-4.4/lib/intl',
    }
    b.src = fs.scandir('bash-4.4/lib/sh/*.c')
    b.output = 'libsh.a'
    b:ar(b:compile())
end

function tilde()
    local b = builder()
    b.include_dirs = {
        'bash-4.4/lib/tilde',
        'bash-4.4',
        'bash-4.4/include',
        'bash-4.4/lib',
    }
    b.src = 'bash-4.4/lib/tilde/tilde.c'
    b.output = 'libtilde.a'
    b:ar(b:compile())
end

function download()
    if fs.isdir('bash-4.4') then return end

    fs.mkdir(builder().build_dir)
    local out = builder().build_dir..'/bash-4.4.tar.gz'

    print(CYAN('Downloading GNU bash'))
    os.execute('curl -L -f http://mirrors.syringanetworks.net/gnu/bash/bash-4.4.tar.gz -o '..out)
    print(CYAN('Extracting GNU bash'))
    os.execute('tar xf '..out)
end

function run_autotools()
    if fs.isfile('bash-4.4/bash') then return end

    print(CYAN('running autotools *throws up in mouth*'))
    os.execute('cd bash-4.4 && ./configure')
    print(CYAN('running make *slightly gags*'))
    os.execute('cd bash-4.4 && make')
end

function compile()
    print(CYAN('compiling for iOS with aite *sighs in relief*'))
    local libs = {
        'intl',
        'readline',
        'termcap',
        'bash',
        'builtins',
        'glob',
        'sh',
        'tilde',
    }
    for i,v in ipairs(libs) do
        print(YELLOW(v))
        _G[v]()
    end
end

function link()
    local b = builder()
    print(CYAN('linking *slightly gags again*'))
    assert(os.pexecute('clang -isysroot "'..b.sdk_path..'" -arch armv7 -arch arm64 -mios-version-min=7.0 '..b.build_dir..'/*.a -liconv -o '..b.build_dir..'/bash') == 0, 'linking failed')
    assert(os.pexecute('ldid -S '..b.build_dir..'/bash') == 0, 'signing failed')
end

function clean()
    os.pexecute('rm -rf '..builder().build_dir)
    os.pexecute('rm -rf bash-4.4')
end
