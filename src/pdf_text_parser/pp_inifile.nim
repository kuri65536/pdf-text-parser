##[ pp_inifile.nim

the short and refactored version of a `ini` file parser from my
[configparser.nim](https://github.com/kuri65536/configparser.nim)

License: MIT, see LICENSE
]##
import logging
import streams
import strutils
import tables


type
  SectionTable* = Table[string, seq[tuple[opt, val: string]]]


  ParseResult = enum ## enumeration of all events that may occur when parsing
    opt_and_val,        ## end of file reached
    val_or_invalid,
    comment,
    in_empty,
    in_val,
    section,            ## a ``[section]`` has been parsed

  ParserStatus* = ref object of RootObj
    cur_state: ParseResult
    sections: Table[string, seq[tuple[opt, val: string]]]
    cur_section_name: string


const
    comment_chars = ['#', ';', ]


proc is_comment(ch: char): bool =
    return comment_chars.contains(ch)


proc is_comment_line(src: string): bool =
    ##[ check the `src` starts with comment characters
    ]##
    const whitespaces = " \t"
    for i, ch in src:
        if whitespaces.contains(ch):
            continue
        if is_comment(ch):
            return true
        return false
    return false


proc remove_comment(src: string, space: bool): string =
    var ret = ""
    var f_quote = false
    for i in src:
        if i == '#':
            break
        if f_quote:
            if i == '"':
                f_quote = false
        else:
            if i == '"':
                f_quote = true
        ret &= $i
    if space:
        ret = ret.strip()
    return ret


proc parse_section_line(line: string): string =
    var left = line.strip(leading = true)
    if not left.startsWith("["):
        return ""
    left = left[1..^1]
    var right = remove_comment(left, space = true)
    if not right.endswith("]"):
        return ""
    right = right[0..^2]

    let sec = right.strip(chars = {' '})
    return sec


proc parse_option_value(line: string
                        ): tuple[st: ParseResult, opt, val: string] =
    const splitter_opt_val = ["=", ]  # ":", ]
    var (f_opt, ) = (true, )

    if is_comment_line(line):
        return (comment, "", "")
    let sec = parse_section_line(line)
    if len(sec) > 0:
        return (section, "", sec)

    var (opt, val) = ("", "")
    for n, ch in line:
        if f_opt:
            if is_comment(ch):
                break
            if splitter_opt_val.contains($ch):
                (f_opt, opt) = (false, opt.strip())
            else:
                opt &= ch
            continue
        else:
            if is_comment(ch):
                break
            val &= $ch
    if f_opt and len(opt.strip()) < 1:
        return (in_empty, "", "")
    elif f_opt:
        return (val_or_invalid, "", opt)

    let val0 = val.strip()
    return (opt_and_val, opt, val0)


proc load_ini*(strm: Stream): SectionTable =
    ##[
        .. note:: todo ... the multiple value lines
    ]##
    var stat = ParserStatus()
    var prev = ""
    stat.sections[""] = @[]
    for line in strm.lines():
        let (st, opt, val) = parse_option_value(line)
        error("load_ini:line is:", $st, ", opt:", opt)
        case st:
        of section:
            stat.cur_section_name = val
            stat.sections[val] = @[]
        of opt_and_val:
            stat.sections[stat.cur_section_name].add((opt, val))
            prev = opt
        of val_or_invalid:
            if prev != "":
                let (pop, pvl) = stat.sections[stat.cur_section_name][^1]
                stat.sections[stat.cur_section_name][^1] = (pop, pvl & val)
        of comment:
            if prev != "":
                discard
        else:
            prev = ""
    return stat.sections

