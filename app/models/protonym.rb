class Protonym < TaxonName

  has_many :taxon_name_classifications

  alias_method :original_combination_source, :source

  # subject                      object
  # Aus      original_genus of   bus
  # aus      type_species of     Bus

  TaxonNameRelationship.descendants.each do |d|
    if d.respond_to?(:assignment_method) 
      relationship = "#{d.assignment_method}_relationship".to_sym
      has_one relationship, class_name: d.name.to_s, foreign_key: :object_taxon_name_id 
      has_one d.assignment_method.to_sym, through: relationship, source: :subject_taxon_name
    end

    if d.respond_to?(:inverse_assignment_method)
      # eval inverse method here
    end
  end

  has_one :type_taxon_name_relationship, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id 
   
  has_one :type_taxon_name, through: :type_taxon_name_relationship, source: :subject_taxon_name

  has_many :type_of_relationships, -> {
    where("taxon_name_relationships.type LIKE 'TaxonNameRelationship::Typification::%'")
    }, class_name: 'TaxonNameRelationship', foreign_key: :subject_taxon_name_id

  has_many :type_of_taxon_names, through: :type_of_relationships, source: :object_taxon_name

  has_many :original_combination_relationships, -> {
    where("taxon_Name_relationships.type LIKE 'TaxonNameRelationship::OriginalCombination::%'")
  }, class_name: 'TaxonNameRelationship', foreign_key: :object_taxon_name_id

  scope :named, -> (name) {where(name: name)}

  scope :with_rank_class, -> (rank_class_name) {where(rank_class: rank_class_name)}

  scope :with_base_of_rank_class, -> (rank_class) {where('rank_class LIKE ?', "#{rank_class}%")}
  scope :with_rank_class_including, -> (include_string) {where('rank_class LIKE ?', "%#{include_string}%")}
 
  scope :descendants_of, -> (taxon_name) {where('(taxon_names.lft >= ?) and (taxon_names.lft <= ?) and (taxon_names.id != ?) and (taxon_names.project_id = ?)', taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id  )}
  scope :ancestors_of, -> (taxon_name) {where('(taxon_names.lft <= ?) and (taxon_names.rgt >= ?) and (taxon_names.id != ?) and (taxon_names.project_id = ?)', taxon_name.lft, taxon_name.rgt, taxon_name.id, taxon_name.project_id  )}

  scope :with_taxon_name_relationships_as_subject, -> {
    joins(:taxon_name_relationships)
  }
 scope :with_taxon_name_relationships_as_object, -> {
    joins(:related_taxon_name_relationships)
  }

 # Or ('|') returns an array, not an AREL
 scope :with_taxon_name_relationships, -> {self.with_taxon_name_relationships_as_subject | self.with_taxon_name_relationships_as_object }

 scope :without_subject_taxon_name_relationships, -> {
   includes(:taxon_name_relationships).
   where(taxon_name_relationships: {subject_taxon_name_id: nil})
 }
 scope :without_object_taxon_name_relationships, -> {
   includes(:related_taxon_name_relationships).
   where(taxon_name_relationships: {object_taxon_name_id: nil})
 }
 
 scope :without_taxon_name_relationships, -> { self.without_subject_taxon_name_relationships.merge(self.without_object_taxon_name_relationships) }


  # scope :without_relationships, -> {
  #   joins( [:taxon_name_relationships, :related_taxon_name_relationships] ).
  #   where( {:taxon_name_relationships => { subject_taxon_name_id: nil }, :related_taxon_name_relationships => { object_taxon_name_id: nil }} )
  # }

  # scope :with_relationships, -> {
  #   includes(:taxon_name_relationships, :related_taxon_name_relationships). 
  #   where( :taxon_name_relationships => { subject_taxon_name_id: !nil }, :related_taxon_name_relationships => { object_taxon_name_id: !nil } )
  # }

  soft_validate(:sv_source_older_then_description)
  soft_validate(:sv_validate_parent_rank)
  soft_validate(:sv_missing_relationships)
  soft_validate(:sv_type_placement)
  soft_validate(:sv_validate_coordinated_names)

  # TODO: validate if the rank can change, only within one group.

  # region Soft validation

  def sv_source_older_then_description
    if self.source && self.year_of_publication
      soft_validations.add(:source_id, 'The year of publication and the year of reference do not match') if self.source.year != self.year_of_publication
    end
  end

  def sv_validate_parent_rank
    if self.rank_class.to_s == 'NomenclaturalRank'
      true
    elsif self.parent.rank_class.to_s == 'NomenclaturalRank'
      true
    elsif !self.rank_class.valid_parents.include?(self.parent.rank_class.to_s)
      soft_validations.add(:rank_class, "The rank #{self.rank_class.rank_name} is not compatible with the rank of parent (#{self.parent.rank_class.rank_name})")
    end
  end

  def sv_missing_relationships
    if SPECIES_RANKS_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Original genus is missing') if self.original_combination_genus.nil?
    elsif GENUS_RANKS_NAMES.include?(self.rank_class.to_s)
      soft_validations.add(:base, 'Type species is not selected') if self.type_species.nil?
    elsif FAMILY_RANKS_NAMES.include?(self.rank_class.to_s)
      if self.type_genus.nil?
        soft_validations.add(:base, 'Type genus is not selected')
      elsif self.name.slice(0, 1) != self.type_genus.name.slice(0, 1)
        soft_validations.add(:base, 'Type genus should have the same initial letters as the family-group name')
      end
    end
  end

  def sv_validate_coordinated_names
    search_rank = NomenclaturalRank::Iczn.group_base(self.rank_string)
    if search_rank
      if search_rank =~ /Family/ 
        z = Protonym.family_group_base(self.name)
        search_name = z.nil? ? nil : "#{z}(ini|ina|inae|idae|oidae|odd|ad|oidea)"
      else
        search_name = self.name
      end
    else
      search_name = nil
    end

    unless search_name.nil?
      list = self.ancestors_and_descendants                               # scope with parens
      list = list.select{|i| /#{search_rank}.*/.match(i.rank_class.to_s)} # scope on rank_class 
      list = list.select{|i| /#{search_name}/.match(i.name)}              # scope on named 
      list = list.reject{|i| i.unavailable_or_invalid?}                   # scope with join on taxon_name_relationships and where > 1 on them

      # Using scopes assignment will be done with single query rather than loops, and be something like:
      #  list = TaxonName.ancestors_and_descendants_of(self).with_rank_of(search_rank).named(<something?!>).unavailable.invalid

      list.each do |t|
        #:TODO think about fixes to tests below
        soft_validations.add(:source_id, "The source does not match with the source of the coordinated #{t.rank_class.rank_name}") if self.source_id != t.source_id
        soft_validations.add(:verbatim_author, "The author does not match with the author of the coordinated #{t.rank_class.rank_name}") if self.verbatim_author != t.verbatim_author
        soft_validations.add(:year_of_publication, "The year does not match with the year of the coordinated #{t.rank_class.rank_name}") if self.year_of_publication != t.year_of_publication
        soft_validations.add(:base, "The original genus does not match with the original genus of coordinated #{t.rank_class.rank_name}") if self.original_combination_genus != t.original_combination_genus
        soft_validations.add(:base, "The original subgenus does not match with the original subgenus of the coordinated #{t.rank_class.rank_name}") if self.original_combination_subgenus != t.original_combination_subgenus
        soft_validations.add(:base, "The original species does not match with the original species of the coordinated #{t.rank_class.rank_name}") if self.original_combination_species != t.original_combination_species
        soft_validations.add(:base, "The type species does not match with the type species of the coordinated #{t.rank_class.rank_name}") if self.type_species != t.type_species
        soft_validations.add(:base, "The type genus does not match with the type genus of the coordinated #{t.rank_class.rank_name}") if self.type_genus != t.type_genus
      end
    end

  end

  def ancestors_and_descendants
    self.ancestors.to_a + self.descendants.to_a
  end

  def self.family_group_base(name_string)
    name_string.match(/(^.*)(ini|ina|inae|idae|oidae|odd|ad|oidea)/)
    $1
  end

  def sv_type_placement
    # type of this taxon is not included in this taxon
    if !!self.type_taxon_name
      unless self.unavailable_or_invalid?
        soft_validations.add(:base, "The type should be included in this #{self.rank_class.rank_name}") unless self.type_taxon_name.ancestors.include?(self)
      else
      end
    end
    # this taxon is a type, but not included in nominal taxon
    if !!self.type_of_taxon_names
      unless self.unavailable_or_invalid?
        self.type_of_taxon_names.each do |t|
          soft_validations.add(:base, "This taxon is type of #{t.rank_class.rank_name} #{t.name} but is not included there") unless self.type_taxon_name.ancestors.include?(t)
        end
      else
      end
    end
  end

  #endregion

end
