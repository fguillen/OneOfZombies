begin
  require 'rubygems'
rescue LoadError
end

require 'gosu'

require 'tool_box'
require 'map'
require 'sprites/sprite'
require 'sprites/blood'
require 'sprites/bullet'
require 'sprites/zombie'
require 'sprites/hero'
require 'sprites/helicopter'
require 'sprites/innocent'
require 'sprites/tile'




module ZOrder
  Background = 0
  Blood = 1
  Hero = 2
  UI = 3
end

module Conf
  HERO_VELOCITY = 3
  HERO_LIFE = 50
  BULLET_VELOCITY = 15
  BULLET_RETROCESO = 5
  BULLET_LAPSUS = 5
  ZOMBIE_VELOCITY = 1
  ZOMBIE_TURN_VELOCITY = 25
  ZOMBIE_TURN_DECISION = 10
  ZOMBIE_LIFE = 5
  ZOMBIE_SAW = 200
  ZOMBIE_REPRODUCTION = 100
  ZOMBIE_BITE_VELOCITY = 10 
  NUM_ZOMBIES = 20
  SCREEN_WIDTH = 600
  SCREEN_HEIGHT = 400
  INNOCENT_LIFE = 4
  INNOCENT_VELOCITY = HERO_VELOCITY 
  INNOCENT_SAW = 200
  NUM_INNOCENTS = 30
end









class Game < Gosu::Window
  attr_accessor :bullets
  attr_reader :font, :font_small, :hero, :image_zombie, :image_bullet, :tb, :map, :innocents, :zombies
  attr_reader :helicopter
  
  
  def initialize
    super(Conf::SCREEN_WIDTH, Conf::SCREEN_HEIGHT, false)
    self.caption = "One Of Zombies Game"
    
    @bullet_lapsus = 0
    
    @tb = ToolBox.new( self )
    
    @map = Map.new( self )
    @map.charge_map
    
    
    @beep = Gosu::Sample.new(self, "media/Beep.wav")
    @shoot = Gosu::Sample.new(self, "media/shoot.mp3")
    @zombie_eaten = Gosu::Sample.new(self, "media/zombie_eaten_2.wav")
    @helicopter_get_an_innocent = Gosu::Sample.new(self, "media/helicopter_get_an_innocent.wav")
    @explosion = Gosu::Sample.new(self, "media/Explosion.wav")
    @aahhh = Gosu::Sample.new(self, "media/aahhh.wav")
    
    
    @hero = self.initialize_hero
    @helicopter = self.initialize_helicopter


    @zombies = self.initialize_zombies( Conf::NUM_ZOMBIES )
    @innocents = self.initialize_innocents( Conf::NUM_INNOCENTS )
    @bullets = []
    @bloods = []
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
    @font_small = Gosu::Font.new(self, Gosu::default_font_name, 10)
    
    @milliseconds_before = Gosu::milliseconds
    @fps = 0
    @frames_counter = 0
    
    @innocents_saved = 0
    
    @pause = false
  end
  
  def initialize_hero
    hero = Hero.new(self)
    hero.warp( (Conf::SCREEN_WIDTH / 2) , (Conf::SCREEN_HEIGHT / 2) )
    
    while( self.map.any_touched_tile_is_not?( :walkable, hero.x, hero.y, hero.width, hero.height ) ) do
      hero.warp( rand(self.map.width*40), rand(self.map.height*40) )
    end
    
    return hero
  end
  
  def initialize_helicopter
    helicopter = Helicopter.new(self)
    helicopter.warp( (Conf::SCREEN_WIDTH / 2) , (Conf::SCREEN_HEIGHT / 2) )
    
    while( self.map.any_touched_tile_is_not?( :walkable, helicopter.x, helicopter.y, helicopter.width, helicopter.height ) ) do
      helicopter.warp( rand(self.map.width*40), rand(self.map.height*40) )
    end
    
    return helicopter
  end

  def initialize_zombies( num )
    zombies = []

    while( zombies.size < num ) do
      x = rand(self.map.width*40)
      y = rand(self.map.height*40)

      if !self.map.any_touched_tile_is_not?( :walkable, x, y, 30, 30 )
        zombie = Zombie.new(self)
        zombie.warp( x, y )
        zombies << zombie
      end
    end
    
    return zombies
  end
  
  def initialize_innocents( num )
    innocents = []

    while( innocents.size < num ) do
      x = rand(self.map.width*40)
      y = rand(self.map.height*40)

      if !self.map.any_touched_tile_is_not?( :walkable, x, y, 30, 30 )
        innocent = Innocent.new(self)
        innocent.warp( x, y )
        innocents << innocent
      end
    end
    
    return innocents
  end

  def update
    return  if @pause
    
    @frames_counter += 1
    if Gosu::milliseconds - @milliseconds_before >= 1000
      @fps = @frames_counter.to_f / ((Gosu::milliseconds - @milliseconds_before) / 1000.0)
      @frames_counter = 0
      @milliseconds_before = Gosu::milliseconds
    end
    
    @bullet_lapsus -= 1  if @bullet_lapsus > 0
    
    if button_down? Gosu::Button::KbUp then
      @hero.angle = 0.0
    end
    
    if button_down? Gosu::Button::KbDown then
      @hero.angle = 180.0
    end
    
    if button_down? Gosu::Button::KbLeft then
      @hero.angle = 270.0
    end
    
    if button_down? Gosu::Button::KbRight then
      @hero.angle = 90.0
    end
    
    if button_down?( Gosu::Button::KbRight ) && button_down?( Gosu::Button::KbDown )
      @hero.angle = 135.0
    end
    
    if button_down?( Gosu::Button::KbRight ) && button_down?( Gosu::Button::KbUp )
      @hero.angle = 45.0
    end
    
    if button_down?( Gosu::Button::KbLeft ) && button_down?( Gosu::Button::KbDown )
      @hero.angle = 225.0
    end
    
    if button_down?( Gosu::Button::KbLeft ) && button_down?( Gosu::Button::KbUp )
      @hero.angle = 315.0
    end
    
    if(
      button_down?( Gosu::Button::KbRight ) ||
      button_down?( Gosu::Button::KbLeft ) ||
      button_down?( Gosu::Button::KbDown ) ||
      button_down?( Gosu::Button::KbUp )
    )
      @hero.walking = true
    else
      @hero.walking = false
    end
    
    if( (button_down? Gosu::Button::KbSpace) && (@bullet_lapsus == 0) )
      @shoot.play
      bullet = Bullet.new( self )
      bullet.warp( @hero.x, @hero.y )
      bullet.shoot( @hero.angle )
      @bullets << bullet
      @bullet_lapsus = Conf::BULLET_LAPSUS
    end
    
    @hero.move
    @zombies.each { |zombie| zombie.move }
    @bullets.each { |bullet| bullet.move }
    @innocents.each { |innocent| innocent.move }
    @map.update
    
    # @zombies += initialize_zombies( rand(3) )  if rand(Conf::ZOMBIE_REPRODUCTION) == 0
    
    self.colisions
  end
  
  def colisions
    @bullets.each do |bullet|
      @zombies.each do |zombie|
        if Gosu::distance(bullet.x, bullet.y, zombie.x, zombie.y) < 10 then
          @hero.score += 10
          @beep.play
          @bullets.delete( bullet )
          
          zombie.life -= 1
          
          zombie.retroceso( bullet.angle )
          
          if zombie.life <= 0 
            @hero.score += 40
            @explosion.play
            
            @zombies.delete zombie
          end
          
          # blood
          @bloods << Blood.new( self, zombie.x, zombie.y )
        end
      end
      
      @innocents.each do |innocent|
        if Gosu::distance(bullet.x, bullet.y, innocent.x, innocent.y) < 10 then
          @hero.score -= 10
          @beep.play
          @bullets.delete( bullet )
          
          innocent.life -= 1
          
          innocent.retroceso( bullet.angle )
          
          if innocent.life <= 0 
            @hero.score -= 40
            @explosion.play
            
            @innocents.delete innocent
          end
          
          # blood
          @bloods << Blood.new( self, innocent.x, innocent.y )
        end
      end
    end
    
    @zombies.each do |zombie|
      if zombie.bite <= 0 
        if Gosu::distance(@hero.x, @hero.y, zombie.x, zombie.y) < 10 then
          @hero.life -= 1
          @zombie_eaten.play
          zombie.bite = Conf::ZOMBIE_BITE_VELOCITY
        end
      
        @innocents.each do |innocent|
          if Gosu::distance(innocent.x, innocent.y, zombie.x, zombie.y) < 20 then
            innocent.life -= 1
          
            if innocent.life <= 0
              @aahhh.play
              @zombies << innocent.convert_to_zombie
              @innocents.delete innocent
            else
              @zombie_eaten.play
            end
            
            zombie.bite = Conf::ZOMBIE_BITE_VELOCITY
          end
        end
      end
    end
    
    @innocents.each do |innocent|
      if Gosu::distance(@helicopter.x, @helicopter.y, innocent.x, innocent.y) < 40 then
        @innocents_saved += 1
        @helicopter_get_an_innocent.play
        @innocents.delete innocent
      end
    end
  end

  def draw
    @map.draw
    @hero.draw
    @helicopter.draw
    @zombies.each { |zombie| zombie.draw }
    @bullets.each { |bullet| bullet.draw }
    @bloods.each { |blood| blood.draw }
    @innocents.each { |innocent| innocent.draw }
    
    @font.draw("Score: #{@hero.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Angle: #{@hero.angle}", 10, 25, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Bullets: #{@bullets.size}", 10, 40, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Zombies: #{@zombies.size}", 10, 55, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Innocents: #{@innocents.size}", 10, 70, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("FPS: #{@fps}", 10, 85, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Innocents S: #{@innocents_saved}", 10, 100, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Pause: #{@pause}", 10, 115, ZOrder::UI, 1.0, 1.0, 0xffff0000)
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
    
    if id == Gosu::Button::KbP then
      @pause = !@pause
    end
  end
end

window = Game.new
window.show