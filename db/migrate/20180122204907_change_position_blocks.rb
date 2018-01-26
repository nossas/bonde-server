class ChangePositionBlocks < ActiveRecord::Migration
  def change
    Mobilization.find_each do |mobi|
      if mobi.blocks.where(position: nil).count >= 1
        x = 1
        last_block = mobi.blocks.where("deleted_at is null and position is not null").order(position: :desc).first
        mobi.blocks.where("deleted_at is null and position is null").order(:id).each do |block|
          block.position = last_block.position + x
          block.save
          puts "Block: #{block.id} UPDATED"
          x + 1
        end
      end
    end
  end
end
