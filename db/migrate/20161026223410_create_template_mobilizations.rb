class CreateTemplateMobilizations < ActiveRecord::Migration
  def change
    create_table :template_mobilizations do |t|
      t.string :name
      t.integer :user_id
      t.string :color_scheme
      t.string :facebook_share_title
      t.text :facebook_share_description
      t.string :header_font
      t.string :body_font
      t.string :favicon
      t.string :facebook_share_image
      t.string :slug, null: false
      t.string :custom_domain
      t.string :twitter_share_text, limit: 140
      t.integer :organization_id
      t.integer :uses_number
      t.boolean :global

      t.timestamps null: false    end
  end
end
