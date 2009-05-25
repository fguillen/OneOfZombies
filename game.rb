begin
  require 'rubygems'
rescue LoadError
end

require 'gosu'

require 'tool_box'
require 'map'

module ZOrder
  Background = 0
  Blood = 1
  Hero = 2
  UI = 3
end

module Conf
  HERO_VELOCITY = 2
  HERO_LIFE = 50
  BULLET_VELOCITY = 4.0
  BULLET_RETROCESO = 5
  BULLET_LAPSUS = 10
  ZOMBIE_VELOCITY = 0.2
  ZOMBIE_TURN_VELOCITY = 25
  ZOMBIE_TURN_DECISION = 10
  ZOMBIE_LIFE = 5
  ZOMBIE_SAW = 200
  ZOMBIE_REPRODUCTION = 100
  NUM_ZOMBIES = 10
  SCREEN_WIDTH = 400
  SCREEN_HEIGHT = 400
end

class Hero
  attr_reader :score, :x, :y
  attr_accessor :angle, :score, :life, :walking


  def initialize(window)
    @image = Gosu::Image.new(window, "media/zanahoria.png", false)
    self.warp( 0, 0 )
    @score = 0
    @angle = 0.0
    @life = Conf::HERO_LIFE
    @window = window
    @walking = false
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    if( @walking )
      @x += Gosu::offset_x( @angle, Conf::HERO_VELOCITY )
      @y += Gosu::offset_y( @angle, Conf::HERO_VELOCITY )
    
      @x = (@window.map.width*40)   if @x > (@window.map.width*40)
      @x = 0                        if @x < 0
      @y = (@window.map.height*40)  if @y > (@window.map.height*40)
      @y = 0                        if @y < 0
    end
  end

  def draw
    if(
      (@x - @window.map.x) + 1 > 0 && 
      (@x - @window.map.x) - 1 < Conf::SCREEN_WIDTH &&
      (@y - @window.map.y) + 1 > 0 && 
      (@y - @window.map.y) - 1 < Conf::SCREEN_HEIGHT
    )
      @window.tb.sprite_images[:hero].draw_rot(@x - @window.map.x , @y - @window.map.y , ZOrder::Hero, @angle + 90)
      @window.font.draw("#{@life}", @x - @window.map.x - 20 , @y - @window.map.y - 30 , ZOrder::UI, 1.0, 1.0, 0xffff0000)
    end
  end
  
end

class Zombie
  attr_reader :x, :y
  attr_accessor :life
  
  def initialize(window)
    self.warp(0,0)
    @angle = rand( (360 * 2) + 1 ) - 360 
    @life = rand(Conf::ZOMBIE_LIFE) + 1
    @window = window
    @image = @window.image_zombie
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    
    if see_hero
      @angle = Gosu::angle(@x, @y, @window.hero.x, @window.hero.y)
    else
      if rand(Conf::ZOMBIE_TURN_DECISION) == 0
        @angle += rand( (Conf::ZOMBIE_TURN_VELOCITY * 2) + 1 ) - Conf::ZOMBIE_TURN_VELOCITY
      end
    end
      

    @x += Gosu::offset_x( @angle, Conf::ZOMBIE_VELOCITY )
    @y += Gosu::offset_y( @angle, Conf::ZOMBIE_VELOCITY )
    
    if(
      @x > (@window.map.width * 40) ||
      @x < 0 ||
      @y > (@window.map.height * 40) ||
      @y < 0
    ) 
      @angle += 90
    end
  end
  
  def retroceso( angle )
    @x += Gosu::offset_x( angle, Conf::BULLET_RETROCESO )
    @y += Gosu::offset_y( angle, Conf::BULLET_RETROCESO )
  end

  def see_hero
    Gosu::distance(@x, @y, @window.hero.x, @window.hero.y) < Conf::ZOMBIE_SAW
  end
  
  def draw
    if(
      (@x - @window.map.x) + 1 > 0 && 
      (@x - @window.map.x) - 1 < Conf::SCREEN_WIDTH &&
      (@y - @window.map.y) + 1 > 0 && 
      (@y - @window.map.y) - 1 < Conf::SCREEN_HEIGHT
    )
      @window.tb.sprite_images[:zombie].draw_rot( @x - @window.map.x , @y - @window.map.y, ZOrder::Hero, @angle + 90 )
      @window.font.draw("#{life}", @x - @window.map.x - 20 , @y - @window.map.y - 30 , ZOrder::UI, 1.0, 1.0, 0xffff0000)
    end
  end
end

class Bullet
  attr_reader :x, :y, :angle
  
  def initialize(window)
    @window = window
    self.warp(0,0)
    self.shoot(0.0)
  end
  
  def shoot( angle )
    @angle = angle
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    @x += Gosu::offset_x( @angle, Conf::BULLET_VELOCITY )
    @y += Gosu::offset_y( @angle, Conf::BULLET_VELOCITY )
    
    if(
      @x > (@window.map.width * 40) ||
      @x < 0 ||
      @y > (@window.map.height * 40) ||
      @y < 0
    ) 
      @window.bullets.delete( self )
    end
  end

  def draw
    if(
      (@x - @window.map.x) + 1 > 0 && 
      (@x - @window.map.x) - 1 < Conf::SCREEN_WIDTH &&
      (@y - @window.map.y) + 1 > 0 && 
      (@y - @window.map.y) - 1 < Conf::SCREEN_HEIGHT
    )
      @window.tb.sprite_images[:bullet].draw_rot( @x - @window.map.x , @y - @window.map.y, ZOrder::Hero, @angle + 90 )
    end
  end
end

class Blood
  attr_reader :x, :y
  
  def initialize(window, x, y)
    @window = window
    @x = x + rand(10)
    @y = y + 10
    @image =  @window.tb.sprite_images[:blood][rand(3)]
  end

  def draw
    if(
      (@x - @window.map.x) > 0 && 
      (@x - @window.map.x) < Conf::SCREEN_WIDTH &&
      (@y - @window.map.y) > 0 && 
      (@y - @window.map.y) < Conf::SCREEN_HEIGHT
    )
      @image.draw_rot( @x - @window.map.x , @y - @window.map.y, ZOrder::Blood, 0.0 )
    end
  end
end

class Game < Gosu::Window
  attr_accessor :bullets
  attr_reader :font, :hero, :image_zombie, :image_bullet, :tb, :map
  
  
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
    @explosion = Gosu::Sample.new(self, "media/Explosion.wav")
    
    @image_zombie = Gosu::Image.new(self, "media/eye.png", false)
    @image_bullet = Gosu::Image.new(self, "media/bullet.bmp", false)
    
    @hero = Hero.new(self)
    @hero.warp( (Conf::SCREEN_WIDTH / 2) , (Conf::SCREEN_HEIGHT / 2) )

    @zombies = self.initialize_zombies( Conf::NUM_ZOMBIES )
    @bullets = []
    @bloods = []
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def initialize_zombies( num )
    zombies = []

    num.times do
      zombie = Zombie.new(self)
      zombie.warp( rand(self.map.width*40), rand(self.map.height*40) )
      zombies << zombie
    end
    
    return zombies
  end

  def update
    
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
    
    @zombies += initialize_zombies( rand(3) )  if rand(Conf::ZOMBIE_REPRODUCTION) == 0
    
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
    end
    
    @zombies.each do |zombie|
      if Gosu::distance(@hero.x, @hero.y, zombie.x, zombie.y) < 10 then
        @hero.life -= 1
        @zombie_eaten.play
      end
    end
  end

  def draw
    @map.draw
    @hero.draw
    @zombies.each { |zombie| zombie.draw }
    @bullets.each { |bullet| bullet.draw }
    @bloods.each { |blood| blood.draw }    

    @font.draw("Score: #{@hero.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Angle: #{@hero.angle}", 10, 25, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Bullets: #{@bullets.size}", 10, 40, ZOrder::UI, 1.0, 1.0, 0xffff0000)
    @font.draw("Zombies: #{@zombies.size}", 10, 55, ZOrder::UI, 1.0, 1.0, 0xffff0000)
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
end

window = Game.new
window.show