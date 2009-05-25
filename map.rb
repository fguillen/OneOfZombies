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
  
    map_plain.split( "\n" ).each_with_index do |line, index|
      @tiles[index] = []
      line.split( '' ).each do |column|
        @tiles[index] << column
      end
    end
    
    @width = @tiles[0].size
    @height = @tiles.size
  end
  
  def update_coordinates
    @x = @window.hero.x - (Conf::SCREEN_WIDTH/2)
    @y = @window.hero.y - (Conf::SCREEN_HEIGHT/2)
    
    @x = 0  if @x < 0
    @y = 0  if @y < 0
    
    @x = (@width * 40) - Conf::SCREEN_WIDTH  if @x > (@width * 40) - Conf::SCREEN_WIDTH
    @y = (@height * 40) - Conf::SCREEN_HEIGHT if @y > (@height * 40) - Conf::SCREEN_HEIGHT
  end
  
  def draw
    self.update_coordinates
    
    @tiles.each_with_index do |line, line_index|
      line.each_with_index do |column, column_index|
        if(
          (column_index * 40) - @x > -40 && 
          (column_index * 40) - @x < Conf::SCREEN_WIDTH &&
          (line_index * 40) - @y > -40 && 
          (line_index * 40) - @y < Conf::SCREEN_HEIGHT
        )
          image = @window.tb.tile_images[:tree]   if column == '1'
          image = @window.tb.tile_images[:house]  if column == '2'
          image = @window.tb.tile_images[:green]  if column == ' '
          image.draw( (column_index * 40) - @x, (line_index * 40) - @y, ZOrder::Background )
        end
      end
    end
  end
end