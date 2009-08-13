class Bullet < Sprite
  attr_reader :x, :y, :angle
  
  def initialize(window)
    @window = window
    self.warp(0,0)
    self.shoot(0.0)
    @image = @window.tb.sprite_images[:bullet]
    @z = ZOrder::Hero
    super()
  end
  
  def shoot( angle )
    @angle = angle
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    @x += Gosu::offset_x( @angle, Conf::BULLET_VELOCITY )
    @y += Gosu::offset_y( @angle, Conf::BULLET_VELOCITY )
    
    if(
      @x > (@window.map.width * 40) ||
      @x < 0 ||
      @y > (@window.map.height * 40) ||
      @y < 0 ||
      @window.map.any_touched_tile_is_not?( :shootable, x, y, 3, 3 )
    ) 
      @window.bullets.delete( self )
    end
  end
  
end