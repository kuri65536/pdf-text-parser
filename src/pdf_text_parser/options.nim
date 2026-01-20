##[ options.nim

License: MIT, see LICENSE
]##
import logging
import std/paths
import strutils
import tables

import options_macro
import pp_rulesfile
import pp_rules


type
  Options* = ref object of RootObj
    filenames*: seq[Path]
    n_quit*: int
    outname*: Path
    rules*: seq[pp_rules.Rule]
    verbosity: logging.Level


proc usage(): void =
    const project_name = "pdf-text-parser"
    const prg = project_name
    const pfx = "  "
    proc lv1(src: string): void =
        echo(pfx & src)
    proc lv2(src: string): void =
        echo(pfx & pfx & src)
    echo(prg & ": extract the TOC and modify pdf outlines")
    lv1("usage: " & prg & " [options] [file1] [file2] ...")
    lv1("options: ")
    lv2("--output or -o [file]   ... specify the output file name")
    lv2("--rules  or -r [file]   ... specify the rules file")
    lv2("--verbosity  or -V [number] ... the debug output level " &
                                                  "(0-6: none to all)")


proc parse_outname(args: seq[string]): Path =
    ##[ gets the specified output name
    ]##
    if len(args) < 1 or len(args[0]) < 1:
        return Path("/dev/stdout")
    assert len(args) < 2, $args
    result = Path(args[0])


proc parse_rules(args: seq[string]): seq[pp_rules.Rule] =
    ##[ load the rule files.
    ]##
    result = @[]
    for i in args:
        let (path, sec) = pp_rulesfile.split_name_and_section(i)
        if len(path.string) < 1:
            error("option:rules: rules file does not exist: " & i)
            continue
        let ret = pp_rulesfile.load(path, sec)
        if len(ret.name) < 1: continue
        result.add(ret)


proc parse_verbosity(args: seq[string]): logging.Level =
    ##[ sets the verbosity as log-level.
    ]##
    var ret: logging.Level

    proc set_level(lvl: Level): void =
        logging.setLogFilter(lvl)
        warn("option:verbosity: set the log-level to " & $lvl)
        ret = lvl

    for i in args:
        let tmp = i.strip()
        block letter:
            let lvl = case tmp.toLower():
                      of "all":    Level.lvlAll
                      of "debug":  Level.lvlDebug
                      of "info":   Level.lvlDebug
                      of "notice": Level.lvlNotice
                      of "warn":   Level.lvlWarn
                      of "error":  Level.lvlError
                      of "fatal":  Level.lvlFatal
                      of "none":   Level.lvlNone
                      else:        break letter
            set_level(lvl); continue
        block number:
            let n = try:               parseInt(tmp)
                    except ValueError: break number
            let lvl = case n:
                      of 6: Level.lvlAll
                      of 5: Level.lvlDebug
                      of 4: Level.lvlNotice
                      of 3: Level.lvlWarn
                      of 2: Level.lvlError
                      of 1: Level.lvlFatal
                      of 0: Level.lvlNone
                      else: break number
            set_level(lvl); continue
    return ret


func check_files(args: seq[string]): seq[Path] =
    ##[ gets the specified input files
    ]##
    result = @[]
    for i in args:
        result.add(Path(i))


proc options*(args: seq[string]): Options =
    ##[ parses the command line options.
    ]##
    logging.addHandler(logging.newConsoleLogger())
    logging.setLogFilter(lvlNotice)

    let ret = Options(n_quit: 0,
                      )

    proc error(n: int): Options =
        usage()
        ret.n_quit = n
        return ret

    if len(args) < 1:
        return error(1)
    options_macro.parse_all(ret, args,
        ('V', "--verbose", "", parse_verbosity, verbosity),
        ('r', "--rules", "", parse_rules, rules),
        ('o', "--output", "", parse_outname, outname),
    )
    if len(ret.rules) < 1:
        echo("can't load the rules file."); return error(2)
    ret.filenames = check_files(prms[""])
    if len(ret.filenames) < 1:
        return error(3)
    return ret

