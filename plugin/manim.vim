if exists('g:loaded_manim_plugin')
  finish
endif
let g:loaded_manim_plugin = 1
lua require('manim_plugin')
