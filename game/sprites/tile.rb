class Tile < Sprite
  attr_reader :x, :y, :walkable, :shootable, :image, :row, :column
  attr_accessor :visible, :zombie_value, :innocent_value, :already_proyected, :negative_innocent_value
  attr_accessor :helicopter_value
  
  def initialize( window, x, y, type, row, column )
    @x = x
    @y = y
    @window = window
    @angle = -90
    @visible = true
    @zombie_value = 0
    @innocent_value = 0
    @negative_innocent_value = 0
    @helicopter_value = 0
    @row = row
    @column = column
    @already_proyected = false
    
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

  # def draw_inner( x, y )
  #   super
  #   @window.font_small.draw("#{@zombie_value}", x, y-10, ZOrder::UI, 1.0, 1.0, 0xffff0000)
  #   @window.font_small.draw("#{self.total_innocent_value}", x, y, ZOrder::UI, 1.0, 1.0, 0xff00ff00)
  # end
  
  def draw_inner( x, y )
    if( @window.admin.admin_show_info )
      @color = Gosu::Color.new(0xff000000)
      @color.red = 255 * @zombie_value / 8
      @color.green = (255 * (self.total_innocent_value+4) / 14)
      @color.blue = 0
    
      @image.draw(
        x - @image.width / 2.0, 
        y - @image.height / 2.0,
        @z, 
        1, 
        1, 
        @color, 
        :additive
      )
    
    
      @window.font_small.draw("#{@zombie_value}", x, y-10, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @window.font_small.draw("#{self.total_innocent_value}", x, y, ZOrder::UI, 1.0, 1.0, 0xff00ff00)
    else
      super
    end
  end
  
  def total_innocent_value
    self.innocent_value - self.negative_innocent_value + (self.helicopter_value*2)
  end
end