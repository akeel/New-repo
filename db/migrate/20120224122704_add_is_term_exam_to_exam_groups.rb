class AddIsTermExamToExamGroups < ActiveRecord::Migration
  def self.up
  add_column :exam_groups, :is_term, :boolean
  end

  def self.down
  remove_column :exam_groups, :is_term 
  end
end
