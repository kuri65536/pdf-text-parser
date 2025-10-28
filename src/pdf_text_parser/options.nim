##[ options.nim

License: MIT, see LICENSE
]##
import logging
import std/paths
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


proc usage(): void =
    const project_name = "pdf-text-parser"
    const prg = project_name
    const pfx = "  "
    echo(prg & ": extract the TOC and modify pdf outlines")
    echo(pfx & "usage: " & prg & " [options] [file1] [file2] ...")
    echo(pfx & "options: ")
    echo(pfx & "  --output or -o [file]   ... specify the output file name")
    echo(pfx & "  --rules  or -r [file]   ... specify the rules file")


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
        let ret = pp_rulesfile.load(i)
        if len(ret) < 1: continue
        result.add(ret)


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
        ('r', "--rules", "", parse_rules, rules),
        ('o', "--output", "", parse_outname, outname),
    )
    if len(ret.rules) < 1:
        echo("can't load the rules file."); return error(2)
    ret.filenames = check_files(prms[""])
    if len(ret.filenames) < 1:
        return error(3)
    return ret

