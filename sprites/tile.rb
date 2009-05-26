class Tile < Sprite
  attr_reader :x, :y, :walkable, :shootable, :image
  attr_accessor :visible
  
  def initialize( window, x, y, type )
    @x = x
    @y = y
    @window = window
    @angle = -90
    @visible = true
    
    if type == ' '
      @image = @window.tb.tile_images[:green][rand(@window.tb.tile_images[:green].size)]
      @walkable = true
      @shootable = true
    elsif type == '1'
      @image = @window.tb.tile_images[:house]
      @walkable = false
      @shootable = false
    elsif type == '2'
      @image = @window.tb.tile_images[:tree]
      @walkable = false
      @shootable = true
    else
      raise "Bad tile type: #{type}"
    end
    
    super()
  end

end