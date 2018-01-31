# エロｇｏｄｉｃ

[![Build Status](https://travis-ci.org/oniietzschan/erogodic.svg?branch=master)](https://travis-ci.org/oniietzschan/erogodic)
[![Codecov](https://codecov.io/gh/oniietzschan/erogodic/branch/master/graph/badge.svg)](https://codecov.io/gh/oniietzschan/erogodic)
[![Alex](https://img.shields.io/badge/alex-never_racist-brightgreen.svg)](http://alexjs.com/)

Erogodic is a library for scripting branching interactive narrative in Lua. It aims to be suitable for any sort of game which needs some amount of dialog or narration, including games which are comprised entirely out of dialog, like visual novels.

Erogodic aims to provide the "back-end" of a dialog system. You will need to implement your own message boxes, portraits, user-interaction, etc. For maximum flexibility, erogodic allows you to attach any amount of arbitrary data to each "message node".

Right now Lua 5.1, Luajit 2.0, and Luajit 2.1 are supported.

I currently do not consider this library to be ideal. The syntax is too verbose, particularily around the menu functionality. I will probably rewrite Erogodic as a custom scripting language at a future time.

## Simple Example

```lua
local Ero = require 'erogodic'()

local script = Ero(function()
  msg "Hello minasan. Which of these frozen desserts is your favourite?"
  option "Soft Serve"
  option "Shaved Ice"
  menu "Choose one:"
  if selection() == "Soft Serve" then
    msg "Too cold!!"
  elseif selection() == "Shaved Ice" then
    msg "Just right."
  end
  msg "Thanks for stopping by!"
end)

script:next()
-- Returns: {msg = "Hello minasan. Which of these frozen desserts is your favourite?"}
script:next()
-- Returns: {msg = "Choose one:",
--           options = {"Soft Serve", "Shaved Ice"}}
script:select("Shaved Ice")
-- Returns: {msg = "Just right."}
script:next()
-- Returns: {msg = "Thanks for stopping by!"}
script:next()
-- Returns: nil
```

## Attributes Example

```lua
local portraitChiito = {path = "chiito.png", width = 200, height = 400}
local portraitYuuri  = {path = "yuuri.png",  width = 195, height = 430}
local script = Ero(function()
  name "Chiito"
  portrait(portraitChiito)
  msg "What are you doing?"
  name "Yuuri"
  portrait(portraitYuuri)
  msg "I'm taking it."
  msg "This is war."
end)
  :defineAttributes({
    'name',
    'portrait',
  })

script:next()
-- {msg = "What are you doing?",
--  name = "Chiito",
--  portrait = {path = "chiito.png", width = 200, height = 400}}
script:next()
-- {msg = "I'm taking it.",
--  name = "Yuuri",
--  portrait = {path = "yuuri.png",  width = 195, height = 430}}
script:next()
-- {msg = "This is war.",
--  name = "Yuuri",
--  portrait = {path = "yuuri.png",  width = 195, height = 430}}
```

## Macro example

Macros can be used to set serveral attributes at once, here's how the previous example could be rewritten:

```lua
local portraitChiito = {path = "chiito.png", width = 200, height = 400}
local portraitYuuri  = {path = "yuuri.png",  width = 195, height = 430}
local script = Ero(function()
  chii "What are you doing?"
  yuu "I'm taking it."
  yuu "This is war."
end)
  :defineAttributes({
    'name',
    'portrait',
  })
  :addMacro('chii', {
    name = "Chiito",
    portrait = portraitChiito,
  })
  :addMacro('yuu', {
    name = "Yuuri",
    portrait = portraitYuuri,
  })
```

## Eventual Features (???)
* Less repetitive syntax. Probably via a custom language parser.
* Support for internationalization.
* Command line script validation tool.

##  ┐(￣ヘ￣;)┌

> In ergodic literature, nontrivial effort is required to allow the reader to traverse the text. If ergodic literature is to make sense as a concept, there must also be nonergodic literature, where the effort to traverse the text is trivial, with no extranoematic responsibilities placed on the reader except (for example) eye movement and the periodic or arbitrary turning of pages.
