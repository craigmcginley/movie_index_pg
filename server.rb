require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

def all_actors
  db_connection do |conn|
    conn.exec('SELECT * FROM actors;')
  end
end


get '/actors' do
  connection = PG::Connection.open(dbname: 'movies')

  all_actors = connection.exec('SELECT name, id FROM actors;')

  @all_actors = []

  all_actors.values.each do |actor|
    actor_hash = {
      name: actor[0],
      id: actor[1]
    }
    @all_actors << actor_hash
  end

  binding.pry

  erb :'actors/index'
end

get '/actors/:id' do

  erb :'actors/show'
end

get '/movies' do

  erb :'movies/index'
end

get '/movies/:id' do

  erb :'movies/show'
end
