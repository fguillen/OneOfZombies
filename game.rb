begin
  require 'rubygems'
rescue LoadError
end

require 'gosu'

module ZOrder
  Background = 0
  Hero = 2
  UI = 3
end

HERO_VELOCITY = 2.0
HERO_LIFE = 50
BULLET_VELOCITY = 4.0
BULLET_RETROCESO = 1
ZOMBIE_VELOCITY = 0.2
ZOMBIE_TURN_VELOCITY = 25
ZOMBIE_TURN_DECISION = 10
ZOMBIE_LIFE = 20
ZOMBIE_SAW = 200
ZOMBIE_REPRODUCTION = 100
NUM_ZOMBIES = 10
SCREEN_WIDTH = 640
SCREEN_HEIGHT = 480

class Hero
  attr_reader :score, :x, :y
  attr_accessor :angle, :score, :life, :walking


  def initialize(window)
    @image = Gosu::Image.new(window, "media/zanahoria.png", false)
    self.warp( 0, 0 )
    @score = 0
    @angle = 0.0
    @life = HERO_LIFE
    @window = window
    @walking = false
  end

  def warp(x, y)
    @x = x
    @y = y
  end
  
  def move
    if( @walking )
      @x += Gosu::offset_x( @angle, HERO_VELOCITY )
      @y += Gosu::offset_y( @angle, HERO_VELOCITY )
    
      @x = SCREEN_WIDTH    if @x > SCREEN_WIDTH
      @x = 0               if @x < 0
      @y = SCREEN_HEIGHT   if @y > SCREEN_HEIGHT
      @y = 0               if @y < 0
    end
  end

  def draw
    @image.draw_rot(@x, @y, ZOrder::Hero, @angle)
    @window.font.draw("#{@life}", @x - 20 , @y - 30 , ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
  
end

class Zombie
  attr_reader :x, :y
  attr_accessor :life
  
  def initialize(window)
    self.warp(0,0)
    @angle = rand( (360 * 2) + 1 ) - 360 
    @life = ZOMBIE_LIFE
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
      if rand(ZOMBIE_TURN_DECISION) == 0
        @angle += rand( (ZOMBIE_TURN_VELOCITY * 2) + 1 ) - ZOMBIE_TURN_VELOCITY
      end
    end
      

    @x += Gosu::offset_x( @angle, ZOMBIE_VELOCITY )
    @y += Gosu::offset_y( @angle, ZOMBIE_VELOCITY )
    
    if(
      @x > SCREEN_WIDTH ||
      @x < 0 ||
      @y > SCREEN_HEIGHT ||
      @y < 0
    ) 
      @angle += 90
    end
  end
  
  def retroceso( angle )
    @x += Gosu::offset_x( angle, BULLET_RETROCESO )
    @y += Gosu::offset_y( angle, BULLET_RETROCESO )
  end

  def see_hero
    Gosu::distance(@x, @y, @window.hero.x, @window.hero.y) < ZOMBIE_SAW
  end
  
  def draw
    @image.draw_rot( @x, @y, ZOrder::Hero, @angle )
    @window.font.draw("#{life}", @x - 20 , @y - 30 , ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end
end

class Bullet
  attr_reader :x, :y, :angle
  
  def initialize(window)
    @window = window
    @image = @window.image_bullet
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
    @x += Gosu::offset_x( @angle, BULLET_VELOCITY )
    @y += Gosu::offset_y( @angle, BULLET_VELOCITY )
    
    if(
      @x > SCREEN_WIDTH ||
      @x < 0 ||
      @y > SCREEN_HEIGHT ||
      @y < 0
    ) 
      @window.bullets.delete( self )
    end
  end

  def draw
    @image.draw_rot( @x, @y, ZOrder::Hero, 0.0 )
  end
end


class Game < Gosu::Window
  attr_accessor :bullets
  attr_reader :font, :hero, :image_zombie, :image_bullet
  
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
    self.caption = "One Of Zombies Game"
    
    @beep = Gosu::Sample.new(self, "media/Beep.wav")
    @zombie_eaten = Gosu::Sample.new(self, "media/zombie_eaten_2.wav")
    @explosion = Gosu::Sample.new(self, "media/Explosion.wav")
    
    @image_zombie = Gosu::Image.new(self, "media/eye.png", false)
    @image_bullet = Gosu::Image.new(self, "media/bullet.bmp", false)
    
    @hero = Hero.new(self)
    @hero.warp( (SCREEN_WIDTH / 2) , (SCREEN_HEIGHT / 2) )

    @zombies = self.initialize_zombies( NUM_ZOMBIES )
    @bullets = []
    
    @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
  end

  def initialize_zombies( num )
    zombies = []

    num.times do
      zombie = Zombie.new(self)
      zombie.warp( rand(SCREEN_WIDTH), rand(SCREEN_HEIGHT) )
      zombies << zombie
    end
    
    return zombies
  end

  def update
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
    
    if button_down? Gosu::Button::KbSpace then
      bullet = Bullet.new( self )
      bullet.warp( @hero.x, @hero.y )
      bullet.shoot( @hero.angle )
      @bullets << bullet
    end
    
    @hero.move
    @zombies.each { |zombie| zombie.move }
    @bullets.each { |bullet| bullet.move }
    
    
    @zombies += initialize_zombies( rand(3) )  if rand(ZOMBIE_REPRODUCTION) == 0
    
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
    @hero.draw
    @zombies.each { |zombie| zombie.draw }
    @bullets.each { |bullet| bullet.draw }
    @font.draw("Score: #{@hero.score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Angle: #{@hero.angle}", 10, 50, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Bullets: #{@bullets.size}", 10, 100, ZOrder::UI, 1.0, 1.0, 0xffffff00)
    @font.draw("Zombies: #{@zombies.size}", 10, 150, ZOrder::UI, 1.0, 1.0, 0xffffff00)
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape then
      close
    end
  end
end

window = Game.new
window.show