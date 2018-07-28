require 'busted'

local ErogodicModule = require 'erogodic'

describe('Terebi:', function()
  local Ero

  before_each(function()
    Ero = ErogodicModule()
  end)

  describe('When executing script', function()
    -- !! This test case is first because the expected error references the line number in this file. !!
    it('Invalid scripts should relay error message', function()
      local script = Ero(function()
        msg(undefinedGlobal.undefinedKey)
      end)
      local expectedError = "Error executing script: spec.lua:16: attempt to index global 'undefinedGlobal' (a nil value)"
      assert.has_error(function() script:next() end, expectedError)
    end)

    it('Should have expected output', function()
      local script = Ero(function()
        msg "Hello minasan."
        msg "Which of these frozen desserts is your favourite?"
        option "Soft Serve"
        option "Shaved Ice"
        menu "Choose one:"
        if selection "Soft Serve" then
          msg "Too cold!!"
        elseif selection "Shaved Ice" then
          msg "Just right."
        end
      end)

      assert.same('table', type(script))
      assert.same(true, script:hasNext())
      assert.same({
        msg = "Hello minasan.",
      }, script:next())
      assert.same({
        msg = "Which of these frozen desserts is your favourite?",
      }, script:next())
      assert.same({
        msg = "Choose one:",
        options = {
          "Soft Serve",
          "Shaved Ice",
        }
      }, script:next())
      assert.same({
        msg = "Just right.",
      }, script:select("Shaved Ice"))
      assert.same(nil, script:next())
      assert.same(false, script:hasNext())
    end)

    it('Looping should be possible. Also test option returning things I guess.', function()
      local script = Ero(function()
        while true do
          local wanko       = option "What does a wanko say?"
          local nyanko      = option "What does a nyanko say?"
          local alreadyKnow = option "I already know a ton about animal sounds."
          menu "Make your selection, now."
          if selection(wanko) then
            msg "Wan! Wan!"
          elseif selection(nyanko) then
            msg "Nya! Nyan!"
          elseif selection(alreadyKnow) then
            msg "Fine. Have a nice day."
            break
          end
        end
      end)

      local assertMenuWasDisplayed = function()
        assert.same({
          msg = "Make your selection, now.",
          options = {
            "What does a wanko say?",
            "What does a nyanko say?",
            "I already know a ton about animal sounds.",
          }
        }, script:next())
      end

      assertMenuWasDisplayed()
      assert.same({
        msg = "Wan! Wan!",
      }, script:select("What does a wanko say?"))
      assertMenuWasDisplayed()
      assert.same({
        msg = "Nya! Nyan!",
      }, script:select("What does a nyanko say?"))
      assertMenuWasDisplayed()
      assert.same({
        msg = "Fine. Have a nice day.",
      }, script:select("I already know a ton about animal sounds."))
      assert.same(nil, script:next())
    end)

    it("Arbitrary lua scripting should be possible", function()
      local player = {
        hatted = false,
      }
      local script = Ero(function()
        while true do
          if player.hatted == false then
            option "Put on a dapper hat."
          else
            option "Say: \"I am the supreme gentleman.\""
          end
          option "Give the world it's retribution."
          menu ""
          if selection "Put on a dapper hat." then
            player.hatted = true
            msg "You put on a dapper hat. It fits perfectly and you look fucking brilliant."
          elseif selection "Say: \"I am the supreme gentleman.\"" then
            msg "You assert your status as a conscious agent in the universe."
            break
          end
        end
      end)

      assert.same(false, player.hatted)
      assert.same({
        msg = "",
        options = {
          "Put on a dapper hat.",
          "Give the world it's retribution.",
        }
      }, script:next())
      assert.same({
        msg = "You put on a dapper hat. It fits perfectly and you look fucking brilliant.",
      }, script:select("Put on a dapper hat."))
      assert.same(true, player.hatted)
      assert.same({
        msg = "",
        options = {
          "Say: \"I am the supreme gentleman.\"",
          "Give the world it's retribution.",
        }
      }, script:next())
      assert.same({
        msg = "You assert your status as a conscious agent in the universe.",
      }, script:select("Say: \"I am the supreme gentleman.\""))
      assert.same(nil, script:next())
    end)

    it('Calling :next() on a finished script should give a vaguely coherent error message.', function()
      local script = Ero(function()
        msg "あ、そういえばアイポンってツリあるよね、ツリ～"
      end)
      assert.same({
        msg = "あ、そういえばアイポンってツリあるよね、ツリ～",
      }, script:next())
      assert.same(nil, script:next())
      assert.same(false, script:hasNext())
      local expectedError = "Script is finished."
      assert.has_error(function() script:next() end, expectedError)
    end)
  end)

  describe('When prompted with a choice', function()
    it('Should throw error when choosing invalid option', function()
      local script = Ero(function()
        option "Lemon Tea"
        option "Milk Tea"
        menu "Which is best?"
      end)

      assert.same({msg = "Which is best?", options = {"Lemon Tea", "Milk Tea"}}, script:next())
      assert.has_error(function() script:select("Onion Tea") end, "Selection 'Onion Tea' was not one of the options.")
    end)

    it('Should not be possible to skip it', function()
      local script = Ero(function()
        option "Yes"
        menu "Would you like to pay your taxes?"
        if selection "Yes" then
          msg "What a good citizen you are!"
        end
      end)

      assert.same({msg = "Would you like to pay your taxes?", options = {"Yes"}}, script:next())
      assert.same({msg = "Would you like to pay your taxes?", options = {"Yes"}}, script:next())
      assert.same({msg = "Would you like to pay your taxes?", options = {"Yes"}}, script:next())
      assert.same({msg = "Would you like to pay your taxes?", options = {"Yes"}}, script:next())
      assert.same({msg = "What a good citizen you are!"}, script:select("Yes"))
      assert.same(nil, script:next())
    end)

    it('"msg" should not block from proceeding when options are defined', function()
      local script = Ero(function()
        msg "You have two options..."
        option "Yahweh"
        msg "Yahweh."
        option "Highway"
        msg "Or the highway."
        menu "Yeah! This time I'm a let it all come out!"
      end)

      assert.same({msg = "You have two options..."}, script:next())
      assert.same({msg = "Yahweh."}, script:next())
      assert.same({msg = "Or the highway."}, script:next())
      assert.same({
        msg = "Yeah! This time I'm a let it all come out!",
        options = {"Yahweh", "Highway"}
      }, script:next())
      assert.same(nil, script:select("Yahweh"))
    end)
  end)

  describe('When setting node attributes', function()
    it('Should be able to define and set arbitrary node attributes', function()
      local script = Ero(function()
        characterName "Steven"
        msg "Get off your duff!"
        effect "shake text"
        msg "Check in with your body; how does it feel?"
        characterName "Doug"
        effect(nil)
        msg "I'm a hunk, so I don't have to exercise."
      end)
        :defineAttributes({
          'characterName',
          'effect',
          'unusedAttribute',
        })

      assert.same({
        characterName = "Steven",
        msg = "Get off your duff!",
      }, script:next())
      assert.same({
        characterName = "Steven",
        effect = "shake text",
        msg = "Check in with your body; how does it feel?",
      }, script:next())
      assert.same({
        characterName = "Doug",
        msg = "I'm a hunk, so I don't have to exercise.",
      }, script:next())
    end)

    it('Should throw error when defineAttributes() is called with invalid parameters.', function()
      local script = Ero(function() end)
      local expectedError = "attributeNames must be a table, got: nil"
      assert.has_error(function() script:defineAttributes(nil) end, expectedError)
    end)

    it('Should be able to get() node value', function()
      local script = Ero(function()
        name "Steve Brule"
        local charaName = get('name')
        msg("Hello, my name is Dr. " .. charaName .. ".")
      end)
        :defineAttributes({'name'})

      assert.same({
        name = "Steve Brule",
        msg = "Hello, my name is Dr. Steve Brule.",
      }, script:next())
    end)

    it('should be able to set node attributes to any Lua value', function()
      local func = function() return false end
      local tbl = {path = "/assets/portrait.png", width = 64, height = 128}
      local script = Ero(function()
        attr(true)
        msg "boolean"
        attr(func)
        msg "function"
        attr(420.666)
        msg "number"
        attr "Puru puru purin"
        msg "string"
        attr(tbl)
        msg "table"
      end)
        :defineAttributes({
          'attr',
        })

      assert.same({
        attr = true,
        msg = "boolean",
      }, script:next())
      assert.same({
        attr = func,
        msg = "function",
      }, script:next())
      assert.same({
        attr = 420.666,
        msg = "number",
      }, script:next())
      assert.same({
        attr = "Puru puru purin",
        msg = "string",
      }, script:next())
      assert.same({
        attr = tbl,
        msg = "table",
      }, script:next())
    end)

    it('should be able to use presets to create message node with multiple attribute values', function()
      local script = Ero(function()

        -- terse syntax
        serval()
        msg "Ohayou!"
        kaban "Tabenai de kudasai!"
        font "jokerman"
        serval "Tabenai yo!"
        -- verbose syntax
        kaban()
        msg "Ureshii naa!"
      end)
        :defineAttributes({
          'font',
          'name',
          'image',
        })
        :addPreset('kaban', {
          name = 'Kaban',
          image = 'kaban.png',
        })
        :addPreset('serval', {
          name = 'Serval, The Serval',
          image = 'serval.png',
        })

      assert.same({
        name = 'Serval, The Serval',
        image = 'serval.png',
        msg = 'Ohayou!',
      }, script:next())
      assert.same({
        name = 'Kaban',
        image = 'kaban.png',
        msg = 'Tabenai de kudasai!',
      }, script:next())
      assert.same({
        name = 'Serval, The Serval',
        image = 'serval.png',
        font = 'jokerman',
        msg = 'Tabenai yo!',
      }, script:next())
      assert.same({
        name = 'Kaban',
        image = 'kaban.png',
        font = 'jokerman',
        msg = 'Ureshii naa!',
      }, script:next())
    end)
  end)

  describe('When using macros', function()
    it('Should be able to use macros', function()
      local script = Ero(function()
        msg "Starting Main Script"
        myMacro("First")
        myMacro("Second")
        msg "Ending Main Script"
      end)
        :addMacro('myMacro', function(val)
          msg("Inside myMacro with value: " .. val)
        end)

      assert.same({
        msg = "Starting Main Script",
      }, script:next())
      assert.same({
        msg = "Inside myMacro with value: First",
      }, script:next())
      assert.same({
        msg = "Inside myMacro with value: Second",
      }, script:next())
      assert.same({
        msg = "Ending Main Script",
      }, script:next())
      assert.same(nil, script:next())
      assert.same(false, script:hasNext())
    end)

    it('Should be able to use macros inside macros', function()
      local script = Ero(function()
        msg "Starting Main Script"
        myMacro(
          "has hairy legs.",
          "prefers dubs over subs."
        )
        msg "Ending Main Script"
      end)
        :addMacro('myMacro', function(...)
          msg("Macro started")
          for _, val in ipairs({...}) do
            mySubmacro(val)
          end
          msg("Macro ended")
        end)
        :addMacro('mySubmacro', function(val)
          msg("We need a Disney princess who " .. val)
        end)

      assert.same({
        msg = "Starting Main Script",
      }, script:next())
      assert.same({
        msg = "Macro started",
      }, script:next())
      assert.same({
        msg = "We need a Disney princess who has hairy legs.",
      }, script:next())
      assert.same({
        msg = "We need a Disney princess who prefers dubs over subs.",
      }, script:next())
      assert.same({
        msg = "Macro ended",
      }, script:next())
      assert.same({
        msg = "Ending Main Script",
      }, script:next())
      assert.same(nil, script:next())
      assert.same(false, script:hasNext())
    end)
  end)

  describe('When calling Script functions', function()
    it('Calling extendEnvironment() should add additional values to environment table', function()
      local script = Ero(function()
        local text = "I am going to marry " .. wifeName
        msg(text)
      end)
        :extendEnvironment({wifeName = 'Toromi'})

      assert.same({msg = "I am going to marry Toromi"}, script:next())
    end)
  end)
end)
