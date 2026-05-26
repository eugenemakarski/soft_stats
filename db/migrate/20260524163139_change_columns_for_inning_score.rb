class ChangeColumnsForInningScore < ActiveRecord::Migration[8.1]
  def change
    remove_column :inning_scores, :top_inning, :boolean
    add_column :inning_scores, :our_half, :boolean
  end
end
