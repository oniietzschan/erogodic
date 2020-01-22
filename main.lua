local Ero = require 'erogodic'
local script = Ero(function()
  name "Shopkeeper"
  msg "Thank you for rescuing my beloved tomboyish daughter!"
  local baklava = option "Delicious Baklava"
  local hamster = option "Loyal Hamster"
  menu "Select your reward"
  if selection(baklava) then
    giveItem("Baklava")
  elseif selection(hamster) then
    giveItem("Hamster")
  end
  msg "Also, take this powerful weapon!"
  giveItem("Slightly-Rusted Dwarfbane +3")
  msg "Farewell!"
end)
  :defineAttributes({
    'name',
  })
  :addMacro('giveItem', function(item)
    local lastName = get('name')
    name ""
    msg("You got the " .. item .. "!")
    name(lastName)
  end)

local Talkies = require 'demo.talkies'
Talkies.backgroundColor = {1, 1, 1, 0.2}
Talkies.textSpeed = 'medium'
Talkies.font = love.graphics.newFont(24)

local displayMessageNode

local function nextMessage()
  local node = script:next()
  displayMessageNode(node)
end

local function selectOption(selection)
  local node = script:select(selection)
  displayMessageNode(node)
end

displayMessageNode = function(node)
  if node == nil then
    return -- Erogodic script is over.
  end

  local config = {}
  if node.options then
    config.options = {}
    for i, opt in ipairs(node.options) do
      local onSelect = function()
        selectOption(opt)
      end
      config.options[i] = {opt, onSelect}
    end
  else
    config.oncomplete = nextMessage
  end
  Talkies.say(node.name, node.msg, config)
end

function love.load()
  nextMessage()
end

function love.update(dt)
  Talkies.update(dt)
end

function love.keypressed(key)
  if key == 'space' or key == 'return' or key == 'e' or key == 'z' then
    Talkies.onAction()
  elseif key == 'up' or key == 'w' then
    Talkies.prevOption()
  elseif key == 'down' or key == 's' then
    Talkies.nextOption()
  elseif key == 'escape' then
    love.event.push('quit')
  end
end

function love.draw()
  Talkies.draw()
  if Talkies.isOpen() == false then
    love.graphics.print('<Script Over>', 20, 20)
  end
end
