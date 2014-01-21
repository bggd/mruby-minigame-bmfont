mruby-minigame-bmfont
=====================

mruby-minigame-bmfont is a mruby-minigame extention that supports draw a bitmap font.

The extention can import a text(.fnt) of angelcode's BMFont format with 32bit depth png.

### Dependencies:

- mruby-minigame
- mruby-io
- mruby-hs-regexp

### Testing Platforms:

- Ubuntu 13.10
- Windows 7 + MinGW

### Example

```ruby
include Minigame

Display.create 640, 480

fnt = BMFont.load("bmfont.fnt")

Gameloop.draw do
  Display.clear
  
  fnt.draw(Display.w/2, Display.h/2, "Hello World", 'align' => :center)
end

Gameloop.run
```

