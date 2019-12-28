max_line_length = false
allow_defined = false -- Do NOT allow implicitly defined globals.
allow_defined_top = false -- Do NOT allow implicitly defined globals.

globals = {
  'get',
  'menu',
  'msg',
  'name',
  'option',
  'selection',
}

files = {
  ['erogodic.lua'] = {
    std = 'luajit',
  },
  ['main.lua'] = {
    std = 'luajit+love',
    globals = {
      'giveItem',
    },
  },
  ['spec.lua'] = {
    std = 'luajit+busted',
    globals = {
      'attr',
      'characterName',
      'effect',
      'font',
      'image',
      'kaban',
      'myMacro',
      'mySubmacro',
      'serval',
      'undefinedGlobal',
      'wifeName',
    },
  },
}

exclude_files = {
  'lua_install/*', -- CI: hererocks
  'demo/*',
}