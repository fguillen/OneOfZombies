class Helicopter < Sprite
  attr_reader :score, :x, :y
  attr_accessor :angle, :score, :life, :walking


  def initialize(window)
    self.warp( 0, 0 )
    @score = 0
    @angle = -90
    @life = Conf::HERO_LIFE
    @window = window
    @walking = false
    @image = @window.tb.sprite_images[:helicopter]
    @z = ZOrder::Hero
    
    super()
  end

  def warp(x, y)
    @x = x
    @y = y
  end
end
