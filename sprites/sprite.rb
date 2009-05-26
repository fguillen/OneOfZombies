class Sprite
  attr_reader :height, :width
  
  def initialize
    @x ||= 0
    @y ||= 0
    @z ||= 0
    @image ||= nil
    @window ||= nil
    @angle ||= 0
    @width ||= @image.width     if @image
    @height ||= @image.height   if @image
  end
  
  def draw
    x_draw = (@x - @window.map.x)
    y_draw = (@y - @window.map.y)
    
    if(
      x_draw + (@width/2) > 0 && 
      x_draw - (@width/2) < Conf::SCREEN_WIDTH &&
      y_draw + (@height/2) > 0 && 
      y_draw - (@height/2) < Conf::SCREEN_HEIGHT
    )
      self.draw_inner( x_draw, y_draw )
    end
  end
  
  def draw_inner( x, y )
    @image.draw_rot( x, y, @z, @angle + 90 )
  end
end