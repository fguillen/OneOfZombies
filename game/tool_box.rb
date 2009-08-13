class ToolBox
  attr_reader :sprite_images, :tile_images
  
  def initialize( window )
    @window = window
    @sprite_images = self.charge_sprite_images
    @tile_images = self.charge_tiles_images
  end
  
  def charge_sprite_images
    images_array = Gosu::Image::load_tiles(@window, "#{File.dirname(__FILE__)}/media/sprite_tiles.png", 40, 40, false)

    images = {}
    images[:hero] = [ images_array[0], images_array[1] ]
    images[:zombie] = [ images_array[2], images_array[3] ]
    images[:bullet] = images_array[4]
    images[:blood] = [ images_array[6], images_array[7], images_array[8] ]
    images[:innocent1_walking] = [ images_array[12], images_array[13] ]
    images[:innocent2_walking] = [ images_array[14], images_array[15] ]
    images[:helicopter] = [ images_array[16], images_array[17] ]
    
    return images
  end

  
  def charge_tiles_images
    images_array = Gosu::Image::load_tiles(@window, "#{File.dirname(__FILE__)}/media/map_tiles.png", 40, 40, false)

    images = {}
    images[:tree] = images_array[0]
    images[:house] = images_array[1]
    
    images[:green] = [images_array[3], images_array[4], images_array[5]]
    
    return images
  end
end