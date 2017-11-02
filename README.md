# エロｇｏｄｉｃ

Erogodic is a library for scripting branching interactive narrative in Lua. It aims to be suitable for any sort of game which needs some amount of dialog or narration, including games which are comprised entirely out of dialog, like visual novels.

Erogodic aims to provide the "back-end" of a dialog system. You will need to implement your own message boxes, portraits, user-interaction, etc. For maximum flexibility, erogodic allows you to attach any amount of arbitrary data to each "message node".

Note: I currently do not consider this library worth using. The syntax is too verbose, particularily around the menu functionality. I will probably rewrite Erogodic as a custom scripting language at a future time.

## Example

```lua
local Ero = require 'erogodic'()

local script = Ero(function()
  Ero:env()

  msg "Hello minasan."
  msg "Which of these frozen desserts is your favourite?"

  option "Soft Serve"
  option "Shaved Ice"
  menu "Choose one:"
  if selection() == "Soft Serve" then
    goto softServe
  elseif selection() == "Shaved Ice" then
    goto shavedIce
  end

  ::softServe::
  msg "Too cold!!"
  do return end

  ::shavedIce::
  msg "Just right."
  do return end
end)


script:next()
-- Returns: {msg = "Hello minasan."}
script:next()
-- Returns: {msg = "Which of these frozen desserts is your favourite?"}
script:next()
-- Returns: {msg = "Choose one:",
--           options = {"Soft Serve", "Shaved Ice"}}
script:select("Shaved Ice")
-- Returns: {msg = "Just right."}
script:next()
-- Returns: nil
```

## Eventual Features
* Traverse nodes with arbitrary content: text, portraits, animations, scripting, etc.
* Control flow including: branching choices, loops, breakpoints.
* Use outside variables and conditions to constrain or direct the script.
* Support for internationalization.
* Command line script validation tool.

##  ┐(￣ヘ￣;)┌

> In ergodic literature, nontrivial effort is required to allow the reader to traverse the text. If ergodic literature is to make sense as a concept, there must also be nonergodic literature, where the effort to traverse the text is trivial, with no extranoematic responsibilities placed on the reader except (for example) eye movement and the periodic or arbitrary turning of pages.
