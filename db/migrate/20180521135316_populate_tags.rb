# coding: utf-8
class PopulateTags < ActiveRecord::Migration
  def change
    execute %Q{
INSERT INTO tags (name, label)
VALUES
('user_meio-ambiente', 'Meio Ambiente'),
('user_direitos-humanos', 'Direitos Humanos'),
('user_seguranca-publica', 'Segurança pública'),
('user_mobilidade', 'Mobilidade'),
('user_direito-das-mulheres', 'Direito das Mulheres'),
('user_feminismo', 'Feminismo'),
('user_participacao-social', 'Participação Social'),
('user_educacao', 'Educação'),
('user_transparencia', 'Transparência'),
('user_direito-lgbtqi+', 'Direito LGBTQI+'),
('user_direito-a-moradia', 'Direito à Moradia'),
('user_combate-a-corrupcao', 'Combate à Corrupção'),
('user_combate-ao-racismo', 'Combate ao Racismo'),
('user_saude-publica', 'Saúde Pública')
ON CONFLICT (name)
DO NOTHING;
}
  end
end
