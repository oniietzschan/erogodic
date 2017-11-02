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
  end)
end)
