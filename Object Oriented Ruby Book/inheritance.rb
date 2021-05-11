###########################################################
#Chapter 4: Inheritance
###########################################################

#1. I extracted the shared state and behavior out into the Vehicle superclass. I also added a TYPE constant to both the MyCar and MyTruck class, which is a different string for each class.

#2. I added the below code to add a class variable and a method to retrieve it:
  # @@num_inherited_objects = 0

  # def self.num_vehicles
  #   @@num_inherited_objects
  # end
    # I also modified the constructor in the Vehicle class to increment every time an object is created

#3. I added the following module below and included it in the MyTruck class
  # module Off_Roadable
  #   def go_off_roading
  #     puts "Leaving the asphalt behind now!"
  #   end
  # end

#4. Invoking #ancestors on a class outputs the method lookup chain.

#5. I extracted out a couple more common methods from the MyCar class to the Vehicle superclass.

#6. I added the below code to the class:
  # def age
  #   self.calculate_vehicle_age
  # end

  # private
  # def calculate_vehicle_age
  #   Time.now.year - self.year
  # end

class Vehicle
  attr_accessor :color
  attr_reader :year, :current_speed, :model

  @@num_inherited_objects = 0

  def self.num_vehicles
    @@num_inherited_objects
  end

  def initialize(year, color, model)
    @year = year
    @color = color
    @model = model
    @current_speed = 0

    @@num_inherited_objects += 1
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
    puts "Vehicle is now off"
  end

  def self.calculate_mileage(gallons, miles_traveled)
    puts "This vehicle gets #{(miles_traveled / gallons.to_f).round(2)} mpg."
  end

  def to_s
    puts "This vehicle is a #{self.color} #{self.year} #{self.model} which is currently traveling #{self.current_speed_text}."
  end

  def age
    calculate_vehicle_age
  end

  private
  def calculate_vehicle_age
    Time.now.year - self.year
  end
end

module Off_Roadable
  def go_off_roading
    puts "Leaving the asphalt behind now!"
  end
end

class MyCar < Vehicle
  TYPE = "car"

  def vehicle_type
    puts "This vehicle is a #{TYPE}."
  end

end

class MyTruck < Vehicle
  include Off_Roadable

  TYPE = "truck"

  def vehicle_type
    puts "This vehicle is a #{TYPE}."
  end

end
zoomy = MyCar.new(1998, "Red", "Toyota Corolla")
puts zoomy
zoomy.vehicle_type
zoomy.spray_paint("Blue")
puts zoomy.age

jumbo = MyTruck.new(2004, "Black", "Rav 4")
puts jumbo.vehicle_type
jumbo.go_off_roading
puts jumbo.age

puts "There are now #{Vehicle.num_vehicles} objects inherited from Vehicle"

puts "\n\n\n\n\n----------"

#7.
class Student
  attr_reader :name
  attr_writer :grade

  def initialize(name, grade)
    @name = name
    @grade = grade
  end

  def better_grade_than?(classmate)
    grade > classmate.grade
  end

  protected
  attr_reader :grade
end

tommy = Student.new("Tommy", 89)
catherine = Student.new("Catherine", 93)

p tommy
p catherine

puts tommy.better_grade_than?(catherine)
puts catherine.better_grade_than?(tommy)

#8. The problem here is that a private method is being invoked. The access modifier needs to be changed to public, or otherwise the code could be refactored so that it's calling a public method (which then could call the private hi method, for example.)