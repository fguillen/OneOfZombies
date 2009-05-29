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
    map_plain = File.read( 'map.txt' )
  
    map_plain.split( "\n" ).each_with_index do |row, row_index|
      @tiles[row_index] = []
      row.split( '' ).each_with_index do |column, column_index|
        @tiles[row_index] << Tile.new( @window, (column_index * 40) + 20, (row_index * 40) + 20 , column )
      end
    end
    
    @width = @tiles[0].size
    @height = @tiles.size
    
    # puts "XXX: #{@tiles.inspect}"
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
    self.update_coordinates
    
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
     return nil
    else  
      # puts "@height: #{@height}"
      # puts "@width: #{@width}"
      # puts "x: #{x}"
      # puts "y: #{y}"
      return @tiles[y/40][x/40]
    end
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
end