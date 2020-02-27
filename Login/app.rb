require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'byebug'

enable :sessions

get('/') do
    slim(:start)
end

post('/login') do

    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true

    username = params["username"]
    password = params["password"]

    pwdhash = db.execute("SELECT password_digest FROM user WHERE username = ?;", username)
    session[:username] = username
    session[:user_id] = db.execute("SELECT id FROM user WHERE username = ?;", username).first["id"]


    if BCrypt::Password.new(pwdhash[0]["password_digest"]) == password
        redirect("/main")
    else
        redirect("/Invalid")
    end
    
end

get('/valid')do
    
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM movies WHERE user_id = ?;", session[:user_id].to_i)


   
    slim(:log_in, locals:{todo:result})
end

get('/main') do 

slim(:main)
end 
 

post('/todo/:id/new')do

    movie_names = params["movie"]
    user_id = params["id"]
    
    p movie_names  
    p user_id
    db = SQLite3::Database.new("db/log_in.db")
    db.execute("INSERT INTO movies(movie_names, user_id) VALUES(?, ?);", movie_names, user_id)

    redirect('/valid')
end

def set_error(error_message)
    session[:error] = error_message
end

post('/register')do
    db = SQLite3::Database.new("db/log_in.db")
    # db.results_as_hash = true
    pwdhash = BCrypt::Password.create(params['password'])
    p pwdhash
    p params['username']
    db.execute("INSERT INTO user(username, password_digest) VALUES(?, ?);", params['username'], pwdhash)

    redirect("/")
end

post('/lists/:id/delete')do

    item_id = params["id"]
    db = SQLite3::Database.new("db/log_in.db")

    db.execute("DELETE FROM movies WHERE id = ?;", item_id)

    redirect('/valid')
end

post('/lists/:id/edit')do

item_id = params["id"]
content = params["content"]

db = SQLite3::Database.new("db/log_in.db")

db.execute("UPDATE to_dos SET content = '#{content}' WHERE id = '#{item_id}';")

redirect('/valid')
end
