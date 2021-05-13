#1. One problem is that we need to keep track of different breeds of dogs, since they have slightly different behaviors. For example, bulldogs can't swim, but all other dogs can.

#Create a sub-class from Dog called Bulldog overriding the swim method to return "can't swim!"

# class Dog
#   def speak
#     'bark!'
#   end

#   def swim
#     'swimming!'
#   end
# end

# class Bulldog < Dog
#   def swim
#     'can\'t swim!'
#   end
# end

# teddy = Dog.new
# puts teddy.speak           # => "bark!"
# puts teddy.swim           # => "swimming!"

# rufus = Bulldog.new
# puts rufus.speak
# puts rufus.swim

########################################
# 2. Create a new class called Cat, which can do everything a dog can, except swim or fetch. Assume the methods do the exact same thing. Hint: don't just copy and paste all methods in Dog into Cat; try to come up with some class hierarchy.

class Pet
  def run
    'running!'
  end

  def jump
    'jumping!'
  end

end

class Dog < Pet
  def speak
    'bark!'
  end

  def swim
    'swimming!'
  end

  def fetch
    'fetching!'
  end
end

class Cat < Pet
  def speak
    'meow!'
  end
end

pete = Pet.new
kitty = Cat.new
dave = Dog.new
bud = Bulldog.new

pete.run                # => "running!"
pete.speak              # => NoMethodError

kitty.run               # => "running!"
kitty.speak             # => "meow!"
kitty.fetch             # => NoMethodError

dave.speak              # => "bark!"

bud.run                 # => "running!"
bud.swim                # => "can't swim!"

########################################
# 3.

          +----------+
          |    Pet   |
          |   run    |
          |   jump   |
          +----------+
        /             \
       /               \
      /                 \
+----------+      +----------+         
|    Cat   |      |    Dog   |
|   speak  |      |  speak   |
|          |      |   swim   |
|          |      |  fetch   |
+----------+      +----------+
                        |
                        |
                        |                                                
                  +----------+
                  |  Bulldog |
                  |   swim   |
                  +----------+

########################################
# 4. The method lookup path is the order in which Ruby searches for method definitions up the class hierarchy. It begins looking in the current class of which the object is an instance, then moves through the mixed in modules, then up the hierarchy of superclasses until it gets to the top-level class, BasicObject.

# This is important because it determines which methods will be run if more than one method has the same name. It allows for method overriding and also method inheritance, which provides additional flexibility.
