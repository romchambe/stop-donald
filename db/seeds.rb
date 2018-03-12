# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create(username: 'Michel', email: "a@example.com", password: "foobar", password_confirmation: "foobar")
User.create(username: 'Jean-Michel', email: "c@example.com", password: "foobar", password_confirmation: "foobar")
User.create(username: 'Robert', email: "e@example.com", password: "foobar", password_confirmation: "foobar")
User.create(username: 'Marco', email: "user@example.com", password: "foobar", password_confirmation: "foobar")

game_1 = Game.new
game_1.creator = User.first
game_1.save
game_2 = Game.new
game_2.creator = User.last
game_2.save
