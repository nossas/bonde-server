class FixPgjwtUrlEncode < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION pgjwt.url_encode(data bytea) RETURNS text LANGUAGE sql AS $$
      SELECT translate(encode(data, 'base64'), E'+/=\\n', '-_');
$$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION pgjwt.url_encode(data bytea) RETURNS text LANGUAGE sql AS $$
      SELECT translate(encode(data, 'base64'), E'+/=\\n', '-_');
$$;
}
  end
end
