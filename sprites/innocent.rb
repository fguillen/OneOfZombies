class Innocent < Sprite
  attr_reader :x, :y
  attr_accessor :life
  
  def initialize(window)
    self.warp(0,0)
    @angle = rand( (360 * 2) + 1 ) - 360 
    @life = rand(Conf::INNOCENT_LIFE) + 1
    @window = window
    @image = @window.tb.sprite_images[:innocent][rand(@window.tb.sprite_images[:innocent].size)]
    @z = ZOrder::Hero
    @velocity = rand() * Conf::INNOCENT_VELOCITY
    
    super() 
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    
    if self.see_hero?
      x, y = self.hero_back_position
      @angle = Gosu::angle(@x, @y, x, y)
    else
      if rand(Conf::ZOMBIE_TURN_DECISION) == 0
        @angle += rand( (Conf::ZOMBIE_TURN_VELOCITY * 2) + 1 ) - Conf::ZOMBIE_TURN_VELOCITY
      end
    end
      
    possible_x = @x + Gosu::offset_x( @angle, @velocity )
    possible_y = @y + Gosu::offset_y( @angle, @velocity )
    
    if !@window.map.any_touched_tile_is_not?( :walkable, possible_x, possible_y, @width/3, @height/3 )
      @x = possible_x
      @y = possible_y
    end
    
    @x = (@window.map.width*40) -1    if @x > (@window.map.width*40) - 1
    @x = 0                            if @x < 0
    @y = (@window.map.height*40) -1   if @y > (@window.map.height*40) - 1
    @y = 0                            if @y < 0
    
    # se da la vuelta
    if(
      @x > (@window.map.width * 40) ||
      @x < 0 ||
      @y > (@window.map.height * 40) ||
      @y < 0
    ) 
      @angle += 90
    end
  end
  
  def retroceso( angle )
    @x += Gosu::offset_x( angle, Conf::BULLET_RETROCESO )
    @y += Gosu::offset_y( angle, Conf::BULLET_RETROCESO )
  end

  def see_hero?
    Gosu::distance(@x, @y, @window.hero.x, @window.hero.y) < Conf::INNOCENT_SAW
  end
  

  
  def draw_inner( x, y )
    super
    @window.font.draw("#{life}", x - 20 , y - 30 , @z, 1.0, 1.0, 0xffff0000)
  end
  
  def more_valuable_arround_tile
    innocent_tile = @window.map.tile_in( @x, @y )
    
    total_tiles = @window.map.tiles_walkables_arround( innocent_tile.row, innocent_tile.column, false )
    total_tiles << innocent_tile
    total_tiles.sort!{ |a,b| b.total_innocent_value <=> a.total_innocent_value }
    
    if total_tiles.first.total_innocent_value == total_tiles.last.total_innocent_value
      result = nil
    else
      result = total_tiles.first
    end
    
    return result
  end

  def move
    tile_to_go = self.more_valuable_arround_tile
    
    if tile_to_go.nil?
      if rand(Conf::ZOMBIE_TURN_DECISION) == 0
        @angle += rand( (Conf::ZOMBIE_TURN_VELOCITY * 2) + 1 ) - Conf::ZOMBIE_TURN_VELOCITY
      end
    else
      if( tile_to_go != @window.map.tile_in( @x, @y ) )
        @angle = Gosu::angle( @x, @y, tile_to_go.x, tile_to_go.y )
      end
    end
    
    possible_x = @x + Gosu::offset_x( @angle, @velocity )
    possible_y = @y + Gosu::offset_y( @angle, @velocity )
    
    if !@window.map.any_touched_tile_is_not?( :walkable, possible_x, possible_y, @width/3, @height/3 )
      @x = possible_x
      @y = possible_y
    end
    
    @x = (@window.map.width*40) -1    if @x > (@window.map.width*40) - 1
    @x = 0                            if @x < 0
    @y = (@window.map.height*40) -1   if @y > (@window.map.height*40) - 1
    @y = 0                            if @y < 0
  end
  
  # def move
  #   
  #   if self.see_hero?
  #     x, y = self.hero_back_position
  #     @angle = Gosu::angle(@x, @y, x, y)
  #   else
  #     if rand(Conf::ZOMBIE_TURN_DECISION) == 0
  #       @angle += rand( (Conf::ZOMBIE_TURN_VELOCITY * 2) + 1 ) - Conf::ZOMBIE_TURN_VELOCITY
  #     end
  #   end
  #     
  #   possible_x = @x + Gosu::offset_x( @angle, @velocity )
  #   possible_y = @y + Gosu::offset_y( @angle, @velocity )
  #   
  #   if !@window.map.any_touched_tile_is_not?( :walkable, possible_x, possible_y, @width/3, @height/3 )
  #     @x = possible_x
  #     @y = possible_y
  #   end
  #   
  #   @x = (@window.map.width*40) -1    if @x > (@window.map.width*40) - 1
  #   @x = 0                            if @x < 0
  #   @y = (@window.map.height*40) -1   if @y > (@window.map.height*40) - 1
  #   @y = 0                            if @y < 0
  #   
  #   # se da la vuelta
  #   if(
  #     @x > (@window.map.width * 40) ||
  #     @x < 0 ||
  #     @y > (@window.map.height * 40) ||
  #     @y < 0
  #   ) 
  #     @angle += 90
  #   end
  # end

  def convert_to_zombie
    zombie = Zombie.new( @window )
    zombie.warp( @x, @y )
    
    return zombie
  end
end