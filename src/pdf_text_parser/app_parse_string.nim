##[ app_parse_string.nim

License: MIT, see LICENSE
]##
import logging
import re
import strutils


proc is_replace_format(fmt: string): tuple[f, g: bool, pat, rep: string] =
    ##[ parses the format as the replacement pattern.
    ]##
    const fallback1 = (false, false, "", "")
    let pfx = fmt[0]
    debug("parse:string:is_replace_format: " & fmt & ", prefix is " & $pfx)
    if not ['/', '#', '%'].contains(pfx):
        return fallback1
    let n_rep = if fmt.endsWith(pfx):         2
                elif fmt.endsWith(pfx & "g"): 3
                else: 0
    debug("parse:string:is_replace_format: suffix is type #" & $n_rep)
    if n_rep == 0:
        return fallback1
    debug("parse:string:is_replace_format: input is " & fmt[1 ..^ n_rep])
    var (pat, rep, f_rep, f_esc) = ("", "", false, false)
    for n, ch in fmt[1 ..^ n_rep]:
        if f_esc and ch == pfx:
            if f_rep: rep &= pfx
            else:     pat &= pfx
            f_esc = false; continue
        if not f_rep:
            if f_esc:
                (f_esc, f_rep, rep) = (false, true, $ch)
            elif ch == pfx:
                f_esc = true
            else:
                pat &= ch
        else:
            if f_esc:
                error("parse:replace:4: found the invalid format, " &
                      "extra separators ..." & fmt)
                return fallback1
            elif ch == pfx:
                debug("parse:check:5: " & pat & ", " & rep)
                f_esc = true
            else:
                rep &= ch
    debug("parse:string:is_replace_format: result '" & pat & "'-'" & rep & "'")
    return (true, n_rep == 3, pat, rep)


proc parse_replace(src: string, pat, rep: string, f_rep: bool): string =
    ##[ applies the replacement to string.
    ]##
    let rex = re.re(pat)
    let tmp = block:
        if f_rep:
            re.replace(src, rex, rep)
        else:
            let tmp2 = re.findAll(src, rex)
            if len(tmp2) < 1:
                src
            else:
                let tmp3 = strutils.split(src, tmp2[0])
                if len(tmp3) < 2:
                    src
                else:
                    tmp3[0] & rep & strutils.join(tmp3[1 ..^ 1], tmp2[0])
    debug("parse:string:replace '" & pat & "' with '" & rep & "'->" & tmp)
    return tmp


proc parse_single(tmp: seq[string], src: string): string =
    ##[ choose the "%s" content from an input string.
    ]##
    proc failed(): string =
        warn("can't parse the input '" & src & "' with " & $tmp)
        return ""

    if tmp[0] == "":
        if src.endsWith(tmp[1]):
            try:
                return src[0 ..^ len(tmp[1]) + 1]
            except IndexDefect:
                discard
        return failed()
    elif tmp[1] == "":
        if src.startsWith(tmp[0]):
            try:
                return src[len(tmp[0]) ..^ 1]
            except IndexDefect:
                discard
        return failed()
    if not src.startsWith(tmp[0]) or
       not src.endsWith(tmp[1]):
        return failed()
    try:
        return src[len(tmp[0]) ..^ len(tmp[1]) + 1]
    except IndexDefect:
        discard
    return src


proc parse*(fmt, src: string): string =
    ##[ parse an extracted text `src` as string with the format `fmt` .

        - `ABCDE%s` ... output exclude ABCDE
        - `%sFGHIJ` ... output exclude FGHIJ
        - `KL%sMNO` ... output exclude KL and MNO
        - `%abc%def%g` ... replace `abc` to `def`
    ]##
    let fmt = fmt.strip()
    if fmt == "%s" or len(fmt) < 1:
        return src
    let (is_replace, rp_flag, rp_pat, rp_rep) = is_replace_format(fmt)
    if is_replace:
        return parse_replace(src, rp_pat, rp_rep, rp_flag)
    if not fmt.contains("%s"):
        error("parse:parse: ignored the format ... " & fmt)
        return src

    let tmp = fmt.split("%s")
    if len(tmp) <= 2:
        return parse_single(tmp, src)
    error("parse:parse: ignored multiple %s, not supported ... " & fmt)
    return src


proc format*(fmt: string, src: string): string =
    ##[
        - `N` ...   align right to N characters.
        - `-N` ...  align left to N characters.
        - `-N-` ... align middle to N characters.
        - `%s` ...  replace '%s' with `src`
    ]##
    if len(fmt) < 1:
        return src

    var fmt = fmt.strip()
    let f_middle = if not fmt.endsWith("-"):  false
                   else:  fmt = fmt[0 ..^ 2]; true
    try:
        let n = parseInt(fmt)
        if n == 0: return src
        if n < 0 and f_middle:
            return center(src, -n)
        elif n < 0:
            return alignLeft(src, -n)
        return align(src, n)
    except ValueError:
        discard
    if fmt.contains("%s"):
        return fmt.replace("%s", src)
    warn("parse:format: ignored the input format ... " & fmt)
    return src

