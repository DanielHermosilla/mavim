# Mavim  

A Neovim plugin to integrate `manim` and `manim-slides`. It provides three user commands that run `Manim` or `manim-slides` in the background and notify you on start, success, or failure.

## Features

- **`:ManimRender [quality] <Scene1> [Scene2 …]`**  
  Renders one or more Manim scene classes from your current buffer’s `.py` file.  
  - **quality** (optional): pass flags like `-pqh` (high quality), `-pql` (low quality), etc.  
  - Automatically builds and runs:  
    ```bash
    manim [quality] --media_dir media/videos myfile.py Scene1 Scene2 …
    ```  

- **`:ManimSlidesRender <Slide1> [Slide2 …]`**  
  Uses the `manim-slides render` subcommand to generate slide bundles (JSON) for one or more slide classes in your file.
```bash
  manim-slides render myfile.py Slide1 Slide2 …
```

- **`:ManimSlidesPresent <Slide1> [Slide2 ...]`**
Launches the `manim-slides present` command in the background

```bash
manim-slides present Slide1 [Slide2 ...]
```

## Installation

```lua
{
  'DanielHermosilla/mavim',
  ft = 'python',
  config = function()
    require('manim_plugin').setup {
      manim_executable        = 'manim',
      manim_slides_executable = 'manim-slides',
      build_dir               = 'media/videos',
      default_quality         = '-pqh',
    }
  end
}
```

> Note: This plugin is prone to a lot of errors. It is still in development. 
> TODO: An object browser
