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
        redirect("/valid")
    else
        redirect("/Invalid")
    end
    
end

get('/valid')do
    
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM to_dos WHERE user_id = ?;", session[:user_id].to_i)

    slim(:log_in, locals:{todo:result})
end

post('/todo/:id/new')do

    content = params["todo"]
    user_id = params["id"]

    db = SQLite3::Database.new("db/log_in.db")
    db.execute("INSERT INTO To_dos(content, user_id) VALUES(?, ?);", content, user_id)

    redirect('/valid')
end

def set_error(error_message)
    session[:error] = error_message
end
post('/register')do
    db = SQLite3::Database.new("db/log_in.db")
    # db.results_as_hash = true
    pwdhash = BCrypt::Password.create(params['password'])

    db.execute("INSERT INTO user(username, password_digest) VALUES(?, ?);", params['username'], pwdhash)

    redirect("/")
end

post('/lists/:id/delete')do

    item_id = params["id"]
    db = SQLite3::Database.new("db/log_in.db")

    db.execute("DELETE FROM to_dos WHERE id = ?;", item_id)

    redirect('/valid')
end

post('/lists/:id/edit')do

item_id = params["id"]
content = params["content"]

db = SQLite3::Database.new("db/log_in.db")

db.execute("UPDATE to_dos SET content = '#{content}' WHERE id = '#{item_id}';")

redirect('/valid')
end

