class Minigame::BMFont
  @@BMFontChar = Struct.new("Minigame::BMFont::BMFontChar",
                           :x, :y, :width, :height, :xoffset, :yoffset,
                           :xadvance, :page, :chnl)

  @@re_common = Regexp.new('^common lineHeight=([0-9]+)')
  @@re_page = Regexp.new('^page id=([0-9]+) file="([a-zA-Z0-9_.-]+)"')
  @@re_char = Regexp.new('^char +id=([0-9]+) +x=([0-9]+) +y=([0-9]+) +width=([0-9]+) +height=([0-9]+) +xoffset=([-0-9]+) +yoffset=([-0-9]+) +xadvance=([-0-9]+) +page=([0-9]+)')

  @@re_kerning = Regexp.new('^kerning +first=([0-9]+) +second=([0-9]+) +amount=([-0-9]+)')

  attr_accessor :char, :page, :kerning, :lineHeight
  def initialize
    @char = {}
    @page = []
    @kerning = {}
    @lineHeight = 0
  end

  def h
    return @lineHeight
  end

  def self.load(filepath)
    fnt = Minigame::BMFont.new

    File.open(filepath) { |file|
      while line = file.gets
        if m = @@re_char.match(line)
          c = @@BMFontChar.new
          c.x = m[2].to_i
          c.y = m[3].to_i
          c.width = m[4].to_i
          c.height = m[5].to_i
          c.xoffset = m[6].to_i
          c.yoffset = m[7].to_i
          c.xadvance = m[8].to_i
          c.page = m[9].to_i

          fnt.char[m[1].to_i] = c
        elsif m = @@re_kerning.match(line)
          if fnt.kerning[m[1].to_i] == nil
            fnt.kerning[m[1].to_i] = {m[2].to_i => m[3].to_i}
          else
            fnt.kerning[m[1].to_i][m[2].to_i] = m[3].to_i
          end
        elsif m = @@re_page.match(line)
          fnt.page[m[1].to_i] = Minigame::Image.load(File.dirname(filepath) + "/" + m[2])
        elsif m = @@re_common.match(line)
          fnt.lineHeight = m[1].to_i
        end
      end
    }

    return fnt
  end

  def draw(x, y, text, opt={})
    align = opt[:align] || opt["align"] || :left
    color = opt[:color] || opt["color"] || Minigame::Color.rgb(255, 255, 255)

    if align == :center
      x -= self.text_width(text) / 2.0
    elsif align == :right
      x -= self.text_width(text)
    end

    prev_code = 0
    amount = 0

    self.each_codepoint_from(text) do |i|
      c = @char[i]

      img = @page[c.page].sub_image(c.x, c.y, c.width, c.height)

      if first = @kerning[prev_code]
        amount = if n = first[i] then n else 0 end
      end

      img.draw(x+c.xoffset+amount, y+c.yoffset, color:color)

      x += c.xadvance + amount
      prev_code = i
    end
  end

  def text_width(text)
    width = 0
    prev_code = 0
    amount = 0
    last_xadvance = 0
    last_width = 0

    self.each_codepoint_from(text) do |i|
      c = @char[i]

      if first = @kerning[prev_code]
        amount = if n = first[i] then n else 0 end
      end

      width += c.xadvance + amount
      last_xadvance = c.xadvance
      last_width = c.width
    end

    width = width - last_xadvance + last_width

    return width
  end

  def to_image(text, color=Minigame::Color.rgb(255, 255, 255))
    img = Minigame::Image.new(self.text_width(text), self.h())

    Minigame::Image.target(img) do
      Minigame::Display.clear(Minigame::Color.rgb(0, 0, 0, 0))

      self.draw(0, 0, text, color:color)
    end

    return img
  end
end
