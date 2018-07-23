class FixPgjwtVerify < ActiveRecord::Migration
  def up
    execute %Q{
CREATE OR REPLACE FUNCTION pgjwt.verify(token text, secret text, algorithm text DEFAULT 'HS256')
      RETURNS table(header json, payload json, valid boolean) LANGUAGE sql AS $$
        SELECT
          convert_from(pgjwt.url_decode(r[1]), 'utf8')::json AS header,
          convert_from(pgjwt.url_decode(r[2]), 'utf8')::json AS payload,
          r[3] = pgjwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
        FROM regexp_split_to_array(token, '\\.') r;
      $$;
}
  end

  def down
    execute %Q{
CREATE OR REPLACE FUNCTION pgjwt.verify(token text, secret text, algorithm text DEFAULT 'HS256')
      RETURNS table(header json, payload json, valid boolean) LANGUAGE sql AS $$
        SELECT
          convert_from(pgjwt.url_decode(r[1]), 'utf8')::json AS header,
          convert_from(pgjwt.url_decode(r[2]), 'utf8')::json AS payload,
          r[3] = pgjwt.algorithm_sign(r[1] || '.' || r[2], secret, algorithm) AS valid
        FROM regexp_split_to_array(token, '\.') r;
      $$;
}
  end
end
