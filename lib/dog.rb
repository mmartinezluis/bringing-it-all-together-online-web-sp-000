require 'pry'
class Dog
  attr_accessor :id, :name, :breed


  def initialize(attributes)
    attributes.each {|key, value| self.send(("#{key}="), value)}
    self.id ||= nil
  end

  def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
    
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    binding.pry
  end

  def self.new_from_db(row)
    dog = Dog.new(id:row[0], name:row[1], breed:row[2])
  end

  def save
    if self.id
      self.update
    else
      sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
      dog = DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self    
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE id=?", id)[0]
    dog = self.new_from_db(dog_data)
  end

  def self.find_or_create_by(name:, breed:)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name= ? AND breed= ?", name, breed)
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = Dog.create(:name => name, :breed => breed)
    end
    dog
  end
    
  def self.find_by_name(name)
    dog =DB[:conn].execute("SELECT * FROM dogs WHERE name=?", name)[0]
    Dog.new_from_db(dog)
  end

  def update
    
    DB[:conn].execute("UPDATE dogs SET name=?, breed=? WHERE id=?", self.name, self.breed, self.id)
  end



end
