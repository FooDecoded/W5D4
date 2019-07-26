PRAGMA foreign_keys = ON;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

INSERT INTO 
  users(fname, lname)
VALUES
  ('John', 'Smith'),
  ('Arthur', 'Miller'),
  ('Annie', 'Giang');



CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  author INTEGER NOT NULL,
  FOREIGN KEY (author) REFERENCES users(id)
);

INSERT INTO 
  questions(title, body, author)
VALUES
  ('What is your name?', 'I want to know your name.', 1),
  ('What is your age?', 'I want to know your age.', 2);
  
CREATE TABLE question_follows (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO 
  question_follows(question_id ,user_id)
VALUES
  (1, 3);

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,
  body TEXT NOT NULL,
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO 
  replies(question_id ,user_id, body, parent_reply_id)
VALUES
  (1, 3, 'heyy anniiee!', 1);

CREATE TABLE question_likes (
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)  
);

INSERT INTO 
  question_likes(user_id, question_id)
VALUES
  (3, 1);


  SELECT question_id, count(user_id) as num_users
  FROM question_follows
  GROUP BY question_id
  ORDER BY num_users DESC
  LIMIT 1

  SELECT count(user_id) as num_likers from question_likes 
  GROUP BY user_id
  where question_id = 1 

  SELECT *
  FROM question_likes join questions on questions.id = question_likes.question_id
