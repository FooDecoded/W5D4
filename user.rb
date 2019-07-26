require 'sqlite3'
require 'singleton'
require_relative 'question.rb'
require_relative 'question_follow.rb'

class UsersDatabase < SQLite3::Database
  include Singleton

  def initialize 
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class User
  attr_accessor :fname, :lname 
  def self.all
    data = UsersDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.select_by_id(id) 
    user = UsersDatabase.instance.execute("SELECT * FROM users WHERE id = #{id}")
    User.new(user[0])
  end

  def initialize(options)
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end

  def authored_questions
    Question.find_by_author_id(@id)
  end

  def authored_replies
    Reply.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow.followed_questions_for_user_id(@id)
  end

  def create
    raise "#{self} already in database" if @id
    UsersDatabase.instance.execute(<<-SQL, @fname, @lname) 
      INSERT INTO 
      users (fname, lname)
      VALUES
      (?, ?)
    SQL
    @id = UsersDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    !!UsersDatabase.instance.execute(<<-SQL, @fname, @lname, @id) 
     UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
      SQL
  end
end