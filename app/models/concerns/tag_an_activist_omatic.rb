module TagAnActivistOmatic
  def add_automatic_tags
    tag = "#{widget.kind}_#{widget.mobilization.name}".downcase.gsub( /\W|\-{2}/, '-' ).gsub( /-{2}/, '-' )

    activist.add_tag widget.community.id, tag
  end
end