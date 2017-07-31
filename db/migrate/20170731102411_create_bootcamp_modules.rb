class CreateBootcampModules < ActiveRecord::Migration[5.1]
  def change
    create_table :bootcamp_modules do |t|
      t.string :title
      t.string :repo
      t.text :description

      t.timestamps
    end
  end
end
