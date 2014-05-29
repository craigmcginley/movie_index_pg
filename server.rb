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

def get_data_all(sql)
  db_connection do |conn|
    conn.exec(sql)
  end
end

def get_data_params(sql, param)
  db_connection do |conn|
    conn.exec_params(sql, [param])
  end
end

get '/' do
  erb :index
end


get '/actors' do
  if params[:page] == nil
    @page_number = 1
  else
    @page_number = params[:page].to_i
  end

  if @page_number == 1
    offset = 0
  else
    offset = (@page_number - 1) * 20
  end

  sql = "SELECT name, id FROM actors
          ORDER BY name
          LIMIT 20 OFFSET #{offset};"
  results = get_data_all(sql)

  @all_actors = results.to_a

  count = "SELECT COUNT(*) FROM actors;"
  all_actors_count = get_data_all(count).to_a
  all_actors_count = all_actors_count[0]["count"].to_i

  if all_actors_count % 20 == 0
    @last_page = all_actors_count / 20
  else
    @last_page = (all_actors_count / 20) + 1
  end

  erb :'actors/index'
end

get '/actors/:id' do
  id = params[:id]
  sql = "SELECT movies.id AS movie_id, actors.name AS name, movies.title AS movie, cast_members.character AS role
                FROM cast_members
                  JOIN movies ON cast_members.movie_id = movies.id
                  JOIN actors ON cast_members.actor_id = actors.id
                WHERE actors.id = $1;"

  results = get_data_params(sql, id)

  @actor = results.to_a

  erb :'actors/show'
end

get '/movies' do
  order_possibilities = ['title', 'year', 'rating', 'genre', 'studio']
  if order_possibilities.include?(params[:order])
    @order = params[:order]
  else
    @order = 'title'
  end

  if params[:page] == nil
    @page_number = 1
  else
    @page_number = params[:page].to_i
  end

  if @page_number == 1
    offset = 0
  else
    offset = (@page_number - 1) * 20
  end

  sql = "SELECT movies.id AS movie_id, movies.title AS title, movies.year AS year, movies.rating, genres.name AS genre, studios.name AS studio
          FROM movies
            LEFT OUTER JOIN studios ON movies.studio_id = studios.id
            JOIN genres ON movies.genre_id = genres.id
          ORDER BY #{@order} ASC
          LIMIT 20 OFFSET #{offset}"

  results = get_data_all(sql)

  @all_movies = results.to_a

  count = "SELECT COUNT(*) FROM movies;"
  all_movies_count = get_data_all(count).to_a
  all_movies_count = all_movies_count[0]["count"].to_i

  if all_movies_count % 20 == 0
    @last_page = all_movies_count / 20
  else
    @last_page = (all_movies_count / 20) + 1
  end

  erb :'movies/index'
end

get '/movies/:id' do
  id = params[:id]
  sql = "SELECT actors.id AS actor_id, actors.name AS actor, cast_members.character AS role
                FROM cast_members
                  JOIN movies ON cast_members.movie_id = movies.id
                  JOIN actors ON cast_members.actor_id = actors.id
                WHERE movies.id = $1;"

  results = get_data_params(sql, id)
  @actors = results.to_a

  sql = "SELECT movies.title, movies.year, movies.rating, genres.name AS genre, studios.name AS studio
          FROM movies
            LEFT OUTER JOIN studios ON movies.studio_id = studios.id
            JOIN genres ON movies.genre_id = genres.id
          WHERE movies.id = $1;"
  results = get_data_params(sql, id)
  @movie = results.to_a

  erb :'movies/show'
end
