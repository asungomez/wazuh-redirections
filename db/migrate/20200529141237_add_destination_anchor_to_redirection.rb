class AddDestinationAnchorToRedirection < ActiveRecord::Migration[6.0]
  def change
    add_column :redirections, :destination_anchor, :string
  end
end
