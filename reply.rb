require 'sqlite3'
require 'singleton'
require_relative 'user.rb'
require_relative 'question.rb'

class RepliesDataBase < SQLite3::Database
  include Singleton

  def initialize 
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class Reply
  attr_accessor :body 
  def self.all
    data = RepliesDataBase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_user_id(user_id)
    data = RepliesDataBase.instance.execute("SELECT * FROM replies WHERE user_id = #{user_id}")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_question_id(question_id) 
    reply = RepliesDataBase.instance.execute("SELECT * FROM replies WHERE question_id = #{question_id}")
    Reply.new(reply[0])
  end

  def author
    User.select_by_id(@user_id) 
  end

  def question
    data = Question.select_by_id(@question_id) 
    data.map { |datum| Reply.new(datum) }
  end

  def parent_reply
    return nil if @parent_reply_id == nil
    data = RepliesDataBase.instance.execute("SELECT * FROM replies WHERE id = #{@parent_reply_id}")
    data.map { |datum| Reply.new(datum) }
  end

  def child_replies
    data = RepliesDataBase.instance.execute("SELECT * FROM replies WHERE parent_reply_id = #{@id}")
    data.map { |datum| Reply.new(datum) }    
  end

  def initialize(options)
    @id = options["id"]
    @question_id = options["question_id"]
    @parent_reply_id = options["parent_reply_id"]
    @user_id = options["user_id"]
    @body = options["body"]
  end

  def create
    raise "#{self} already in database" if @id
    RepliesDataBase.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id, @body) 
      INSERT INTO 
      replies (question_id, parent_reply_id, user_id, body)
      VALUES
      (?, ?, ?, ?)
    SQL
    @id = RepliesDataBase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    !!RepliesDataBase.instance.execute(<<-SQL, @body, @id) 
     UPDATE
        replies
      SET
        body = ?
      WHERE
        id = ?
      SQL
  end
end