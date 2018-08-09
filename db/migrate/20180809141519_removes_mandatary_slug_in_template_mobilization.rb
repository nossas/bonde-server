class RemovesMandatarySlugInTemplateMobilization < ActiveRecord::Migration
  def up
    execute <<-SQL
      alter table public.template_mobilizations alter column slug drop not null;
    SQL
  end

  def down
    execute <<-SQL
      alter table public.template_mobilizations alter column slug drop not null;
    SQL
  end
end
