class CreateBootcampExercises < ActiveRecord::Migration[5.1]
  def change
    create_table :bootcamp_exercises do |t|
      t.string :title
      t.text :description
      t.references :bootcamp_module, foreign_key: true, index: true

      t.timestamps
    end
  end
end
