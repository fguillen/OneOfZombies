class Hero < Sprite
  attr_reader :score, :x, :y
  attr_accessor :angle, :score, :life, :walking


  def initialize(window)
    self.warp( 0, 0 )
    @score = 0
    @angle = 0.0
    @life = Conf::HERO_LIFE
    @window = window
    @walking = false
    @image = @window.tb.sprite_images[:hero]
    @z = ZOrder::Hero
    
    super()
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    if( @walking )
      possible_x = @x + Gosu::offset_x( @angle, Conf::HERO_VELOCITY )
      possible_y = @y + Gosu::offset_y( @angle, Conf::HERO_VELOCITY )

      if !@window.map.any_touched_tile_is_not?( :walkable, possible_x, possible_y, @width/3, @height/3 )
        @x = possible_x
        @y = possible_y
      end
    
      @x = (@window.map.width*40)   if @x > (@window.map.width*40)
      @x = 0                        if @x < 0
      @y = (@window.map.height*40)  if @y > (@window.map.height*40)
      @y = 0                        if @y < 0
      
      # @window.map.tile_in( @x, @y ).visible = true
    end
  end
  
  def draw
    super
    @window.font.draw("#{@life}", @x - @window.map.x - 20 , @y - @window.map.y - 30 , @z, 1.0, 1.0, 0xffff0000)
  end
  
end