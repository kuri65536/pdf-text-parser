##[ pdf_text_parser.nim

License: MIT, see LICENSE
]##
import logging
import os
import std/paths
import system

import pdf_text_parser/app_extract
import pdf_text_parser/app_format
import pdf_text_parser/app_parse
import pdf_text_parser/options


proc main(args: seq[string]): int =
    let opts = options(args)
    if opts.n_quit != 0:
        return opts.n_quit
    info("main: loop over " & $len(opts.filenames))

    proc proc1(filename: Path, f_head, f_tail: bool): void =
        debug("main: extract 1 PDF " & filename.string)
        let blks = app_extract.extract_blocks(opts.rules, filename)
        let blk2 = app_parse.parse(opts.rules, blks)
        app_format.format(opts.rules, blk2, f_head, f_tail)

    if len(opts.filenames) < 1:
        return 1
    if len(opts.filenames) < 2:
        proc1(opts.filenames[0], true, true)
        return 0

    proc1(opts.filenames[0], true, false)
    for i in opts.filenames[1 ..^  2]:
        proc1(i, false, false)
    proc1(opts.filenames[^1], false, true)
    return 0


when isMainModule:
    var args: seq[string] = @[]
    for i in 1..os.paramCount():
        args.add(os.paramStr(i))
    system.quit(main(args))

