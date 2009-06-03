class SpriteStatus
  
  attr_accessor :name, :animation, :delay
  
  def initialize( name, animation, delay )
    @name = name
    @animation = animation
    @delay = delay
    @actual_delay = @delay
    @actual_image = animation.next
  end
  
  def image
    @actual_delay -= 1
    
    if @actual_delay <= 0
      @actual_delay = delay
      @actual_image = animation.next
    end
    
    return @actual_image.image
  end
end