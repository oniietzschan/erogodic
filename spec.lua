require 'busted'

local ErogodicModule = require 'erogodic'

describe('Terebi:', function()
  local Ero

  before_each(function()
    Ero = ErogodicModule()
  end)

  describe('When executing script', function()
    it('Should have expected output', function()
      local script = Ero(function()
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

    it('Looping should be possible', function()
      local script = Ero(function()
        while true do
          option "What does a wanko say?"
          option "What does a nyanko say?"
          option "I already know a ton about animal sounds."
          menu "Make your selection, now."
          if selection() == "What does a wanko say?" then
            msg "Wan! Wan!"
          elseif selection() == "What does a nyanko say?" then
            msg "Nya! Nyan!"
          elseif selection() == "I already know a ton about animal sounds." then
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
        ::redo::
        if player.hatted == false then
          option "Put on a dapper hat."
        else
          option "Say: \"I am the supreme gentleman.\""
        end
        option "Give the world it's retribution."
        menu ""
        if selection() == "Put on a dapper hat." then
          player.hatted = true
          msg "You put on a dapper hat. It fits perfectly and you look fucking brilliant."
          goto redo
        elseif selection() == "Say: \"I am the supreme gentleman.\"" then
          msg "You assert your status as a conscious agent in the universe."
        elseif selection() == "Give the world it's retribution." then
          msg "What was seen can never be unseen, and I will never forget it, nor will I forgive it."
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

    it('Invalid scripts should relay error message', function()
      local script = Ero(function()
        msg(undefinedGlobal.undefinedKey)
      end)
      local expectedError = "Error executing script: spec.lua:153: attempt to index global 'undefinedGlobal' (a nil value)"
      assert.has_error(function() script:next() end, expectedError)
    end)
  end)

  describe('When prompted with a choice', function()
    it('It should not be possible to skip it', function()
      local script = Ero(function()
        option "Yes"
        menu "Would you like to pay your taxes?"
        if selection() == "Yes" then
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
