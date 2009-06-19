require 'test/unit'
require '../game.rb'

class HelicopterTest < Test::Unit::TestCase
  def test_button_down
    window = Game.new
    # window.show

    puts "window.pause: #{window.pause}"
    # window.button_down( Gosu::Button::KbS )    
    puts "window.pause: #{window.pause}"
    
    puts "window.helicopter.status_name: #{window.helicopter.status_name}"
    window.button_down( Gosu::Button::KbG )    
    puts "window.helicopter.status_name: #{window.helicopter.status_name}"
    
    puts "window.hero.status_name: #{window.hero.status_name}"
    while( window.hero.status_name == 'helicopter' )
      window.update
      # puts "window.helicopter.x: #{window.helicopter.x}"
    end
    puts "window.hero.status_name: #{window.hero.status_name}"
    
    
  end

end