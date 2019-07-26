require 'sqlite3'
require 'singleton'
require_relative 'user.rb'
require_relative 'reply.rb'
require_relative 'question_follow.rb'

# CREATE TABLE questions (
#   id INTEGER PRIMARY KEY,
#   title TEXT NOT NULL,
#   body TEXT NOT NULL,
#   author INTEGER NOT NULL,
#   FOREIGN KEY (author) REFERENCES users(id)
# );

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize 
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Question
  attr_accessor :title, :body 
  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.select_by_id(id) 
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE id = #{id}")
    # puts question
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_author_id(author_id)
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions WHERE author = #{author_id}")
    data.map { |datum| Question.new(datum) }
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def author
    User.select_by_id(@author) 
  end

  def replies
    Reply.find_by_question_id(@id) 
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end
  
  
  def initialize(options)
    puts options
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author = options["author"]
  end

  def create
    raise "#{self} already in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author) 
      INSERT INTO 
      questions (title, body, author)
      VALUES
      (?, ?, ?)
    SQL
    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    !!QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @author, @id) 
     UPDATE
        questions
      SET
        title = ?, body = ?, author = ?
      WHERE
        id = ?
      SQL
  end
end