class TaxonNameRelationship < ActiveRecord::Base

  include Housekeeping

  validates_presence_of :type, :subject_taxon_name_id, :object_taxon_name_id


  validates_uniqueness_of :object_taxon_name_id,  scope: :type, if: :is_combination?
  validates_uniqueness_of :object_taxon_name_id,  scope: [:type, :subject_taxon_name_id], unless: :is_combination?

  def is_combination?
    !!/TaxonNameRelationship::(Original|)Combination/.match(self.type.to_s)
  end
  #validates_uniqueness_of :object_taxon_name_id,  scope: [:type, :subject_taxon_name_id]

  belongs_to :subject_taxon_name, class_name: 'TaxonName', foreign_key: :subject_taxon_name_id # left side
  belongs_to :object_taxon_name, class_name: 'TaxonName', foreign_key: :object_taxon_name_id # right side

  before_validation :validate_type,
                    :validate_subject_and_object_share_code,
                    :validate_valid_subject_and_object

  def aliases
    []
  end

  def self.object_properties
    []
  end

  def self.subject_properties
    []
  end

  def self.valid_subject_ranks
    []
  end

  # right_side
  def self.valid_object_ranks
    []
  end

  def self.assignable
    false
  end

  def type_name
    TAXON_NAME_RELATIONSHIP_NAMES.include?(self.type) ? self.type.to_s : nil
  end

  def type_class=(value)
    write_attribute(:type, value.to_s)
  end

  def type_class
    r = read_attribute(:type)
    TAXON_NAME_RELATIONSHIP_NAMES.include?(r) ? r.constantize : r
  end


  protected

  # TODO: Flesh this out vs. TaxonName#rank_class.  Ensure that FactoryGirl type can be set in postgres branch.
  def validate_type
    errors.add(:type, "'#{type}' is not a validly_published taxon name relationship") if !TAXON_NAME_RELATIONSHIP_NAMES.include?(type.to_s)
  end

  def validate_subject_and_object_share_code
    if object_taxon_name.class == Protonym && subject_taxon_name.class == Protonym
      errors.add(:object_taxon_name_id, "The related taxon is from different nomenclatural code") if subject_taxon_name.rank_class.nomenclatural_code != object_taxon_name.rank_class.nomenclatural_code
    end
  end

  def validate_valid_subject_and_object
    if self.subject_taxon_name.nil?
      errors.add(:subject_taxon_name_id, "Please select a taxon")
    elsif self.object_taxon_name.nil?
      errors.add(:object_taxon_name_id, "Please select a taxon")
    elsif self.subject_taxon_name && self.object_taxon_name
      errors.add(:subject_taxon_name_id, "Rank of the taxon is not compatible with the status") if !self.type_class.valid_subject_ranks.include?(subject_taxon_name.rank_class.to_s)
      if object_taxon_name.class == Protonym
        errors.add(:object_taxon_name_id, "Rank of the taxon is not compatible with the status") if !self.type_class.valid_object_ranks.include?(object_taxon_name.rank_class.to_s)
      else
        errors.add(:object_taxon_name_id, "Rank of the taxon is not compatible with the status") if !self.type_class.valid_object_ranks.include?(object_taxon_name.parent.rank_class.to_s)
      end
    end
  end
end
