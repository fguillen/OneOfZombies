class Helicopter < Sprite
  attr_reader :score, :x, :y, :statuses
  attr_accessor :angle, :score, :life, :walking, :innocents_aboard, :status, :tile_destination


  def initialize(window)
    self.warp( 0, 0 )
    @score = 0
    @angle = -90
    @life = Conf::HERO_LIFE
    @window = window
    @walking = false
    @z = ZOrder::Helicopter
    @statuses = {}
    @statuses[:waiting] = SpriteStatus.new( @window.tb.sprite_images[:helicopter], Conf::ANIMATION_VELOCITY )
    @statuses[:going] = SpriteStatus.new( @window.tb.sprite_images[:helicopter], Conf::ANIMATION_VELOCITY )
    @statuses[:delivering] = SpriteStatus.new( @window.tb.sprite_images[:helicopter], Conf::ANIMATION_VELOCITY )
    @statuses[:comming] = SpriteStatus.new( @window.tb.sprite_images[:helicopter], Conf::ANIMATION_VELOCITY )
    @statuses[:inspection] = SpriteStatus.new( @window.tb.sprite_images[:helicopter], Conf::ANIMATION_VELOCITY )
    @status = @statuses[:inspection]
    @tile_destination = @window.map.random_walkable_tile
    @angle = Gosu::angle( @x, @y, @tile_destination.x, @tile_destination.y )
    
    @on_delivering = 0
    @tile_destination = nil
    
    @innocents_aboard = 0
    
    @velocity = Conf::HELICOPTER_VELOCITY
    
    @going_x = (@window.map.width * 40) + 100
    
    @image = @status.image
    super()
  end

  def move
    @image = @status.image
    
    if @status == @statuses[:delivering]
      @on_delivering += 1
      if @on_delivering >= Conf::HELICOPTER_DELIVERING_TIME
        @on_delivering = 0
        @innocents_aboard = 0
        if( @window.hero.status_name != 'helicopter' )
          @window.panel.add_message 'helicopter: i\'m comming'
          @status = @statuses[:comming]
        else
          @window.panel.add_message 'helicopter: i\'ll put you there again if you want'
          @status = @statuses[:inspection]
        end
        @tile_destination = @window.map.random_walkable_tile
        @angle = Gosu::angle( @x, @y, @tile_destination.x, @tile_destination.y )
      end
    end
    
    if @status == @statuses[:comming]
      if @window.map.tile_in( @x, @y ) == @tile_destination
        @window.panel.add_message 'helicopter: i\'m ready for take innocents'
        @status = @statuses[:waiting]
        @angle = -90
        if( @window.hero.status_name == 'helicopter' )
          @window.panel.add_message 'haha.. let\'s play this!!'
          
          if @window.innocents.size > 0 
            @window.panel.add_message 'helicopter: find the innocents and bring them here'
          elsif @window.zombies.size > 0 
            @window.panel.add_message 'helicopter: no more innocentes left, kill every thing it moves'
          else
            @window.panel.add_message 'helicopter: not anything here to kill or save.. maybe you wanna take a walk'
          end
          
          @window.hero.status = @window.hero.statuses[:stop]
          helicopter_tile = @window.map.tile_in( @x, @y )
          arround_tile = @window.map.tiles_walkables_arround( helicopter_tile.row, helicopter_tile.column )[0]
          @window.hero.warp( arround_tile.x, arround_tile.y )
        end
      else
        @x += Gosu::offset_x( @angle, @velocity )
        @y += Gosu::offset_y( @angle, @velocity )
      end
    end
    
    if @status == @statuses[:inspection]
      if @window.map.tile_in( @x, @y ) == @tile_destination
        @tile_destination = @window.map.random_walkable_tile
        @angle = Gosu::angle( @x, @y, @tile_destination.x, @tile_destination.y )
      end
      @x += Gosu::offset_x( @angle, @velocity )
      @y += Gosu::offset_y( @angle, @velocity )
    end
    
    if @status == @statuses[:waiting]
    end
    
    if @status == @statuses[:going]
      @angle = Gosu::angle( @x, @y, @going_x, @y )
      if @x >= @going_x
        @window.panel.add_message 'helicopter: i\'m delivering the innocents.. i\'ll be right there'
        @status = @statuses[:delivering]
      else
        @x += Gosu::offset_x( @angle, @velocity )
      end
    end
    
  end
  
  def warp(x, y)
    @x = x
    @y = y
  end
  
  def status_name
    return 'waiting'      if @status == @statuses[:waiting]
    return 'going'        if @status == @statuses[:going]
    return 'delivering'   if @status == @statuses[:delivering]
    return 'comming'      if @status == @statuses[:comming]  
    return 'inspection'   if @status == @statuses[:inspection]  
  end
end
