class CreateThings < ActiveRecord::Migration[5.2]
  def change
    create_table :things do |t|
      t.text :what
      t.text :where
      t.string :when
      t.text :why

      t.timestamps
    end
  end
end
