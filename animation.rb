class Animation
  def initialize( images )
    animation_images = []
    
    images.each do |image|
      animation_images << AnimationImage.new( image )
    end
    
    animation_images.each_with_index do |animation_image, index|
      if animation_image == animation_images.last
        animation_image.image_next = animation_images.first
      else
        animation_image.image_next = animation_images[index+1]
      end
    end
    
    @actual_image = animation_images.first
  end
  
  def next
    @actual_image = @actual_image.image_next
    
    return @actual_image
  end
end

class AnimationImage
  attr_reader :image
  attr_accessor :image_next
  
  def initialize( image, image_next = nil )
    @image = image
    @image_next = image_next
  end
  
  
end