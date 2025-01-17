require 'bundler/setup'
Bundler.require
after do
  ActiveRecord::Base.connection.close
end

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

#unless ENV['RACK_ENV'] == 'production'
#    ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
#end

class User < ActiveRecord::Base
  has_many :tokens
  has_many :chats
  has_many :rooms,  through: :userrooms
  has_many :userrooms
  has_many :friends
  has_many :alerts
	has_many :favorooms
  has_secure_password
  validates :mail,
    presence: true,
    format: {with:/.+@.+/}
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end

class Chat < ActiveRecord::Base
  belongs_to :room
  belongs_to :user
  paginates_per 200
end

class Room < ActiveRecord::Base
  has_many :users,  through: :userrooms
  has_many :chats#, through: :readrooms
  has_many :userrooms
	has_many :favorooms
  paginates_per 40
end

class Userroom < ActiveRecord::Base
  enum status: {normal: 0, admin: 1, watch: 2, block: 3}
  validates :user_id, uniqueness: { scope: [:room_id] } 
  belongs_to :room
  belongs_to :user
  has_many :friends
end

class Token < ActiveRecord::Base
  belongs_to :user
end

class Friend < ActiveRecord::Base
  enum status: {not_friend: 0, friend: 1, intimate: 2, block: 3}
  belongs_to :user
  belongs_to :userroom
	belongs_to :alert
end

class Alert < ActiveRecord::Base
  enum status: {room: 0, friend: 1}
  belongs_to :user
	belongs_to :friend
  paginates_per 20
end

class Favoroom < ActiveRecord::Base
	belongs_to :room
	belongs_to :user
end
 
# class Readchat < ActiveRecord::Base 
# 	belongs_to :room
# 	belongs_to :chat
# end
