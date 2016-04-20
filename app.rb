require 'sinatra'
require_relative 'config/application'

helpers do
  def current_user
    if @current_user.nil? && session[:user_id]
      @current_user = User.find_by(id: session[:user_id])
      session[:user_id] = nil unless @current_user
    end
    @current_user
  end
end

def clear_form
  session[:name], session[:location], session[:description] = "", "", ""
end

get '/' do
  redirect '/meetups'
end

get '/auth/github/callback' do
  user = User.find_or_create_from_omniauth(env['omniauth.auth'])
  session[:user_id] = user.id
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/meetups' do
  clear_form
  @meetups = Meetup.all.sort { |a, b| a.name <=> b.name }
  erb :'meetups/index'
end

get '/meetups/show/:id' do
  meetup_id = params[:id]
  @meetup = Meetup.where(id: meetup_id).first
  @attendees = @meetup.users
  erb :'meetups/show'
end

get '/meetups/join/:id' do
  if session[:user_id] == nil
    flash[:notice] = "You must be signed in to join a meetup"
  else
    attendee = Attendee.create(user_id: session[:user_id], meetup_id: params[:id])
    if attendee.save
      flash[:notice] = "You have joined the meetup"
    else
      flash[:notice] = "You already joined this meetup"
    end
  end
  redirect '/'
end

get '/meetups/new' do
  @form_data = { name: session[:name], location: session[:location], description: session[:description] }
  erb :'meetups/new'
end

post '/meetups' do
  if session[:user_id] == nil
    flash[:notice] = "You must be signed in to do that."
    redirect '/'
  end
  meetup = Meetup.new(creator_id: session[:user_id], name: params[:name], location: params[:location], description: params[:description])
  if meetup.save
    flash[:notice] = "Meetup created successfully"
    clear_form
  else
    error = meetup.errors.full_messages.first
    flash[:notice] = "#{error}"
    session[:name], session[:location], session[:description] = params[:name], params[:location], params[:description]
    redirect '/meetups/new'
  end
  redirect '/meetups'
end
