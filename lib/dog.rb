class Dog
    attr_accessor :name, :breed, :id

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed 
    end 

    def self.create_table
        sql = <<-SQL
            CREATE TABLE dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT)
        SQL
        DB[:conn].execute(sql)
    end 

    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end 

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self 
    end 

    def self.new_from_db(row)
        id = row[0]
        name = row[1]
        breed = row[2]
        self.new(id:id, name:name, breed:breed)
    end 

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        dog_data = DB[:conn].execute(sql, id).flatten
        self.new_from_db(dog_data)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        dog_data = DB[:conn].execute(sql, name).flatten
        self.new_from_db(dog_data)
    end
    
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end 

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save        
    end 

    def self.find_or_create_by(name: ,breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        db_row = DB[:conn].execute(sql, name, breed)
        if db_row.empty? #is row an empty array and therefore no record exists
            self.create(name:name, breed:breed)
        else 
            dog_data = db_row.flatten
            self.new_from_db(dog_data)
        end 
    end 

end
