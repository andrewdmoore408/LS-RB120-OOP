###########################################################
#Chapter 2: Classes and Objects I
###########################################################

#1
class MyCar
  attr_accessor :color
  attr_reader :year, :current_speed

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @current_speed = 0
  end

  def spray_paint(color)
    self.color = color
  end

  def current_speed_text
    "#{self.current_speed} mph"
  end

  def accelerate_to(acceleration_target)
    while @current_speed < acceleration_target
      @current_speed += 1
      puts "Accelerating: speed is now #{current_speed_text}."
    end
  end

  def brake_to(brake_to_target)
    while @current_speed > brake_to_target
      @current_speed -= 1
      puts "Braking: speed is now #{current_speed_text}."
    end
  end

  def turn_off
    brake_to(0)
    puts "Shutting down..."
    puts
    puts "Car is now off"
  end

end

zoomzoom = MyCar.new(2020, "Red", "Porsche Roadster")
p zoomzoom

puts zoomzoom.color
zoomzoom.color = "Purple"
puts zoomzoom.color
puts zoomzoom.year
zoomzoom.spray_paint("Blue")
puts zoomzoom.color
zoomzoom.accelerate_to(17)
zoomzoom.brake_to(4)
# zoomzoom.turn_off

# 2. To be able to view and modify the color, I added the line attr_accessor :color. For read-only access for the year, I added the line attr_reader :year

# 3. To provide this functionality, I added the following code to the class definition:
  # def spray_paint(color)
  #   self.color = color
  # end