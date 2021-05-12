###########################################################
#Chapter 3: Classes and Objects II
###########################################################

#1 To add a class method, we need to prepend self. to the method name. I added the following method definition:
  # def self.calculate_mileage(gallons, miles_traveled)
  #   puts "This car gets #{(miles_traveled / gallons.to_f).round(2)} mpg."
  # end

#2 To override the to_s method, I added the following method definition to the class below:

  # def to_s
  #   puts "This car is a #{self.color} #{self.year} #{self.model} which is currently traveling #{self.current_speed_text}."
  # end

#3 This error was thrown because a setter method wasn't defined in this case. Instead of attr_reader, attr_accessor should be used. This will automatically create both a getter and setter method for the name attribute.

class MyCar
  attr_accessor :color
  attr_reader :year, :current_speed, :model

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @current_speed = 0
  end

  def self.calculate_mileage(gallons, miles_traveled)
    puts "This car gets #{(miles_traveled / gallons.to_f).round(2)} mpg."
  end

  def to_s
    puts "This car is a #{self.color} #{self.year} #{self.model} which is currently traveling #{self.current_speed_text}."
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

puts MyCar.calculate_mileage(14, 289)

speedy = MyCar.new(2001, "Crimson", "Honda Civic")
puts speedy