class AddOriginAnchorToRedirection < ActiveRecord::Migration[6.0]
  def change
    add_column :redirections, :origin_anchor, :string
  end
end
