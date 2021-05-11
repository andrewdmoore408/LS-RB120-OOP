###########################################################
#Chapter 1: The Object Model
###########################################################

# 1. To create an object, we define a class and then instantiate an object (instance of that class) by invoking the new method on the class and using a variable to store a pointer to the newly created object.

class NiceCat
end

oreo = NiceCat.new
puts oreo
##########

# 2. A module is a way to organize a collection of methods which can be reused across different classes. Its purpose is to establish and provide shared behaviors (methods) which can be useful in multiple classes. They are "mixed in" by using the include keyword inside a class definition, and more than one module can be included in a class.

module Speak
  def speak(sound)
    puts sound
  end
end

# Updated class definition with module mixed in
class NiceCat
  include Speak
end