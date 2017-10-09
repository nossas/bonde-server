module TagAnActivistOmatic
  def add_automatic_tags
    if widget.mobilization.present?
      tag_to_add = "#{widget.kind}_#{widget.mobilization.name}".downcase.gsub( /\W|\-{2}/, '-' ).gsub( /-{2}/, '-' )

      self.activist
        .add_tag(
          widget.community.id,
          tag_to_add,
          widget.mobilization,
          self.created_at
      ) if activist && widget
    end
  end
end