##[ pdf_text_parser.nim

License: MIT, see LICENSE
]##
import logging
import os
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
    for filename in opts.filenames:
        debug("main: extract 1 PDF " & filename.string)
        let blks = app_extract.extract_blocks(opts.rules, filename)
        let blk2 = app_parse.parse(opts.rules, blks)
        app_format.format(blk2)


when isMainModule:
    var args: seq[string] = @[]
    for i in 1..os.paramCount():
        args.add(os.paramStr(i))
    system.quit(main(args))

