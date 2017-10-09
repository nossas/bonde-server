class Activist < ActiveRecord::Base
  has_many :donations
  has_many :credit_cards, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :form_entries
  has_many :activist_pressures
  has_many :activist_matches
  has_many :activist_tags

  validates :name, :email, presence: true
  validates_format_of :email, with: /\A[^@\s]+@([^@\s]+\.)+[^@\W]+\z/

  def self.by_email email
    self.where("lower(email) = lower(?)", email.strip).order(id: :asc).first
  end

  def first_name
    name.split(' ')[0] if name
  end

  def last_name
    (name.split(' ')[1..-1]).join(' ') if name
  end

  def self.update_from_csv_content csv_content, community_id
    update_from_csv CsvReader.new(content: csv_content), community_id
  end

  def self.update_from_csv_file csv_filename, community_id
    update_from_csv CsvReader.new(file_name: csv_filename), community_id
  end

  def tag_list community_id
    activist_tag = self.activist_tags.find_by_community_id community_id
    return activist_tag.nil? ? nil : activist_tag.tag_list
  end

  def add_tag community_id, tag, mobilization = nil, date_created = DateTime.now
    if self.save
      conditions =  {
        community_id: community_id,
        mobilization_id: mobilization.try(:id)
      }

      activist_tag = self.activist_tags.find_by(conditions) || self.activist_tags.create!(conditions.merge(created_at: date_created))

      _tag = ActsAsTaggableOn::Tag.where(name: tag).last
      if !_tag.present?
        _tag = activist_tag.tags.create(
          name: tag,
          label: mobilization.try(:name)
        )
      end

      if !activist_tag.taggings.where(tag_id: _tag.id).exists?
        activist_tag.taggings.create(
          tag_id: _tag.id,
          taggable_id: activist_tag.id,
          taggable_type: 'ActivistTag',
          context: 'tags',
          created_at: date_created
        )
      end
      activist_tag.save
    end
  end

  private

  def self.update_from_csv csv_reader, community_id
    list = []
    (1 .. csv_reader.max_records).each do
      activist = (Activist.find_by_email csv_reader.email) || Activist.new
      activist.name = csv_reader.try(:name) if csv_reader.try(:name)
      activist.email = csv_reader.try(:email) if csv_reader.try(:email)
      activist.phone = csv_reader.try(:phone) if csv_reader.try(:phone)
      activist.document_number = csv_reader.try(:document_number) if csv_reader.try(:document_number)
      activist.document_type = csv_reader.try(:document_type) if csv_reader.try(:document_type)
      activist.save!

      csv_reader.tags.split(';').each { |tag| activist.add_tag community_id, tag } if csv_reader.try(:tags)

      csv_reader.next_record
      list << activist
    end
    list
  end
end
