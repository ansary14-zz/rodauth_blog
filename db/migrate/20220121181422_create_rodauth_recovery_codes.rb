class CreateRodauthRecoveryCodes < ActiveRecord::Migration[6.1]
  def change
    # Used by the recovery codes feature
    create_table :account_recovery_codes, primary_key: [:id, :code] do |t|
      t.column :id, :bigint
      t.foreign_key :accounts, column: :id
      t.string :code
    end
  end
end
