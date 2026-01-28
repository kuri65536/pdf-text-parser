PDF Text Extractor and Parser
============================

This tool extracts specific information from PDF files
based on user-defined rules, converting the
content into structured data (like XML or JSON).

PDFs, unlike XML or HTML, do not have a built-in data structure or hierarchy.
They primarily define the position and style of text.
This tool bridges that gap by allowing you to create rules
based on text position or data patterns (e.g., numbers, dates)
to parse documents consistently.


## Use Cases

### 1. Extract Billing Information

If your credit card company or utility provider
sends billing statements as PDFs, you can use this
tool to extract transaction details automatically.


![Example PDF Screenshot](tests/sample-bill.png)


**Example XML Output:**

```xml
<bill>
  <date>2025-10-25T09:11:55.000+09:00</date>
  <amount>20,000</amount>
  <description>ABC restaurant</description>
</bill>
```


### 2. Extract Insurance Information

![a PDF sample for insurance](tests/sample-payslip.png)


**Example CSV Output:**

```text
2025-10-25; 13,123; title...
```


---


Prerequisites
-----------------------------------------

| Software     | Required Version |
|:------------:|:---------:|
| nim          | >= 2.0.2  |
| poppler-glib  | libpoppler-glib-dev >= 22.12.0-2+deb12u1 |
| poppler-utils | poppler-utils       >= 22.12.0-2+deb12u1 |


---


Installation
-----------------------------------------

### Build on Debian Bookworm
- 1. Install dependencies:

```shell
$ sudo apt install libpoppler-glib-dev
```

- 2. Install Nim (>= 2.0.2)

    *(Follow official Nim installation instructions if not already installed)*

- 3. Build

```shell
$ git clone https://github.com/kuri65536/pdf_text_parser
$ cd pdf_text_parser
$ nimble build
```


### Build with mingw64 (Windows)

*(Under construction)*


-----


## Usage

```shell
$ ./pdf_text_parser [options] [files]
```

  * **[options]**: See the table below.
  * **[files]**: One or more PDF files to parse.


### Options

| Option    | Short | Parameter | Description |
|:----------|:--:|:------------:|:------------|
| `--rules` | -r | `file-name`  | **Required.** Specifies the INI file for extraction rules. [1] |
| `--verbosity` | -V | `number` | 0-6, 0: min = none, 1: less verbosity, 6: max |

[1]: #option---rules



#### Option: --rules
Specifies the path to the INI file
that defines the extraction rules.

**Usage:** `--rules [file-name:section]` or `-r [file-name]`

**Example:**
`$ ./pdf_text_parser -r a_sample_rule.ini:main target.pdf`


-----


#### Option: --verbosity
Specifies the verbosity level for debug messages by 0 to 7.
Higher values increase verbosity; 0 disables outputs.

**Usage:** `--verbosity [0-7]` or `-V [0-7]`

**Example:**
`$ ./pdf_text_parser -V 7 -r a_sample_rule.ini:main target.pdf`


-----


### The Extract Rules File
The extract rules file uses the `INI file` format and
is processed line by line.

see the examples in the `tests/` directory:
[test_ini](tests/test_ini.nim),
[test_ini2](tests/test_ini2.nim),
or [test_ini3](tests/test_ini3.nim)


#### Example Rule File

```ini
expand = group1

[group1]
; Rules in the global (top-level) section
extract = abc, 100, 100, 200, 200
extract = def, 100, 110, 200, 200
extract = ghi, 100, 120, 200, 200

format_csv = abc, def, ghi

[group2]
pairs = tbl0, 80:50:200:20, 280:50:400:20
```


#### Example Result
If the PDF contains "1111" in the first area (assigned to `abc`),
"2222" in the second (assigned to `def`),
and "3333" in the third (assigned to `ghi`),
this rule file will generate the following CSV output:

```csv
1111,2222,3333
```


-----


### Rule Definitions

#### The Rule: 'expand'

This rule will expand the rules in the group which
was specified in this rule.

The following is an example:

```text
rule1 = ...
expand = name2
rule3 = ...

[name2]
rule2_1 = ...
rule2_1 = ...
...
```

The above rules are equivalent to rules::

```text
rule1 = ...
rule2_1 = ...
rule2_1 = ...
...
rule3 = ...
```


The usage: `expand = [name]`


**name**

The `name` parameter specifies the `ini-file` group to be
expanded at this line in the current rules group.


-----


#### The Rule: 'extract'

This rule extracts text from a specific region
(defined by coordinates) of the PDF pages.


```text
extract = [variable_name], [x1], [y1], [x2], [y2]
```

| Position | Value | Description   |
|:--------:|:-----:|---------------|
| 1 | `variable_name` | The name of the extracted text |
| 2        | `x1`  | the **left** coordinate of the area to be extracted |
| 3        | `y1`  | the **top**  coordinate of the area |
| 4        | `x2`  | the **right** coordinate of the area |
| 5        | `y2`  | the **bottom** coordinate of the area |


-----


#### The Rule: 'pairs'

```text
pairs = [variable_name], [bd:num], [x1:w1:x2:w2], ...
```

| Position | Value | Description   |
|:--------:|:-----:|---------------|
| 1 | `variable_name` | The name of the extracted text |
| 2 or later | `x1:w1:x2:w2`  | See parameter details below  |
| 2 or later | `bd`           | The y tolerance for grouping |


**Logic**

1. First, bounding boxes on the page are grouped by
    their y2 position (bottom coordinate),
    using the `bd` parameter as a tolerance.

2. Next, within each group (line), the tool looks for
    a bounding box in the key range (x1 to x1 + w1) and
    a bounding box in the value range (x2 to x2 + w2).

3. If both are found, they are registered as a key-value pair.

The result can be retrieved using the `get` rule
by specifying the `key` content.


**x1:w1:x2:w2** parameter

- `x1:w1` ... The x position and width of the **key**
- `x2:w2` ... The x position and width of the **value**


**bd parameter (bottom coordinate difference)**

`bd` parameter specifies the tolerance (in PDF unit)
for grouping bounding boxes as being on the "same line".

For example, if `bd` parameter is 5, boxes with slightly
different Y2 coordinates will be treated as the same line.
If `bd` is 2, the checking is stricter.

| box    | y2  | bd=5        | bd=2 |
|--------|-----|-------------|------|
| bbox1  | 100 | o           | o    |
| bbox2  | 101 | (same line) | (same line) |
| bbox3  | 104 | (same line) | (different line) |


The result can be obtained by specifying the `key` value.


-----


#### The Rule: 'parse'

This rule specifies the parse operation for the extracted text.

```text
parse = [new_name], [source_name], [type], [format1], [format2]

parse = name2, name1, date-time, yyyy/mm/dd, yyyy
parse = name3, name1, date-time, yyyy/mm/dd, mm
```

| Position | Value   | Description   |
|:--------:|:-------:|:-------------:|
| 1  | `new_name`    | The name of the new parsed text |
| 2  | `source_name` | The variable name from `extract` to parse |
| 3  | `type`        | the data type to parse, see   |
| 4  | `format1`     | the *input* format to parse   |
| 5  | `format2`     | the *output* format to output |

the format text depends on the `type` specified.

| Type      | Description   |
|:---------:|:--------------|
| date-time | Parses a date/time string. |
| string    | Parses a string. |


- Parsing `date-time` just passes the format parameter to
    the nim-lang `times.parse` function.  
    please check the
    [nim-lang times.parse](https://nim-lang.org/docs/times.html#parsing-and-formatting-dates)
    function manual.




---


#### The Rule: 'get'

This rule specifies the `get` operation for the extracted text
from the `pairs` rule.

```text
get = [new_name], [source_name], [key_name]
```

| Position | Value   | Description   |
|:--------:|:-------:|:-------------:|
| 1  | `new_name`    | The name of the new parsed text |
| 2  | `source_name` | The variable name from `pairs` to parse |
| 3  | `key`         | the key string in the parsed pairs |



---


#### The Rule: 'calc'

This rule specifies the calculate operation for the extracted text.

```text
calc = [new_name], [operator], [term1], [term2], [term3] ...

calc = name2, add, name1, name4, name5
calc = name3, &, name1, name4
```

| Position | Value   | Description   |
|:--------:|:-------:|:-------------:|
| 1  | `new_name`    | The name of the new calculated text |
| 2  | `operator`    | The calculation type |
| 3  | `term1`       | the source variable |
| 4  | `term2`       | the source variable |
| 5  | `term3`       | the source variable (optional) |

the calculation type on the `operator` specified.

| Type      | Description   |
|:---------:|:--------------|
| +         | add the terms as numbers, the result will be sum of terms |
| add       |^ |
| -         | subtract the terms as numbers |
| sub       |^ |
| *         | multiply the terms as numbers |
| mul       |^ |
| &         | concatenate the terms as string |
| concat    |^ |

Please see [tests/test_calc1.nim] or `test_calc*.nim` for
the operators and expected results.


---


Roadmap (Under Construction)
-----------------------------------------

[under construction]: #under-construction

The following features are planned:

- XML output format.
- JSON output format.
- True poppler-API access to get bounding box in PDF.
- Cache the bounding box contents in PDFDoc
- Refactor the rule structure
- Add the page parameters to the pairs
- Add the page parameters to the extract



---


License
-----------------------------------------
MIT (see `LICENSE` file)


---


Information
-----------------------------------------
If you find this project useful,
Donations are welcome to support the development of this project.


[![img-bitcoin]][lnk-bitcoin]
&nbsp;&nbsp;or&nbsp;&nbsp;
[![img-etherium]][lnk-bitcoin]

- [bitcoin:39Qx9Nffad7UZVbcLpVpVanvdZEQUanEXd][lnk-bitcoin]
- [ethereum:0x9d03b1a8264023c3ad8090b8fc2b75b1ba2b3f0f][lnk-bitcoin]
- or [liberapay](https://liberapay.com/kuri65536) .

[lnk-bitcoin]:  https://kuri65536.bitbucket.io/donation.html?message=thank-for-pdf_toc_outlines
[img-bitcoin]:  https://github.com/user-attachments/assets/abce4347-bcb3-42c6-a9e8-1cd12f1bd4a5
[img-etherium]: https://github.com/user-attachments/assets/d1bdb9a8-9c6f-4e74-bc19-0d0bfa041eb2

