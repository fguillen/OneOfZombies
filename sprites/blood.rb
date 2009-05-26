class Blood < Sprite
  attr_reader :x, :y
  
  def initialize(window, x, y)    
    @window = window
    @x = x + rand(10)
    @y = y + 10
    @image = @window.tb.sprite_images[:blood][rand(@window.tb.sprite_images[:blood].size)]
    @z = ZOrder::Blood
    @angle = -90
    super()
  end
  

end