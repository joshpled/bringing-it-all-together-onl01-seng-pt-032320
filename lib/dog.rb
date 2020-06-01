class Dog

    attr_accessor :name, :breed, :id

    def initialize (name: , breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end 

    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs(
            id INT PRIMARY KEY,
            name TEXT, 
            breed TEXT)"
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    end

    def save
        DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed) 
        row = DB[:conn].execute("SELECT * FROM dogs ORDER BY id DESC LIMIT 1").flatten
        dog = Dog.new(id: row[0], name: row[1], breed: row[2])
        dog
    end

    def self.create(hash)
        dog = Dog.new(name: hash[:name],breed: hash[:breed])
        dog.save
    end

    def self.new_from_db(hash)
        Dog.new(name: hash[1], breed: hash[2], id: hash[0])
    end

    def self.find_by_id(id)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).flatten
        self.new_from_db(row)
    end

    def self.find_or_create_by(name:,breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            row = dog[0]
            create_dog = Dog.new(name: row[1], breed: row[2], id: row[0])
        else
            create_dog = Dog.create(name: name, breed: breed)
        end
    end 

    def self.find_by_name(name)
        row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).flatten
        self.new_from_db(row)
    end 

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", self.name, self.breed, self.id).flatten
    end


end