class ChangeBlocksPositionsOrder < ActiveRecord::Migration
  def change
    Mobilization.find_each do |mobi|
      if mobi.blocks.where(position: nil).count >= 1
        x = 0
        mobi.blocks.where(deleted_at: nil).order(:id).each do |block|
          block.position = x + 1
          block.save
        end
      end
    end
  end
end
