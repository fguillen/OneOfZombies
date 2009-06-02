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
    x_draw = (@x - @window.map.x).to_i
    y_draw = (@y - @window.map.y).to_i
    
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
    factor_y = 1
    angle = @angle + 90
    
    if angle <= 270 && angle > 0
      factor_y = -1
      angle = angle - 180
    end
    
    @image.draw_rot( x, y, @z, angle, 0.5, 0.5, factor_y )
  end
  
  def back_position
    angle = @angle
    
    if angle < 225 && angle > 180
      angle = angle - 180
    end
    
    x = @x + Gosu::offset_x( angle - 180, 40 )
    y = @y + Gosu::offset_y( angle - 180, 40 )
    
    return x, y
  end
end