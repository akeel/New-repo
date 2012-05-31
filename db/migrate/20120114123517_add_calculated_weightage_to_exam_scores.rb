class AddCalculatedWeightageToExamScores < ActiveRecord::Migration
  def self.up
    add_column :exam_scores, :calculated_weightage, :float, :default => 0.0
  end

  def self.down
    remove_column :exam_scores, :calculated_weightage
  end
end
