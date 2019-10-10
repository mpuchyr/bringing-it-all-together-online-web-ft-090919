class Dog
    attr_accessor :name, :breed, :id

    def initialize(dog_hash)
        @name = dog_hash[:name]
        @breed = dog_hash[:breed]
        @id = dog_hash[:id]
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs;
        SQL
        DB[:conn].execute(sql)
    end

    def save
        if self.id
            self.update
        else
            sql = <<-SQL
                INSERT INTO dogs (name, breed)
                VALUES (?, ?);
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        end
        self
    end


    def self.create(dog_hash)
        dog = Dog.new(dog_hash)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog_id = row[0]
        dog_name = row[1]
        dog_breed = row[2]
        dog_hash = {:id => dog_id, :name => dog_name, :breed => dog_breed}
        new_dog = Dog.new(dog_hash)
        new_dog        
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?;"
        result = DB[:conn].execute(sql, id)[0]
        dog_hash = {:id => result[0], :name => result[1], :breed => result[2]}
        Dog.new(dog_hash)
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)[0]
        dog_hash = {:id => result[0], :name => result[1], :breed => result[2]}
        Dog.new(dog_hash)
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.find_or_create_by(dog_hash)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        result = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])[0]
        if !result
            self.create(dog_hash)
        else
            self.find_by_id(result[0])
        end
    end

end