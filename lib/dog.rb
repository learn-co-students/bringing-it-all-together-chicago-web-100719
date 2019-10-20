class Dog
attr_accessor :name, :breed
attr_reader :id

    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        DB[:conn].execute("DROP TABLE dogs")
    end

    def save
        if self.id
        else
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        end
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.new_from_db(row)
        dog = self.new(name: row[1], breed: row[2], id: row[0])
    end

    def self.find_by_id(id)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
        self.new_from_db(dog)
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ? LIMIT 1", name, breed)
        if !dog.empty?
            doggie_data = dog[0]
            dog = self.new_from_db(doggie_data)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? LIMIT 1", name)[0]
        self.new_from_db(dog)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? 
            WHERE id = ?
        SQL
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end




end