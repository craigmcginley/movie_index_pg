require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG::Connection.open(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

def get_movie_data(sql, id=nil)
  db_connection do |conn|
    conn.exec(sql)
  end
end


get '/actors' do
  sql = 'SELECT name, id FROM actors;'
  results = get_movie_data(sql)

  @all_actors = results.to_a

  erb :'actors/index'
end

get '/actors/:id' do
  id = params[:id]
  sql = "SELECT movies.id AS movie_id, actors.name AS name, movies.title AS movie, cast_members.character AS role
                FROM cast_members
                  JOIN movies ON cast_members.movie_id = movies.id
                  JOIN actors ON cast_members.actor_id = actors.id
                WHERE actors.id = #{id};"

  results = get_movie_data(sql, id)

  @actor = results.to_a

  erb :'actors/show'
end

get '/movies' do
  sql = 'SELECT movies.id AS movie_id, movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studios
          FROM movies
            LEFT OUTER JOIN studios ON movies.studio_id = studios.id
            JOIN genres ON movies.genre_id = genres.id
          ORDER BY title ASC;'

  results = get_movie_data(sql)

  @all_movies = results.to_a

  erb :'movies/index'
end

get '/movies/:id' do
  id = params[:id]
  sql = "SELECT actors.id AS actor_id, actors.name AS actor, cast_members.character AS role
                FROM cast_members
                  JOIN movies ON cast_members.movie_id = movies.id
                  JOIN actors ON cast_members.actor_id = actors.id
                WHERE movies.id = #{id};"

  results = get_movie_data(sql, id)
  @actors = results.to_a

  sql = "SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studios
          FROM movies
            LEFT OUTER JOIN studios ON movies.studio_id = studios.id
            JOIN genres ON movies.genre_id = genres.id
          WHERE movies.id = #{id};"
  results = get_movie_data(sql, id)
  @movie = results.to_a
  binding.pry

  erb :'movies/show'
end
