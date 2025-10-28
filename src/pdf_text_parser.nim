##[ pdf_text_parser.nim

License: MIT, see LICENSE
]##
import os
import system

import pdf_text_parser/app_extract
import pdf_text_parser/app_format
import pdf_text_parser/options


proc main(args: seq[string]): int =
    let opts = options(args)
    if opts.n_quit != 0:
        return opts.n_quit
    for filename in opts.filenames:
        let blks = app_extract.extract_blocks(opts.rules, filename)
        app_format.format(blks)


when isMainModule:
    var args: seq[string] = @[]
    for i in 1..os.paramCount():
        args.add(os.paramStr(i))
    system.quit(main(args))

