begin
  require 'rubygems'
rescue LoadError
end

require 'gosu'

require "#{File.dirname(__FILE__)}/animation"
require "#{File.dirname(__FILE__)}/tool_box"
require "#{File.dirname(__FILE__)}/map"
require "#{File.dirname(__FILE__)}/panel"

require "#{File.dirname(__FILE__)}/sprite_status"
require "#{File.dirname(__FILE__)}/sprites/sprite"
require "#{File.dirname(__FILE__)}/sprites/blood"
require "#{File.dirname(__FILE__)}/sprites/bullet"
require "#{File.dirname(__FILE__)}/sprites/zombie"
require "#{File.dirname(__FILE__)}/sprites/hero"
require "#{File.dirname(__FILE__)}/sprites/helicopter"
require "#{File.dirname(__FILE__)}/sprites/innocent"
require "#{File.dirname(__FILE__)}/sprites/tile"

module ZOrder
  Background = 0
  Blood = 1
  Hero = 2
  Helicopter = 3
  UI = 4
end

module Conf
  HERO_VELOCITY = 3
  HERO_LIFE = 5
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
  NUM_ZOMBIES = 50
  SCREEN_WIDTH = 800
  SCREEN_HEIGHT = 500
  PANEL_WIDTH = 200
  PANEL_VELOCITY = 2
  INNOCENT_LIFE = 8
  INNOCENT_VELOCITY = 4
  INNOCENT_SAW = 200
  NUM_INNOCENTS = 10
  HELICOPTER_CAPACITY = 4
  HELICOPTER_VELOCITY = 5
  HELICOPTER_DELIVERING_TIME = 400
  ANIMATION_VELOCITY = 4
end

class Admin
  attr_accessor :admin_show_info, :admin_show_panel, :admin_show_life
  
  def initialize
    @admin_show_info = false
    @admin_show_panel = false
    @admin_show_life = false
  end
end









class Game < Gosu::Window
  attr_accessor :bullets, :admin
  attr_reader :font, :font_small, :hero, :image_zombie, :image_bullet, :tb, :map, :innocents, :zombies, :pause
  attr_reader :helicopter, :panel
  
  
  def initialize
    super( Conf::SCREEN_WIDTH, Conf::SCREEN_HEIGHT, false, 30 )
    self.caption = "One Of Zombies Game"
    
    @bullet_lapsus = 0
    
    @tb = ToolBox.new( self )
    
    @map = Map.new( self )
    @map.charge_map
    
    
    @beep = Gosu::Sample.new(self, "#{File.dirname(__FILE__)}/media/Beep.wav")
    @shoot = Gosu::Sample.new(self, "#{File.dirname(__FILE__)}/media/shoot.mp3")
    @zombie_eaten = Gosu::Sample.new(self, "#{File.dirname(__FILE__)}/media/zombie_eaten_2.wav")
    @helicopter_get_an_innocent = Gosu::Sample.new(self, "#{File.dirname(__FILE__)}/media/helicopter_get_an_innocent.wav")
    @explosion = Gosu::Sample.new(self, "#{File.dirname(__FILE__)}/media/Explosion.wav")
    @aahhh = Gosu::Sample.new(self, "#{File.dirname(__FILE__)}/media/aahhh.wav")
    
    
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
    
    @admin = Admin.new
    
    @panel = Panel.new( self )
    
    @panel.add_message( "what the fuck!!" )
    @panel.add_message( "that is all full of that criatures" )
    @panel.add_message( "" )
    @panel.add_message( "helicopter: when you ready press 'G' key and I'll put you on flat" )
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
    helicopter.warp( ((@map.width * 40) + 100) , (@map.height * 20) )
    
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
    
    
    if( @hero.status_name != 'helicopter' && @hero.status_name != 'died' )
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
        @hero.status = @hero.statuses[:walking]
      else
        @hero.status = @hero.statuses[:stop]
      end
    
      if( (button_down? Gosu::Button::KbSpace) && (@bullet_lapsus == 0) )
        @shoot.play
        bullet = Bullet.new( self )
        bullet.warp( @hero.x, @hero.y )
        bullet.shoot( @hero.angle )
        @bullets << bullet
        @bullet_lapsus = Conf::BULLET_LAPSUS
      end
    end


    
    @hero.move
    @zombies.each { |zombie| zombie.move }
    @bullets.each { |bullet| bullet.move }
    @innocents.each { |innocent| innocent.move }
    @helicopter.move
    @map.update
    @panel.move
    
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
            
            @panel.add_message 'die zombie, hahaha'
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
            
            @panel.add_message 'ouh, fuck!, I just killed an innocent.'
            
            if @innocents.size == 0 
              @panel.add_message 'that was the last innocent, better go away, come on to the helicopter.'
            else
              @panel.add_message "only #{@innocents.size} innocents left"
            end
          end
          
          # blood
          @bloods << Blood.new( self, innocent.x, innocent.y )
        end
      end
    end
    
    @zombies.each do |zombie|
      if zombie.bite <= 0 
        zombie.bite = Conf::ZOMBIE_BITE_VELOCITY
        
        if( (@hero.status_name == 'stop' || @hero.status_name == 'walking') && @hero.status_name != 'died' )
          if Gosu::distance(@hero.x, @hero.y, zombie.x, zombie.y) < 10 then
            @hero.life -= 1
            
            if @hero.life <= 0
              @aahhh.play
              @panel.add_message 'son or latter, it should happen.. I\'m a zombie'
              @panel.add_message ''
              @panel.add_message ''
              @panel.add_message ''
              @panel.add_message 'GAME OVER'
              
              @hero = hero.convert_to_zombie
              @zombies << @hero
            else
              @zombie_eaten.play
              @panel.add_message 'he is bitting me!!'
            end
            
          end
        end
      
        @innocents.each do |innocent|
          if Gosu::distance(innocent.x, innocent.y, zombie.x, zombie.y) < 20 then
            innocent.life -= 1
          
            if innocent.life <= 0
              @aahhh.play
              @zombies << innocent.convert_to_zombie
              @innocents.delete innocent
              
              @panel.add_message 'oh my good, a new zombie'
              
              if @innocents.size == 0 
                @panel.add_message 'the last innocent was infected, better go away, come on to the helicopter.'
              else
                @panel.add_message "only #{@innocents.size} innocents left"
              end
              
            else
              @zombie_eaten.play
            end
            
          end
        end
      end
    end
    
    if( @helicopter.status == @helicopter.statuses[:waiting] )
      @innocents.each do |innocent|
        if Gosu::distance(@helicopter.x, @helicopter.y, innocent.x, innocent.y) < 30 then
          @innocents_saved += 1
          @helicopter_get_an_innocent.play
          @innocents.delete innocent
          
          @helicopter.innocents_aboard += 1
          
          @panel.add_message 'that is, an other innocent on the helicopter'
          
          if @innocents.size == 0 
            @panel.add_message 'no more innocents to save, better go away, come on to the helicopter.'
          else
            @panel.add_message "only #{@innocents.size} innocents left"
          end
          
          if( @helicopter.innocents_aboard >= Conf::HELICOPTER_CAPACITY )
            @helicopter.status = @helicopter.statuses[:going ]
            
            @panel.add_message 'put the innocents at save, and come quickly'
            
          else
            @panel.add_message "helicopter: I have space for #{Conf::HELICOPTER_CAPACITY - @helicopter.innocents_aboard} innocents more"
          end
        end
      end

    end
    
    if( @helicopter.status == @helicopter.statuses[:waiting] )  
      if( @innocents.size == 0 )
        if Gosu::distance(@helicopter.x, @helicopter.y, @hero.x, @hero.y) < 5 then
          @helicopter_get_an_innocent.play
          @hero.status = @hero.statuses[:helicopter]
          @helicopter.status = @helicopter.statuses[:going ]
          
          @panel.add_message 'that is all, no more innocents to save'
          
        end
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
    @panel.draw
    
    if( @admin.admin_show_panel )
      @font.draw("Score: #{@hero.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffff0000)  if @hero.status_name != 'died'
      @font.draw("Angle: #{@hero.angle}", 10, 25, ZOrder::UI, 1.0, 1.0, 0xffff0000)  if @hero.status_name != 'died'
      @font.draw("Bullets: #{@bullets.size}", 10, 40, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("Zombies: #{@zombies.size}", 10, 55, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("Innocents: #{@innocents.size}", 10, 70, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("FPS: #{@fps}", 10, 85, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("Innocents S: #{@innocents_saved}", 10, 100, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("Pause: #{@pause}", 10, 115, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("Helicopter: #{@helicopter.status_name}", 10, 130, ZOrder::UI, 1.0, 1.0, 0xffff0000)
      @font.draw("Hero: #{@hero.status_name}", 10, 145, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    end
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
    
    if id == Gosu::Button::KbS then
      @pause = !@pause
    end
    
    if id == Gosu::Button::KbI then
      @admin.admin_show_info = !@admin.admin_show_info
      
      @panel.add_message 'show me the ground vibrations'  if @admin.admin_show_info
      @panel.add_message 'hide me the ground vibrations'  if !@admin.admin_show_info
    end

    if id == Gosu::Button::KbP then
      @admin.admin_show_panel = !@admin.admin_show_panel
      @panel.add_message 'show me the panel'  if @admin.admin_show_panel
      @panel.add_message 'hide me the panel'  if !@admin.admin_show_panel
    end
    
    if id == Gosu::Button::KbL then
      @admin.admin_show_life = !@admin.admin_show_life
      @panel.add_message 'show me the life of the criatures'  if @admin.admin_show_life
      @panel.add_message 'hide me the life of the criatures'  if !@admin.admin_show_life
    end
    
    
    if( @hero.status_name == 'helicopter' && @helicopter.status_name == 'inspection' && id == Gosu::Button::KbG )
      @helicopter.status = @helicopter.statuses[:comming]
      @helicopter.tile_destination = self.map.random_walkable_tile
      @helicopter.angle = Gosu::angle( @helicopter.x, @helicopter.y, @helicopter.tile_destination.x, @helicopter.tile_destination.y )
      
      @panel.add_message 'ok, find a place and let me rock'
      
    end
  end
end

# window = Game.new
# window.show