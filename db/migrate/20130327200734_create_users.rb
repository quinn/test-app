class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :twitter_oauth_id
      t.string :twitter_oauth_token
      t.string :twitter_oauth_secret
      t.string :name

      t.timestamps
    end
  end
end
