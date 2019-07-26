require 'sqlite3'
require 'singleton'

class QuestionLikesDatabase < SQLite3::Database
  include Singleton

  def initialize 
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end
end

class QuestionLike

  def initialize(options)
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end


  def self.likers_for_question_id(question_id)
    ids = QuestionLikesDatabase.instance.execute("SELECT user_id from question_likes where question_id = #{question_id}")
    # debugger
    ids.map { |id| User.select_by_id(id["user_id"])  }
  end

  def num_likes_for_question_id(question_id)
      ids = QuestionLikesDatabase.instance.execute("SELECT count(user_id) as num_likers from question_likes where question_id = #{question_id} GROUP BY num_likers")
  end

end
