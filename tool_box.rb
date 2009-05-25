class ToolBox
  attr_reader :sprite_images, :tile_images
  
  def initialize( window )
    @window = window
    @sprite_images = self.charge_sprite_images
    @tile_images = self.charge_tiles_images
  end
  
  def charge_sprite_images
    images_array = Gosu::Image::load_tiles(@window, "media/sprite_tiles.png", 40, 40, false)

    images = {}
    images[:hero] = images_array[0]
    images[:zombie] = images_array[1]
    images[:bullet] = images_array[2]
    images[:blood] = [ images_array[3], images_array[4], images_array[5] ]
    
    return images
  end
  
  def charge_tiles_images
    images_array = Gosu::Image::load_tiles(@window, "media/map_tiles.png", 40, 40, false)

    images = {}
    images[:tree] = images_array[0]
    images[:house] = images_array[1]
    images[:green] = images_array[2]
    
    return images
  end
end