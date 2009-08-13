class Hero < Sprite
  attr_reader :score, :x, :y, :statuses
  attr_accessor :angle, :score, :life, :walking, :status


  def initialize(window)
    self.warp( 0, 0 )
    @score = 0
    @angle = 0.0
    @life = Conf::HERO_LIFE
    @window = window
    @z = ZOrder::Hero
    @statuses = {}
    @statuses[:walking] = SpriteStatus.new( @window.tb.sprite_images[:hero], Conf::ANIMATION_VELOCITY )
    @statuses[:stop] = SpriteStatus.new( [@window.tb.sprite_images[:hero][0]], Conf::ANIMATION_VELOCITY )
    @statuses[:helicopter] = SpriteStatus.new( [@window.tb.sprite_images[:hero][0]], Conf::ANIMATION_VELOCITY )
    @statuses[:died] = SpriteStatus.new( @window.tb.sprite_images[:zombie], Conf::ANIMATION_VELOCITY )
    @status = @statuses[:helicopter]
    @image = @status.image
    super()
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    @image = @status.image
    
    if( @status == @statuses[:walking] )
      possible_x = @x + Gosu::offset_x( @angle, Conf::HERO_VELOCITY )
      possible_y = @y + Gosu::offset_y( @angle, Conf::HERO_VELOCITY )

      if !@window.map.any_touched_tile_is_not?( :walkable, possible_x, possible_y, @width/3, @height/3 )
        @x = possible_x
        @y = possible_y
      end
    
      @x = (@window.map.width*40) -1    if @x > (@window.map.width*40) - 1
      @x = 0                            if @x < 0
      @y = (@window.map.height*40) -1   if @y > (@window.map.height*40) - 1
      @y = 0                            if @y < 0
      
      # @window.map.tile_in( @x, @y ).visible = true
    end
    
    if( @status == @statuses[:helicopter] )
      @x = @window.helicopter.x
      @y = @window.helicopter.y
    end
  end
  
  def draw
    super  if @status != @statuses[:helicopter]
    if( @window.admin.admin_show_life )
      @window.font.draw("#{@life}", @x - @window.map.x - 20 , @y - @window.map.y - 30 , @z, 1.0, 1.0, 0xffff0000)
    end
  end
  
  def status_name
    return 'stop'         if @status == @statuses[:stop]
    return 'walking'      if @status == @statuses[:walking]
    return 'helicopter'   if @status == @statuses[:helicopter]
    return 'died'         if @status == @statuses[:died]
  end
  
  def convert_to_zombie
    zombie = Zombie.new( @window )
    zombie.warp( @x, @y )
    
    return zombie
  end
end