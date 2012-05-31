class AddHostelToStudents < ActiveRecord::Migration
  def self.up
    add_column :students, :hostel_id, :integer
  end

  def self.down
    remove_column :students, :hostel_id
  end
end
