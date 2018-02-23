local mobile = true

local function builder()
    local b = _G.builder('apple')
    b.verbose = true
    if mobile then
        b.sdk = 'iphoneos'
        b.archs = {
            'armv7',
            'arm64',
        }
    else
        b.sdk = 'macosx'
    end
    b.defines = {
        HAVE_CONFIG_H = true,
    }
    b.compiler = 'gcc'
    b.build_dir = 'aite_build'
    function b:ar(obj)
        print(YELLOW('---> ')..GREEN(self.output))
        os.execute('ar cr '..self.output..' '..table.concat(obj, ' '))
        os.execute('ranlib '..self.output)
    end
    return b
end

function compat()
    local b = builder()
    b.include_dirs = {
        '.',
        'lib/compat',
    }
    b.src = {
        'lib/compat/empty.c',
        'lib/compat/md5.c',
        'lib/compat/obstack.c',
    }
    b.cflags = '-Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wno-tautological-constant-out-of-range-compare -Wmissing-declarations -Wmissing-format-attribute -Wformat -Wformat-security -Wsizeof-array-argument -Wpointer-arith -Wlogical-not-parentheses -Wswitch-bool -Wvla -Winit-self -Wwrite-strings -Wcast-align -Wshadow -Wshift-negative-value -Wnull-dereference -Wdeclaration-after-statement -Wnested-externs -Wbad-function-cast -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition'
    b.bin = 'libcompat.a'
    b:ar(b:compile())
end

function libdpkg()
    local b = builder()
    b.defines.LOCALEDIR = '"/usr/local/share/locale"'
    b.defines.CONFIGDIR = '"/usr/local/etc/dpkg"'
    b.defines.ADMINDIR = '"/usr/local/var/lib/dpkg"'
    b.defines.DEFAULT_TEXT_DOMAIN = '"dpkg"'

    --b.cflags = '-Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -Wno-tautological-constant-out-of-range-compare -Wmissing-declarations -Wmissing-format-attribute -Wformat -Wformat-security -Wsizeof-array-argument -Wpointer-arith -Wlogical-not-parentheses -Wswitch-bool -Wvla -Winit-self -Wwrite-strings -Wcast-align -Wshadow -Wshift-negative-value -Wnull-dereference -Wdeclaration-after-statement -Wnested-externs -Wbad-function-cast -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition'

    b.include_dirs = {
        '.',
        'lib/compat',
        'lib',
        'dep/liblzma/api',
    }

    b.src = {
        'lib/dpkg/ar.c',
        'lib/dpkg/arch.c',
        'lib/dpkg/atomic-file.c',
        'lib/dpkg/buffer.c',
        'lib/dpkg/c-ctype.c',
        'lib/dpkg/cleanup.c',
        'lib/dpkg/color.c',
        'lib/dpkg/command.c',
        'lib/dpkg/compress.c',
        'lib/dpkg/dbdir.c',
        'lib/dpkg/dbmodify.c',
        'lib/dpkg/deb-version.c',
        'lib/dpkg/debug.c',
        'lib/dpkg/depcon.c',
        'lib/dpkg/dir.c',
        'lib/dpkg/dump.c',
        'lib/dpkg/ehandle.c',
        'lib/dpkg/error.c',
        'lib/dpkg/fdio.c',
        'lib/dpkg/file.c',
        'lib/dpkg/fields.c',
        'lib/dpkg/glob.c',
        'lib/dpkg/i18n.c',
        'lib/dpkg/log.c',
        'lib/dpkg/mlib.c',
        'lib/dpkg/namevalue.c',
        'lib/dpkg/nfmalloc.c',
        'lib/dpkg/options.c',
        'lib/dpkg/options-parsers.c',
        'lib/dpkg/parse.c',
        'lib/dpkg/parsehelp.c',
        'lib/dpkg/path.c',
        'lib/dpkg/path-remove.c',
        'lib/dpkg/pkg.c',
        'lib/dpkg/pkg-db.c',
        'lib/dpkg/pkg-array.c',
        'lib/dpkg/pkg-format.c',
        'lib/dpkg/pkg-list.c',
        'lib/dpkg/pkg-namevalue.c',
        'lib/dpkg/pkg-queue.c',
        'lib/dpkg/pkg-show.c',
        'lib/dpkg/pkg-spec.c',
        'lib/dpkg/progname.c',
        'lib/dpkg/program.c',
        'lib/dpkg/progress.c',
        'lib/dpkg/report.c',
        'lib/dpkg/string.c',
        'lib/dpkg/strhash.c',
        'lib/dpkg/strwide.c',
        'lib/dpkg/subproc.c',
        'lib/dpkg/tarfn.c',
        'lib/dpkg/treewalk.c',
        'lib/dpkg/trigname.c',
        'lib/dpkg/trignote.c',
        'lib/dpkg/triglib.c',
        'lib/dpkg/trigdeferred.c',
        'lib/dpkg/utils.c',
        'lib/dpkg/varbuf.c',
        'lib/dpkg/version.c',
    }
    b.bin = 'libdpkg.a'
    b:ar(b:compile())
end

function dpkg_deb()
    local b = builder()
    b.defines.LOCALEDIR = '"/usr/local/share/locale"'
    b.bin = 'dpkg-deb.a'
    b:ar(b:compile())
end

function dpkg()
    local b = builder()
    b.defines.LOCALEDIR = '"/usr/local/share/locale"'
    b.defines.ADMINDIR = '"/usr/local/var/lib/dpkg"'

    b.include_dirs = {
        'lib/compat',
        '.',
        'lib',
        'src',
    }

    b.src = {
        'src/archives.c',
        'src/cleanup.c',
        'src/configure.c',
        'src/depcon.c',
        'src/enquiry.c',
        'src/errors.c',
        'src/filesdb.c',
        'src/filesdb-hash.c',
        'src/file-match.c',
        'src/filters.c',
        'src/infodb-access.c',
        'src/infodb-format.c',
        'src/infodb-upgrade.c',
        'src/divertdb.c',
        'src/statdb.c',
        'src/help.c',
        'src/main.c',
        'src/packages.c',
        'src/remove.c',
        'src/script.c',
        'src/select.c',
        'src/selinux.c',
        'src/trigproc.c',
        'src/unpack.c',
        'src/update.c',
        'src/verify.c',
    }

    b.bin = 'dpkg'
    local obj = b:compile()
    b:link(table.merge(
        obj,
        b.build_dir..'/libdpkg.a'
    ))
end
