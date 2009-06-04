class Zombie < Sprite
  attr_reader :x, :y
  attr_accessor :life, :bite
  
  def initialize(window)
    self.warp(0,0)
    @angle = rand( (360 * 2) + 1 ) - 360 
    @life = rand(Conf::ZOMBIE_LIFE) + 1
    @window = window
    @z = ZOrder::Hero
    @velocity = rand() * Conf::ZOMBIE_VELOCITY
    @bite = Conf::ZOMBIE_BITE_VELOCITY
    @status = SpriteStatus.new( @window.tb.sprite_images[:zombie], Conf::ANIMATION_VELOCITY )
    @image = @status.image
    super() 
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  
  def more_valuable_arround_tile
    zombie_tile = @window.map.tile_in( @x, @y )
    
    return nil  if zombie_tile.nil?
    
    total_tiles = @window.map.tiles_walkables_arround( zombie_tile.row, zombie_tile.column, false )
    total_tiles << zombie_tile
    total_tiles.sort!{ |a,b| b.zombie_value <=> a.zombie_value }
    
    if total_tiles.first.zombie_value == total_tiles.last.zombie_value
      result = nil
    else
      result = total_tiles.first
    end
    
    return result
  end

  def move
    @image = @status.image
    
    @bite -= 1  if @bite > 0
    
    
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
  #   if self.see_hero?
  #     @angle = Gosu::angle(@x, @y, @window.hero.x, @window.hero.y)
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
  
  def retroceso( angle )
    @x += Gosu::offset_x( angle, Conf::BULLET_RETROCESO )
    @y += Gosu::offset_y( angle, Conf::BULLET_RETROCESO )
  end

  def see_hero?
    Gosu::distance(@x, @y, @window.hero.x, @window.hero.y) < Conf::ZOMBIE_SAW
  end
  
  def draw_inner( x, y )
    super
    if( @window.admin.admin_show_life )
      @window.font.draw("#{life}", x - 20 , y - 30 , @z, 1.0, 1.0, 0xffff0000)
    end
  end
  
  def status_name
    return 'died'
  end

end