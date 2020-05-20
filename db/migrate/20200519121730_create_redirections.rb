class CreateRedirections < ActiveRecord::Migration[6.0]
  def change
    create_table :redirections do |t|
      t.integer :from
      t.integer :to

      t.timestamps
    end
    add_foreign_key :redirections, :pages, column: :from
    add_foreign_key :redirections, :pages, column: :to
  end
end
