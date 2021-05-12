#1. One class definition for this object could be:
class Person
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

# bob = Person.new('bob')
# bob.name                  # => 'bob'
# bob.name = 'Robert'
# bob.name                  # => 'Robert'

# 2. Modifying the class as instructed:
class Person
  attr_accessor :first_name, :last_name

  def initialize(first_name, last_name = "")
    @first_name = first_name
    @last_name = last_name
  end

  def name
    self.first_name + " " + self.last_name
  end
end

# bob = Person.new('Robert')
# p bob.name                  # => 'Robert'
# p bob.first_name            # => 'Robert'
# p bob.last_name             # => ''
# p bob.last_name = 'Smith'
# p bob.name                  # => 'Robert Smith'

#3. Now create a smart name= method that can take just a first name or a full name, and knows how to set the first_name and last_name appropriately.
class Person
  attr_accessor :first_name, :last_name

  def initialize(names)
    parse_full_name(names)
  end

  def name
    "#{self.first_name} #{self.last_name}".strip
  end

  def name=(name_string)
    parse_full_name(name_string)
  end

  private
  def parse_full_name(name_string)
    names = name_string.split

    self.first_name = names.first
    self.last_name = names.length > 1 ? names.last : ""
  end
end

bob = Person.new('Robert')
p bob.name                  # => 'Robert'
p bob.first_name            # => 'Robert'
p bob.last_name             # => ''
p bob.last_name = 'Smith'
p bob.name                  # => 'Robert Smith'

p bob.name = "John Adams"
p bob.first_name            # => 'John'
p bob.last_name             # => 'Adams'

#4. Using the same class definition as number 3
bob = Person.new('Robert Smith')
rob = Person.new('Robert Smith')
p bob.name == rob.name

#5. This will output the string representation (#to_s) of the Person object to which bob points. At the moment, it won't display much since we haven't overridden the #to_s method.

class Person
  attr_accessor :first_name, :last_name

  def initialize(names)
    parse_full_name(names)
  end

  def name
    "#{self.first_name} #{self.last_name}".strip
  end

  def name=(name_string)
    parse_full_name(name_string)
  end

  def to_s
    name
  end

  private
  def parse_full_name(name_string)
    names = name_string.split

    self.first_name = names.first
    self.last_name = names.length > 1 ? names.last : ""
  end
end

bob = Person.new("Bobby Briggs")
puts "This person is #{bob}"

# After adding the overridden #to_s method, the output now displays the return value of the custom #to_s method, which invokes the #name method in this case, thus returning the full name of the calling object.