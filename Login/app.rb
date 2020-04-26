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

get('/Valid')do
    
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM movies WHERE user_id = ?;", session[:user_id].to_i)


   
    slim(:log_in, locals:{todo:result})
end

get('/main') do 

    slim(:main)
end 


get('/bountylist') do 
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM bountyinfo WHERE user_id = ?;", session[:user_id].to_i)

    slim(:bountylist,locals:{res:result})
end 


post('/bounty/:id/new')do

    movie_names = params["movie"]
    user_id = params["id"]
    
   
    db = SQLite3::Database.new("db/log_in.db")
    db.execute("INSERT INTO movies(movie_names, user_id) VALUES(?, ?);", movie_names, user_id)

    redirect('/bountycreate')
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

    id = params["id"]
    db = SQLite3::Database.new("db/log_in.db")

    db.execute("DELETE FROM bountyinfo WHERE id = ?;", id)

    redirect('/main')
end

post('/lists/:id/edit')do

    id = params["id"]
    movie_names = params["content"]

    db = SQLite3::Database.new("db/log_in.db")

    db.execute("UPDATE bountyinfo SET content = '#{content}' WHERE id = '#{item_id}';")

    redirect('/valid')
end

get('/bountycreate') do 
    slim(:bountycreate)
end 

post('/bounty/new') do 
    if(session[:user_id] == nil) 
        return redirect("/main")
    end 
    user_id = session[:user_id]
    name = params["name"]
    contents = params["contents"]
    price = params["price"]
    db = SQLite3::Database.new("db/log_in.db")
    db.execute("INSERT INTO bountyinfo( price,contents,name,user_id) VALUES(?,?,?,?);",price ,contents,name,user_id) 
    redirect('/main')
end 
