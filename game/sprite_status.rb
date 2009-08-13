class SpriteStatus
  
  attr_accessor :animation, :delay
  
  def initialize( images, delay )
    @images = images
    @delay = delay
    @actual_delay = @delay
    @step = 0
  end
  
  def image
    @actual_delay -= 1
    
    if @actual_delay <= 0
      @actual_delay = delay
      @step += 1
      # @step = 0  if @step > @images.size
    end
    
    return @images[@step % @images.size]
  end
end