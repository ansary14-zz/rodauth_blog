class CreateRodauthOauth < ActiveRecord::Migration[6.1]
  def change
    create_table :oauth_applications do |t|
      t.integer :account_id
      t.foreign_key :accounts, column: :account_id
      t.string :name, null: false
      t.string :description, null: false
      t.string :homepage_url, null: false
      t.string :redirect_uri, null: false
      t.string :client_id, null: false, index: { unique: true }
      t.string :client_secret, null: false, index: { unique: true }
      t.string :scopes, null: false
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :oauth_grants do |t|
      t.integer :account_id
      t.foreign_key :accounts, column: :account_id
      t.integer :oauth_application_id
      t.foreign_key :oauth_applications, column: :oauth_application_id
      t.string :code, null: false
      t.datetime :expires_in, null: false
      t.string :redirect_uri
      t.datetime :revoked_at
      t.string :scopes, null: false
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      # for using access_types
      t.string :access_type, null: false, default: "offline"
      # uncomment to enable PKCE
      # t.string :code_challenge
      # t.string :code_challenge_method
      # uncomment to use OIDC nonce
      # t.string :nonce
      t.index(%i[oauth_application_id code], unique: true)
    end

    create_table :oauth_tokens do |t|
      t.integer :account_id
      t.foreign_key :accounts, column: :account_id
      t.integer :oauth_grant_id
      t.foreign_key :oauth_grants, column: :oauth_grant_id
      t.integer :oauth_token_id
      t.foreign_key :oauth_tokens, column: :oauth_token_id
      t.integer :oauth_application_id
      t.foreign_key :oauth_applications, column: :oauth_application_id
      t.string :token, null: false, token: true, unique: true
      # uncomment if setting oauth_tokens_token_hash_column
      # and delete the token column
      # t.string :token_hash, token: true, unique: true
      t.string :refresh_token, unique: true
      # uncomment if setting oauth_tokens_refresh_token_hash_column
      # and delete the refresh_token column
      # t.string :refresh_token_hash, token: true, unique: true
      t.datetime :expires_in, null: false
      t.datetime :revoked_at
      t.string :scopes, null: false
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
      # uncomment to use OIDC nonce
      # t.string :nonce
    end
  end
end