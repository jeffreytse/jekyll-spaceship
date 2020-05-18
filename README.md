<h1 align="center">
  <a href="https://github.com/jeffreytse/jekyll-spaceship">
    <img alt="spaceship →~ jekyll" src="https://raw.githubusercontent.com/jeffreytse/jekyll-spaceship/master/logos/jekyll-spaceship-logo.png" width="400">
  </a>
  <br> 🚀 Jekyll Spaceship 🚀 <br>
</h1>

<h4 align="center">
  <a href="https://jekyllrb.org" target="_blank"><code>Jekyll</code></a> plugin for Astronauts.
</h4>

<p align="center">

  <a href="https://travis-ci.org/jeffreytse/jekyll-spaceship">
    <img src="https://travis-ci.org/jeffreytse/jekyll-spaceship.svg?branch=master"
      alt="CI Status" />
  </a>

  <a href="http://badge.fury.io/rb/jekyll-spaceship">
    <img src="https://badge.fury.io/rb/jekyll-spaceship.svg"
      alt="Gem Version" />
  </a>

  <a href="https://codeclimate.com/github/jeffreytse/jekyll-spaceship">
    <img src="https://codeclimate.com/github/jeffreytse/jekyll-spaceship/badges/gpa.svg"
      alt="Code Climate" />
  </a>

  <a href="https://codeclimate.com/github/jeffreytse/jekyll-spaceship/test_coverage">
    <img src="https://api.codeclimate.com/v1/badges/cd56b207f327603662a1/test_coverage"
      alt="Test Coverage" />
  </a>

  <a href="https://github.com/jeffreytse/jekyll-spaceship/blob/master/LICENSE.txt">
    <img src="https://img.shields.io/badge/License-MIT-brightgreen.svg"
      alt="License" />
  </a>

  <a href="http://badge.fury.io/rb/jekyll-spaceship">
    <img src="https://img.shields.io/gem/dt/jekyll-spaceship"
      alt="Download Data" />
  </a>

</p>

<p align="center">

  <a href="https://liberapay.com/jeffreytse">
    <img src="http://img.shields.io/liberapay/goal/jeffreytse.svg?logo=liberapay"
      alt="Donate (Liberapay)" />
  </a>

  <a href="https://patreon.com/jeffreytse">
    <img src="https://img.shields.io/badge/support-patreon-F96854.svg?style=flat-square"
      alt="Donate (Patreon)" />
  </a>

  <a href="https://ko-fi.com/jeffreytse">
    <img height="20" src="https://www.ko-fi.com/img/githubbutton_sm.svg"
      alt="Donate (Ko-fi)" />
  </a>

</p>

<div align="center">
  <h4>
    <a href="#requirements">Requirements</a> |
    <a href="#installation">Install</a> |
    <a href="#usage">Usage</a> |
    <a href="#credits">Credits</a> |
    <a href="#license">License</a>
  </h4>
</div>

<div align="center">
  <sub>Built with ❤︎ by
  <a href="https://jeffreytse.net">jeffreytse</a> and
  <a href="https://github.com/jeffreytse/jekyll-spaceship/graphs/contributors">contributors </a>
</div>
<br>


A Jekyll plugin to provide powerful supports for table, mathjax, plantuml, emoji, youtube, vimeo, dailymotion, etc.

<p align="center">
    <img alt="Jekyll Spaceship Demo" src="https://user-images.githubusercontent.com/9413601/82250463-15451780-997e-11ea-8809-f411586d9508.gif" alt="Donate (Ko-fi)" />
</p>

**💡 Tip:** I hope you enjoy using this plugin. If you like this project, **a little star** for it is your way make a clear statement: **My work is valued**. I would appreciate your support! _Thank you!_


## Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [1. Table Usage](#1-table-usage)
    - [1.1 Rowspan and Colspan](#rowspan-and-colspan)
    - [1.2 Multiline](#multiline)
    - [1.3 Headerless](#headerless)
    - [1.4 Cell Alignment](#cell-alignment)
    - [1.5 Cell Markdown](#cell-markdown)
  - [2. MathJax Usage](#2-mathjax-usage)
    - [2.1 Performance Optimization](#21-performance-optimization)
    - [2.2 How to use?](#22-how-to-use)
  - [3. PlantUML Usage](#3-plantuml-usage)
  - [4. Video Usage](#4-video-usage)
    - [4.1 Youtube Usage](#youtube-usage)
    - [4.2 Vimeo Usage](#vimeo-usage)
    - [4.3 DailyMotion Usage](#dailymotion-usage)
  - [5. Hybrid HTML with Markdown](#5-hybrid-html-with-markdown)
  - [6. Markdown Polyfill](#6-markdown-polyfill)
    - [6.1 Escape Ordered List](#escape-ordered-list)
  - [7. Emoji Usage](#7-emoji-usage)
- [Credits](#credits)
- [Contributing](#contributing)
- [License](#license)

## Requirements

- Ruby >= 2.3.0

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

**💡 Tip:** Note that GitHub Pages runs in `safe` mode and only allows [a set of whitelisted plugins](https://pages.github.com/versions/). To use the gem in GitHub Pages, you need to build locally or use CI (e.g. [travis](https://travis-ci.org/), [github workflow](https://help.github.com/en/actions/configuring-and-managing-workflows/configuring-a-workflow)) and deploy to your `gh-pages` branch. [Click here for more information.](https://jekyllrb.com/docs/continuous-integration/github-actions/)

## Usage

### 1. Table Usage

**For now, these extended features are provided:**

- Cells spanning multiple columns
- Cells spanning multiple rows
- Cells text align separately
- Table header not required
- Grouped table header rows or data rows

Noted that GitHub filters out style property, so the example displays with the obsolete align property. But in actual this plugin outputs style property with text-align CSS attribute.

#### Rowspan and Colspan

^^ in a cell indicates it should be merged with the cell above.  
This feature is contributed by [pmccloghrylaing](https://github.com/pmccloghrylaing).

```markdown
|              Stage | Direct Products | ATP Yields |
| -----------------: | --------------: | ---------: |
|         Glycolysis |           2 ATP |            |
|                 ^^ |          2 NADH |   3--5 ATP |
| Pyruvaye oxidation |          2 NADH |      5 ATP |
|  Citric acid cycle |          2 ATP              ||
|                 ^^ |          6 NADH |     15 ATP |
|                 ^^ |          2 FADH |      3 ATP |
|                                   30--32 ATP    |||
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
| :    Easy Multiline   : |||
| :----- | :----- | :------ |
| Apple  | Banana | Orange  \
| Apple  | Banana | Orange  \
| Apple  | Banana | Orange
| Apple  | Banana | Orange  \
| Apple  | Banana | Orange  |
| Apple  | Banana | Orange  |
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
|♜| |♝|♛|♚|♝|♞|♜|
| |♟|♟|♟| |♟|♟|♟|
|♟| |♞| | | | | |
| |♗| | |♟| | | |
| | | | |♙| | | |
| | | | | |♘| | |
|♙|♙|♙|♙| |♙|♙|♙|
|♖|♘|♗|♕|♔| | |♖|
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

```markdown
| :        Fruits \|\| Food       : |||
| :--------- | :-------- | :--------  |
| Apple      | :  Apple :| Apple      \
| Banana     |   Banana  | Banana     \
| Orange     |   Orange  | Orange     |
| :   Rowspan is 4    : || How's it?  |
|^^    A. Peach         ||   1. Fine :|
|^^    B. Orange        ||^^ 2. Bad   |
|^^    C. Banana        ||  It's OK!  |
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

#### Cell Markdown

Sometimes we may need some abundant content (e.g., mathjax, image, video) in Markdown table  
Therefore, here we also make markown syntax possible inside a cell.

```markdown
| :                   MathJax \|\| Image                 : |||
| :------------ | :-------- | :----------------------------- |
| Apple         | : Apple : | Apple                          \
| Banana        | Banana    | Banana                         \
| Orange        | Orange    | Orange                         |
| :     Rowspan is 4     : || :        How's it?           : |
| ^^     A. Peach          ||    1. ![example][cell-image]   |
| ^^     B. Orange         || ^^ 2. $I = \int \rho R^{2} dV$ |
| ^^     C. Banana         || **It's OK!**                   |

[cell-image]: https://jekyllrb.com/img/octojekyll.png "An exemplary image"
```

Code above would be parsed as:

<table>
<thead>
<tr>
<th align="center" colspan="3">MathJax || Image
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
<td align="center">How's it?</td>
</tr>
<tr>
<td align="left">
<ol>
<li><img width="100" src="http://latex2png.com/pngs/82b913db54a9f303bed7197d11347d74.png"></img></li>
<li><img width="150" src="https://jekyllrb.com/img/octojekyll.png" title="An exemplary image"></img></li>
</ol>
</td>
</tr>
<tr>
<td align="left"><b>It' OK!</b></td>
</tr>
</tbody>
</table>

### 2. MathJax Usage

[MathJax](http://www.mathjax.org/) is an open-source JavaScript display engine for LaTeX, MathML, and AsciiMath notation that works in all modern browsers.

Some of the main features of MathJax include:

- High-quality display of LaTeX, MathML, and AsciiMath notation in HTML pages
- Supported in most browsers with no plug-ins, extra fonts, or special
  setup for the reader
- Easy for authors, flexible for publishers, extensible for developers
- Supports math accessibility, cut-and-paste interoperability, and other
  advanced functionality
- Powerful API for integration with other web applications

#### 2.1 Performance optimization

At building stage, the MathJax engine script will be added by automatically checking whether there is a math expression in the page, this feature can help you improve the page performance  on loading speed.

#### 2.2 How to use?

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

- sequence diagram,
- use case diagram,
- class diagram,
- activity diagram,
- component diagram,
- state diagram
- object diagram

There are two ways to create a diagram in your Jekyll blog page:

````markdown
```plantuml
Bob -> Alice : hello world
```
````

or

```markdown
@startuml
Bob -> Alice : hello
@enduml
```

### 4. Video Usage

How often did you find yourself googling "**How to embed a video in markdown?**"

While its not possible to embed a video in markdown, the best and easiest way is to extract a frame from the video. To add videos to your markdown files easier I developped this tool for you, and it will parse the video link inside the image block automatically.

**For now, these video links parsing are provided:**

- Youtube
- Vimeo
- DailyMotion

There are two ways to embed a video in your Jekyll blog page:

Inline-style:

```markdown
![]({video-link})
```

Reference-style:

```markdown
![][{reference}]

[{reference}]: {video-link}
```

For configuring video attributes (e.g, width, height), just adding query string to
the link as below:

```markdown
![](https://www.youtube.com/watch?v=Ptk_1Dc2iPY?width=800&height=500)
```

```markdown
![](https://www.dailymotion.com/video/x7tfyq3?width=100%&height=400&autoplay=1)
```

#### Youtube Usage

```markdown
![](https://www.youtube.com/watch?v=Ptk_1Dc2iPY)
```

```markdown
![](//www.youtube.com/watch?v=Ptk_1Dc2iPY?width=800&height=500)
```

#### Vimeo Usage

```markdown
![](https://vimeo.com/263856289)
```

```markdown
![](https://vimeo.com/263856289?width=500&height=320)
```

#### DailyMotion Usage

```markdown
![](https://www.dailymotion.com/video/x7tfyq3)
```

```markdown
![](https://dai.ly/x7tgcev?width=100%&height=400)
```

### 5. Hybrid HTML with Markdown

As markdown is not only a lightweight markup language with plain-text-formatting syntax, but also an easy-to-read and easy-to-write plain text format, so writing a hybrid HTML with markdown is an awesome choice.

It's easy to write markdown inside HTML:

```html
<script type="text/markdown">
# Hybrid HTML with Markdown is a not bad choice ^\_^

## Table Usage

| :        Fruits \|\| Food       : |||
| :--------- | :-------- | :--------  |
| Apple      | :  Apple :| Apple      \
| Banana     |   Banana  | Banana     \
| Orange     |   Orange  | Orange     |
| :   Rowspan is 4    : || How's it?  |
|^^    A. Peach         ||   1. Fine :|
|^^    B. Orange        ||^^ 2. Bad   |
|^^    C. Banana        ||  It's OK!  |

## PlantUML Usage

@startuml
Bob -> Alice : hello
@enduml

## Video Usage

![](https://www.youtube.com/watch?v=Ptk_1Dc2iPY)
</script>
```

### 6. Markdown Polyfill

It allows us to polyfill features for extending markdown syntax.

**For now, these polyfill features are provided:**

- Escape ordered list

#### Escape Ordered List

A backslash at begin to escape the ordered list.

```markdown
Normal:

1. List item Apple.
3. List item Banana.
10. List item Cafe.

Escaped:

\1. List item Apple.
\3. List item Banana.
\10. List item Cafe.
```

Code above would be parsed as:

```markdown
Normal:

1. List item Apple.
2. List item Banana.
3. List item Cafe.

Escaped:

1. List item Apple.
3. List item Banana.
10. List item Cafe.
```

### 7. Emoji Usage
GitHub-flavored emoji images and names would allow emojifying content such as: it's raining :cat:s and :dog:s!

Noted that emoji images are served from the GitHub.com CDN, with a base URL of [https://github.githubassets.com](https://github.githubassets.com), which results in emoji image URLs like [https://github.githubassets.com/images/icons/emoji/unicode/1f604.png](https://github.githubassets.com/images/icons/emoji/unicode/1f604.png).

In any page or post, use emoji as you would normally, e.g.

```
I give this plugin two :+1:!
```

**Code above would be parsed as:**

I give this plugin two :+1:!

## Credits

- [Jekyll](https://github.com/jekyll/jekyll) - A blog-aware static site generator in Ruby.
- [MultiMarkdown](https://fletcher.github.io/MultiMarkdown-6) - Lightweight markup processor to produce HTML, LaTeX, and more.
- [markdown-it-multimd-table](https://github.com/RedBug312/markdown-it-multimd-table) - Multimarkdown table syntax plugin for markdown-it markdown parser.
- [jmoji](https://github.com/jekyll/jemoji) - GitHub-flavored emoji plugin for Jekyll.

## Contributing

Issues and Pull Requests are greatly appreciated. If you've never contributed to an open source project before I'm more than happy to walk you through how to create a pull request.

You can start by [opening an issue](https://github.com/jeffreytse/jekyll-spaceship/issues/new) describing the problem that you're looking to resolve and we'll go from there.

## License

This software is licensed under the [MIT license](https://opensource.org/licenses/mit-license.php) © JeffreyTse.
