
class Tile
  attr_accessor  :row, :column, :content, :value
  
  def initialize( row, column, content )
    @row = row
    @column = column
    @content = content
    @value = 0
  end
end

class DiffusionTest
  
  def initialize
    @map = [
      "   X               X       ",
      "                        X  ",
      "    XXX   X                ",
      "     X                 X   ",
      "     X     X               ",
      "            XXXXX          ",
      "             XX            ",
      "             XX            ",
      "               X           "
    ]
    
    @map_clean = [
      "                           ",
      "                           ",
      "                           ",
      "                           ",
      "                           ",
      "                           ",
      "                           ",
      "                           ",
      "                           "
    ]

    @height = @map.size
    @width = @map[0].size
    
    @steps = 0
    
    @tiles = []
    
    @map_clean.each_with_index do |row, row_index|
      @tiles[row_index] = []
      row.split( '' ).each_with_index do |value, column_index|
        @tiles[row_index] << Tile.new( row_index, column_index, value )
      end
    end

    @x = 12
    @y = 4
  end
  
  def go
    self.print_map
    self.calculate_value
    puts "steps: #{@steps}"
  end
  
  def print_map
    (0..(@height-1)).each do |row|
      (0..(@width-1)).each do |column|
        print @tiles[row][column].content   if @tiles[row][column].content != ' '
        print @tiles[row][column].value     if @tiles[row][column].content == ' '
      end
      print "\n"
    end
    
    print "\n"
  end
  
  def calculate_value
    (0..(@height-1)).each do |row|
      (0..(@width-1)).each do |column|
        @tiles[row][column].value = 0
      end
    end
        
    @touched_tiles = []
    initial_tile = @tiles[@y][@x]
        
    self.proyect_value_2( initial_tile, 5 )
  end
  
  def proyect_value( tile, num )
    @steps += 1
    
    num = num - 1
    
    puts "row: #{tile.row}, column: #{tile.column}, num: #{num}"
    
    if num > 0 # && tile.value == 0
      self.print_map
      (tiles_walkables_arround( tile.row, tile.column ) - @touched_tiles).each do |tile_arround|
        tile_arround.value = num  if tile_arround.value == 0
        if num > 1
          (tiles_walkables_arround( tile_arround.row, tile_arround.column ) - @touched_tiles).each do |tile_arround_2|
            tile_arround_2.value = num - 1  if tile_arround_2.value == 0
          end
        end 
      end
      
      to_proyected_in_this_step = []
      
      (tiles_walkables_arround( tile.row, tile.column ) - @touched_tiles).each do |tile_arround|
        to_proyected_in_this_step << tile_arround
        @touched_tiles << tile_arround
      end
      
      to_proyected_in_this_step.each do |tile_to_proyect|
        proyect_value( tile_to_proyect, num )
      end
      
    end
  end
  
  def proyect_value_2( tile, num )
    @steps += 1
    puts "row: #{tile.row}, column: #{tile.column}, num: #{num}"
    tile.value = num  if num > tile.value
    # @touched_tiles << tile
    num = num - 1
    
    if num > 0 # && tile.value == 0
      (tiles_walkables_arround( tile.row, tile.column ) - @touched_tiles).each do |tile_arround|
        proyect_value_2( tile_arround, num )  if tile_arround.value < num
      end
    end
    
    self.print_map
  end
  
  
  def tiles_walkables_arround( row, column )
    result = []
    result << self.get_tile_if_walkable( row - 1, column + 0 )
    # result << self.get_tile_if_walkable( row - 1, column + 1 )
    result << self.get_tile_if_walkable( row + 0, column + 1 )
    # result << self.get_tile_if_walkable( row + 1, column + 1 )
    result << self.get_tile_if_walkable( row + 1, column + 0 )
    # result << self.get_tile_if_walkable( row + 1, column - 1 )
    result << self.get_tile_if_walkable( row + 0, column - 1 )
    # result << self.get_tile_if_walkable( row - 1, column - 1 )

    result = result.compact.uniq 
    puts "tiles_walkables_arround.result: #{result.size}"
    return result
  end
  
  def get_tile_if_walkable( row, column )
    if(
      row >= 0 &&
      row < @height &&
      column >= 0 &&
      column < @width &&
      @tiles[row][column].content != 'X'
    )
      result = @tiles[row][column]
    else
      result = nil
    end
    
    puts "row: #{row}, column: #{column}, result: #{result}"
    
    return result
  end
end

dt = DiffusionTest.new
dt.go