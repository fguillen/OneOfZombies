class Panel
  def initialize( window )
    @window = window
    @font = Gosu::Font.new( @window, Gosu::default_font_name, 20 )
    @buffer = []
  end
  
  def add_message( message )
    lines = self.wordwrap( message, Conf::PANEL_WIDTH, @font )
    
    lines.each_with_index do |line, index|
      position = nil
      
      if !@buffer.empty? && @buffer.last.position > Conf::SCREEN_HEIGHT - 30
        increment = 30  if index == 0
        increment = 20  if index != 0
        
        position = @buffer.last.position + increment
      else
        position = Conf::SCREEN_HEIGHT
      end
      
      line = " #{line}"  if index != 0 
      
      @buffer << PanelElement.new( line, position )
    end
  end
  
  
  def wordwrap( message, width, font)
    word_array = message.split(' ')
    lines = [word_array.shift]
    
    word_array.each do |word|
      if font.text_width("#{lines[-1]} #{word}") < width
        lines[-1] << ' ' << word
      else
        lines.push(word)
      end
    end
    
    return lines
  end
  
  def move
    @buffer.each do |element|
      element.position -= Conf::PANEL_VELOCITY
      if element.position <= -20
        @buffer.delete element
      end
    end
  end
  
  def draw
    @buffer.each do |element|    
      @font.draw( element.text, Conf::SCREEN_WIDTH - Conf::PANEL_WIDTH, element.position, ZOrder::UI, 1.0, 1.0, 0xffff0000 )
    end
  end
  
end

class PanelElement
  attr_accessor :text, :position
  
  def initialize( text, position )
    @text = text
    @position = position
  end
end