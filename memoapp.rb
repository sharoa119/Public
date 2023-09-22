# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

PATH = 'public/memoapp.json'

def memos(path)
  File.open(path) do |file|
    JSON.parse(file.read)
  end
end

get '/' do
  redirect '/memos'
end

get '/memos' do
  @memos = memos(PATH)
  erb :index
end

get '/memos/:id' do
  id = params[:id]
  memos = memos(PATH)

  memo = memos.find { |m| m['id'] == id }
  if memo
    @title = memo['title']
    @content = memo['content']
    erb :detail
  else
    '<font size="7">Not Found(x_x)</font>'
  end
end

get '/new' do
  erb :newentry
end

def register(path, memos)
  File.open(path, 'wb') do |file|
    JSON.dump(memos, file)
  end
end

post '/memos' do
  maxid = 0
  memos = memos(PATH)
  memos.each do |m|
    id = m['id'].to_i
    maxid = id if id > maxid
  end

  new_memo = {
    'id' => (maxid + 1).to_s,
    'title' => params[:title],
    'content' => params[:content]
  }

  memos << new_memo
  register(PATH, memos)

  redirect '/memos'
end

get '/memos/:id/edit' do
  id = params[:id]
  memos = memos(PATH)

  memo = memos.find { |m| m['id'] == id }

  @title = memo['title']
  @content = memo['content']
  erb :edit
end

patch '/memos/:id' do
  id = params[:id]
  memos = memos(PATH)

  memo = memos.find { |m| m['id'] == id }
  if memo
    memo['title'] = params[:title]
    memo['content'] = params[:content]

    register(PATH, memos)
  end

  redirect "/memos/#{id}"
end

delete '/memos/:id' do
  id = params[:id]
  memos = memos(PATH)

  memos.reject! { |m| m['id'] == id }

  register(PATH, memos)

  redirect '/memos'
end

get '/*' do
  '<font size="7">Not Found(x_x)</font>'
end