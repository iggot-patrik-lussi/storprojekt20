#App.rb innehåller alla routes och allt som uppgör sidan. De olika routsen utgör olika sidor till hemsidan och det är så man går mellan de
#I början så är alla olika saker som används till att bygga upp sidan requirade som t.ex. sinatra eller slim. 
#Sedan har jag olika routes som för det mesta har namngets med restfull routes för att göra det mindre förvirrande för en läsare att kunna granska koden.


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



get('/main') do 

    slim(:main)
end 


get('/bountylist') do 
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM bountyinfo WHERE user_id = ?;", session[:user_id].to_i)

    slim(:bountylist,locals:{res:result})
end 

get('/browsebounties') do 
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM bountyinfo;")

    slim(:browsebounties,locals:{res:result})
end 

post('/bounty/delete/:id') do 
    db = SQLite3::Database.new("db/log_in.db")
    db.execute("DELETE FROM bountyinfo WHERE id = ?;", params[:id])
    redirect(back)

end 

get('/bounty/edit/:id') do
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    result = db.execute("SELECT * FROM bountyinfo WHERE id = ?;", params[:id].to_i).first
    
    slim(:bountyedit, locals:{res:result})
end 

post('/bounty/edit/:id') do 
    db = SQLite3::Database.new("db/log_in.db")
    db.results_as_hash = true
    db.execute("UPDATE bountyinfo SET contents = ?,name = ?,price = ? ;", params[:contents],params[:name],params[:price])
    redirect("/bountylist")
end 



post('/bounty/:id/new')do

    movie_names = params["movie"]
    user_id = params["id"]
    
   
    db = SQLite3::Database.new("db/log_in.db")
    db.execute("INSERT INTO movies(movie_names, user_id) VALUES(?, ?);", movie_names, user_id)

    redirect('/bountycreate')
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
