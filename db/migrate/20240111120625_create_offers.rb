class CreateOffers < ActiveRecord::Migration[7.1]
  def change
    create_table :offers do |t|
      t.string :title
      t.text :description
      t.text :photo_urls
      t.text :product_options
      t.float :ratings
      t.text :feedbacks
      t.decimal :price
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
