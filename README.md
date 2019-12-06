# jekyll-spaceship

[![Build Status](https://travis-ci.org/jeffreytse/jekyll-spaceship.svg?branch=master)](https://travis-ci.org/jeffreytse/jekyll-spaceship)
[![Gem Version](https://badge.fury.io/rb/jekyll-spaceship.svg)](http://badge.fury.io/rb/jekyll-spaceship)
[![Code Climate](https://codeclimate.com/github/jeffreytse/jekyll-spaceship/badges/gpa.svg)](https://codeclimate.com/github/jeffreytse/jekyll-spaceship)
[![Test Coverage](https://api.codeclimate.com/v1/badges/cd56b207f327603662a1/test_coverage)](https://codeclimate.com/github/jeffreytse/jekyll-spaceship/test_coverage)

A Jekyll plugin to provide powerful supports for table, mathjax, plantuml, etc.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [1. Table Usage](#1-table-usage)
    - [1.1 Rowspan and Colspan](#rowspan-and-colspan)
    - [1.2 Multiline](#multiline)
    - [1.3 Headerless](#headerless)
    - [1.4 Cell Alignment](#cell-alignment)
  - [2. MathJax Usage](#2-mathjax-usage)
  - [3. PlantUML Usage](#3-plantuml-usage)
- [Credits](#credits)
- [Contributing](#contributing)
- [License](#license)


## Installation

Add jekyll-spaceship plugin in your site's `Gemfile`, and run `bundle install`.

```ruby
gem 'jekyll-spaceship'
```

Add jekyll-spaceship to the `gems:` section in your site's `_config.yml`.

```yml
plugins:
  - jekyll-spaceship
```

## Usage

### 1. Table Usage

**For now, these extended features are provided:**

* Cells spanning multiple columns
* Cells spanning multiple rows
* Cells text align separately
* Table header not required
* Grouped table header rows or data rows

Noted that GitHub filters out style property, so the example displays with the obsolete align property. But in actual this plugin outputs style property with text-align CSS attribute.

#### Rowspan and Colspan
^^ in a cell indicates it should be merged with the cell above.  
This feature is contributed by [pmccloghrylaing](https://github.com/pmccloghrylaing).

```markdown
| Stage | Direct Products | ATP Yields |
| ----: | --------------: | ---------: |
|Glycolysis | 2 ATP                   ||
|^^         | 2 NADH      | 3--5 ATP   |
|Pyruvaye oxidation | 2 NADH | 5 ATP   |
|Citric acid cycle  | 2 ATP  |         |
|^^                 | 6 NADH | 15 ATP  |
|^^                 | 2 FADH | 3 ATP   |
| 30--32 ATP                         |||
```

Code above would be parsed as:

<table>
<thead>
<tr>
<th align="right">Stage</th>
<th align="right">Direct Products</th>
<th align="right">ATP Yields</th>
</tr>
</thead>
<tbody>
<tr>
<td align="right" rowspan="2">Glycolysis</td>
<td align="right" colspan="2">2 ATP</td>
</tr>
<tr>
<td align="right">2 NADH</td>
<td align="right">3–5 ATP</td>
</tr>
<tr>
<td align="right">Pyruvaye oxidation</td>
<td align="right">2 NADH</td>
<td align="right">5 ATP</td>
</tr>
<tr>
<td align="right" rowspan="3">Citric acid cycle</td>
<td align="right" colspan="2">2 ATP</td>
</tr>
<tr>
<td align="right">6 NADH</td>
<td align="right">15 ATP</td>
</tr>
<tr>
<td align="right">2 FADH2</td>
<td align="right">3 ATP</td>
</tr>
<tr>
<td align="right" colspan="3">30–32 ATP</td>
</tr>
</tbody>
</table>

#### Multiline
A backslash at end to join cell contents with the following lines.  
This feature is contributed by [Lucas-C](https://github.com/Lucas-C).

```markdown
|:     Easy Multiline     :|||
|:------ |:------ |:-------- |
| Apple  | Banana |  Orange  \
| Apple  | Banana |  Orange  \
| Apple  | Banana |  Orange
| Apple  | Banana |  Orange  \
| Apple  | Banana |  Orange  |
| Apple  | Banana |  Orange  |
```

Code above would be parsed as:

<table>
<thead>
<tr>
<th align="center" colspan="3">Easy Multiline</th>
</tr>
</thead>
<tbody>
<tr>
<td align="left">Apple<br>Apple<br>Apple</td>
<td align="left">Banana<br>Banana<br>Banana</td>
<td align="left">Orange<br>Orange<br>Orange</td>
</tr>
<tr>
<td align="left">Apple<br>Apple</td>
<td align="left">Banana<br>Banana</td>
<td align="left">Orange<br>Orange</td>
</tr>
<tr>
<td align="left">Apple</td>
<td align="left">Banana</td>
<td align="left">Orange</td>
</tr>
</tbody>
</table>

#### Headerless
Table header can be eliminated.

```markdown
|--|--|--|--|--|--|--|--|
|♜|  |♝|♛|♚|♝|♞|♜|
|  |♟|♟|♟|  |♟|♟|♟|
|♟|  |♞|  |  |  |  |  |
|  |♗|  |  |♟|  |  |  |
|  |  |  |  |♙|  |  |  |
|  |  |  |  |  |♘|  |  |
|♙|♙|♙|♙|  |♙|♙|♙|
|♖|♘|♗|♕|♔|  |  |♖|
```

Code above would be parsed as:

<table>
<tbody>
<tr>
<td>♜</td>
<td></td>
<td>♝</td>
<td>♛</td>
<td>♚</td>
<td>♝</td>
<td>♞</td>
<td>♜</td>
</tr>
<tr>
<td></td>
<td>♟</td>
<td>♟</td>
<td>♟</td>
<td></td>
<td>♟</td>
<td>♟</td>
<td>♟</td>
</tr>
<tr>
<td>♟</td>
<td></td>
<td>♞</td>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td>♗</td>
<td></td>
<td></td>
<td>♟</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td>♙</td>
<td></td>
<td></td>
<td></td>
</tr>
<tr>
<td></td>
<td></td>
<td></td>
<td></td>
<td></td>
<td>♘</td>
<td></td>
<td></td>
</tr>
<tr>
<td>♙</td>
<td>♙</td>
<td>♙</td>
<td>♙</td>
<td></td>
<td>♙</td>
<td>♙</td>
<td>♙</td>
</tr>
<tr>
<td>♖</td>
<td>♘</td>
<td>♗</td>
<td>♕</td>
<td>♔</td>
<td></td>
<td></td>
<td>♖</td>
</tr>
</tbody>
</table>

#### Cell Alignment
Markdown table syntax use colons ":" for forcing column alignment.  
Therefore, here we also use it for foring cell alignment.  

Table cell can be set alignment separately.

```
|:     Fruits \|\| Food           :|||
|:-------- |:-------- |:------------ |
| Apple    |: Apple  :|    Apple     \
| Banana   |  Banana  |    Banana    \
| Orange   |  Orange  |    Orange    |
|:   Rowspan is 4   :||   How's it?  |
|^^  A. Peach        ||   1. Fine   :|
|^^  B. Orange       ||^^ 2. Bad     |
|^^  C. Banana       ||   It's OK!   |
```

Code above would be parsed as:

<table>
<thead>
<tr>
<th align="center" colspan="3">Fruits || Food
</tr>
</thead>
<tbody>
<tr>
<td align="left">Apple<br>Banana<br>Orange</td>
<td align="center">Apple<br>Banana<br>Orange</td>
<td align="left">Apple<br>Banana<br>Orange</td>
</tr>
<tr>
<td align="center" rowspan="4" colspan="2">
Rowspan is 4
<br>A. Peach
<br>B. Orange
<br>C. Banana
</td>
</tr>
<tr>
<td align="left">How's it?</td>
</tr>
<tr>
<td align="right">1. Fine<br>2. Bad</td>
</tr>
<tr>
<td align="left">It' OK!</td>
</tr>
</tbody>
</table>


### 2. MathJax Usage
[MathJax](http://www.mathjax.org/) is an open-source JavaScript display engine for LaTeX, MathML, and AsciiMath notation that works in all modern browsers.

**Some of the main features of MathJax include:**

* High-quality display of LaTeX, MathML, and AsciiMath notation in HTML pages
* Supported in most browsers with no plug-ins, extra fonts, or special
  setup for the reader
* Easy for authors, flexible for publishers, extensible for developers
* Supports math accessibility, cut-and-paste interoperability, and other
  advanced functionality
* Powerful API for integration with other web applications


Put your math expression within \$...\$

```markdown
$ a * b = c ^ b $
```

```markdown
$ 2^{\frac{n-1}{3}} $
```

```markdown
$ \int\_a^b f(x)\,dx. $
```

### 3. PlantUML Usage
[PlantUML](http://plantuml.sourceforge.net/) is a component that allows to quickly write:
 * sequence diagram,
 * use case diagram,
 * class diagram,
 * activity diagram,
 * component diagram,
 * state diagram
 * object diagram


There are two ways to create a diagram in your Jekyll blog page:

```markdown
@startuml
Bob -> Alice : hello
@enduml
```

or

````markdown
``` plantuml
Bob -> Alice : hello world
```
````
## Credits

- [Jekyll](https://github.com/jekyll/jekyll) - A blog-aware static site generator in Ruby.
- [MultiMarkdown](https://fletcher.github.io/MultiMarkdown-6) - Lightweight markup processor to produce HTML, LaTeX, and more.
- [markdown-it-multimd-table](https://github.com/RedBug312/markdown-it-multimd-table) - Multimarkdown table syntax plugin for markdown-it markdown parser.

## Contributing

Issues and Pull Requests are greatly appreciated. If you've never contributed to an open source project before I'm more than happy to walk you through how to create a pull request.

You can start by [opening an issue](https://github.com/jeffreytse/jekyll-spaceship/issues/new) describing the problem that you're looking to resolve and we'll go from there.

## License
This software is licensed under the [MIT license](https://opensource.org/licenses/mit-license.php) © JeffreyTse.
