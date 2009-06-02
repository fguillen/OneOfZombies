class Map
  attr_reader :tiles, :width, :height, :x , :y
  
  def initialize( window )
    @window = window
    @width = 0
    @height = 0
    @tiles = []
    @x = 0
    @y = 0
  end
  
  def charge_map
    map_plain = File.read( 'map_2.txt' )
  
    map_plain.split( "\n" ).each_with_index do |row, row_index|
      @tiles[row_index] = []
      row.split( '' ).each_with_index do |column, column_index|
        @tiles[row_index] << Tile.new( @window, (column_index * 40) + 20, (row_index * 40) + 20 , column, row_index, column_index )
      end
    end
    
    @width = @tiles[0].size
    @height = @tiles.size
    
    # puts "XXX: #{@tiles.inspect}"
  end
  
  def update
    self.update_coordinates
    self.calculate_tile_values
  end
  
  
  def update_coordinates
    @x = @window.hero.x - (Conf::SCREEN_WIDTH/2)
    @y = @window.hero.y - (Conf::SCREEN_HEIGHT/2)
    
    @x = 0  if @x < 0
    @y = 0  if @y < 0
    
    @x = (@width * 40) - Conf::SCREEN_WIDTH     if @x > (@width * 40) - Conf::SCREEN_WIDTH
    @y = (@height * 40) - Conf::SCREEN_HEIGHT   if @y > (@height * 40) - Conf::SCREEN_HEIGHT
  end
  
  def draw    
    @tiles.each_with_index do |row, row_index|
      row.each_with_index do |column, column_index|
        # puts "XXX: row_index: #{row_index}, column_index: #{column_index}, element: #{@tiles[row_index][column_index]}"
        
        @tiles[row_index][column_index].draw  if @tiles[row_index][column_index].visible
      end
    end
  end
  
  def tile_in( x, y )
    if(
      x >= (@width * 40) ||
      x < 0 ||
      y >= (@height * 40) ||
      y < 0
    )
     result = nil
    else  
      # puts "@height: #{@height}"
      # puts "@width: #{@width}"
      # puts "x: #{x}"
      # puts "y: #{y}"
      result = @tiles[y/40][x/40]
    end
    
    # puts "x: #{x}, y: #{y} and result nil"  if result.nil?
    
    return result
  end
  
  def tiles_touched( x, y, width, height )
    result = []
    result << self.tile_in( x, y )
    result << self.tile_in( x, y - (height/2) ) # up
    result << self.tile_in( x + (width/2), y - (height/2) ) # up-right
    result << self.tile_in( x + (width/2), y ) # right
    result << self.tile_in( x + (width/2), y + (height/2) ) # down-right
    result << self.tile_in( x + (width/2), y ) # down
    result << self.tile_in( x - (width/2), y + (height/2) ) # down-left
    result << self.tile_in( x - (width/2), y ) # left
    result << self.tile_in( x - (width/2), y - (height/2) ) # up-left
    
    return result.compact.uniq
  end
  
  def any_touched_tile_is_not?( method, x, y, width, height )
    tiles_touched = self.tiles_touched( x, y, width, height )
    
    tiles_touched.each do |tile|
      return true  if !tile.send( method )
    end
    
    return false
  end
  
  def calculate_tile_values
    @tiles.each do |row|
      row.each do |t| 
        t.zombie_value = 0
        t.innocent_value = 0
        t.negative_innocent_value = 0
        t.helicopter_value = 0
        # t.already_proyected = false
      end
    end
    
    
    # @proyected_tiles = []
    
    hero_tile = self.tile_in( @window.hero.x, @window.hero.y )
    self.proyect_zombie_value( hero_tile, 5 )
    
    @window.innocents.each do |innocent|
      innocent_tile = self.tile_in( innocent.x, innocent.y )
      self.proyect_zombie_value( innocent_tile, 4 )
    end
    
    hero_back_postion_x, hero_back_postion_y = @window.hero.back_position
    hero_back_tile = self.tile_in( hero_back_postion_x, hero_back_postion_y )
    self.proyect_innocent_value( hero_back_tile, 5 )
    
    helicopter_tile = self.tile_in( @window.helicopter.x, @window.helicopter.y )
    self.proyect_helicopter_value( helicopter_tile, 4 )
    
    @window.zombies.each do |zombie|
      zombie_tile = self.tile_in( zombie.x, zombie.y )
      self.proyect_negative_innocent_value( zombie_tile, 3 )
    end
    
    
    # hero_tile.zombie_value = 5
    # @proyected_tiles << hero_tile
    
    
  end
  
  # def proyect_zombie_value( tile, num )
  #   num = num - 1
  #   
  #   if num > 0 # && tile.zombie_value == 0
  #     
  #     (tiles_walkables_arround( tile.row, tile.column ) - @proyected_tiles).each do |tile_arround|
  #       tile_arround.zombie_value = num  if tile_arround.zombie_value == 0
  #       if num > 1
  #         (tiles_walkables_arround( tile_arround.row, tile_arround.column ) - @proyected_tiles).each do |tile_arround_2|
  #           tile_arround_2.zombie_value = num - 1  if tile_arround_2.zombie_value == 0
  #         end
  #       end 
  #     end
  #     
  #     to_proyected_in_this_step = []
  #     
  #     (tiles_walkables_arround( tile.row, tile.column ) - @proyected_tiles).each do |tile_arround|
  #       to_proyected_in_this_step << tile_arround
  #       @proyected_tiles << tile_arround
  #     end
  #     
  #     to_proyected_in_this_step.each do |tile_to_proyect|
  #       proyect_zombie_value( tile_to_proyect, num )
  #     end
  #     
  #   end
  # end
  
  def proyect_zombie_value( tile, num )
    tile.zombie_value = num  if num > tile.zombie_value
    num = num - 1
    
    if num > 0 # && tile.value == 0
      tiles_walkables_arround( tile.row, tile.column ).each do |tile_arround|
        proyect_zombie_value( tile_arround, num )
      end
    end
  end
  
  def proyect_innocent_value( tile, num )
    return if tile.nil? 
    
    tile.innocent_value = num  if num > tile.innocent_value
    
    num = num - 1
    
    if num > 0 # && tile.value == 0
      tiles_walkables_arround( tile.row, tile.column ).each do |tile_arround|
        proyect_innocent_value( tile_arround, num )
      end
    end
  end
  
  def proyect_helicopter_value( tile, num )
    tile.helicopter_value = num  if num > tile.helicopter_value
    num = num - 1
    
    if num > 0 # && tile.value == 0
      tiles_walkables_arround( tile.row, tile.column ).each do |tile_arround|
        proyect_helicopter_value( tile_arround, num )
      end
    end
  end
  
  def proyect_negative_innocent_value( tile, num )
    tile.negative_innocent_value = num  if num > tile.negative_innocent_value
    num = num - 1
    
    if num > 0 # && tile.value == 0
      tiles_walkables_arround( tile.row, tile.column ).each do |tile_arround|
        proyect_negative_innocent_value( tile_arround, num )
      end
    end
  end
  
  def tiles_walkables_arround( row, column, corners = false )
    result = []
    result << self.get_tile_if_walkable( row - 1, column + 0 )
    result << self.get_tile_if_walkable( row - 1, column + 1 )  if corners
    result << self.get_tile_if_walkable( row + 0, column + 1 )
    result << self.get_tile_if_walkable( row + 1, column + 1 )  if corners
    result << self.get_tile_if_walkable( row + 1, column + 0 )
    result << self.get_tile_if_walkable( row + 1, column - 1 )  if corners
    result << self.get_tile_if_walkable( row + 0, column - 1 )
    result << self.get_tile_if_walkable( row - 1, column - 1 )  if corners

    return( result.compact.uniq )
  end
  
  def get_tile_if_walkable( row, column )
    if(
      row >= 0 &&
      row < self.height &&
      column >= 0 &&
      column < self.width &&
      @tiles[row][column].walkable
    )
      return @tiles[row][column]
    else
      return nil
    end
  end

end