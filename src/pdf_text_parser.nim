##[ pdf_text_parser.nim

License: MIT, see LICENSE
]##
import logging
import os
import std/paths
import std/streams
import system

import pdf_text_parser/app_convert
import pdf_text_parser/app_extract
import pdf_text_parser/app_output
import pdf_text_parser/options


proc main(args: seq[string]): int =
    let opts = options(args)
    if opts.n_quit != 0:
        return opts.n_quit
    info("main: loop over " & $len(opts.filenames))

    let strm = openFileStream("/dev/stdout", fmWrite)
    defer: strm.close()

    proc proc1(filename: Path, outs: set[output_options]): void =
        debug("main: extract 1 PDF " & filename.string)
        let blks = app_extract.extract_blocks(opts.rules, filename)
        let blk2 = app_convert.parse(opts.rules, blks)
        app_output.output(strm, opts.rules, blk2, outs)

    if len(opts.filenames) < 1:
        return 1
    if len(opts.filenames) < 2:
        proc1(opts.filenames[0], {})
        return 0

    proc1(opts.filenames[0], {output_head})
    for i in opts.filenames[1 ..^  2]:
        proc1(i, {output_inter})
    proc1(opts.filenames[^1], {output_tail})
    return 0


when isMainModule:
    var args: seq[string] = @[]
    for i in 1..os.paramCount():
        args.add(os.paramStr(i))
    system.quit(main(args))

