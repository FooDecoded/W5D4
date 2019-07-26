require 'sqlite3'
require 'singleton'
require_relative 'user.rb'
require_relative 'reply.rb'
require "byebug"

# CREATE TABLE question_follows (
#   question_id INTEGER NOT NULL,
#   user_id INTEGER NOT NULL,
#   FOREIGN KEY (user_id) REFERENCES users(id),
#   FOREIGN KEY (question_id) REFERENCES questions(id)
# );

class QuestionFollowsDatabase < SQLite3::Database
  include Singleton

  def initialize 
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end



class QuestionFollow

  def self.followers_for_question_id(question_id)
    ids = QuestionFollowsDatabase.instance.execute("SELECT user_id from question_follows where question_id = #{question_id}")
    # debugger
    ids.map { |id| User.select_by_id(id["user_id"])  }
  end

  def self.followed_questions_for_user_id(user_id)
    ids = QuestionFollowsDatabase.instance.execute("SELECT question_id from question_follows where user_id = #{user_id}")
    # debugger
    ids.map { |id| Question.select_by_id(id["question_id"])  }
  end

  def self.most_followed_questions(n = 1)
    ids = QuestionFollowsDatabase.instance.execute("
          SELECT question_id, count(user_id) as num_users
          FROM question_follows
          GROUP BY question_id
          ORDER BY num_users DESC
          LIMIT #{n}
      ")
      # debugger
    ids.map { |id| Question.select_by_id(id["question_id"])  }
  end

  def initialize(options)
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end

end