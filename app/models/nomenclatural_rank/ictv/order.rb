class NomenclaturalRank::Ictv::Order < NomenclaturalRank::Ictv

  def self.parent_rank
    NomenclaturalRank::Ictv::Kingdom
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'name must end in -viralis') if not(taxon_name.name =~ /.*(viralis)\Z/)
  end

  def self.abbreviation
    'ord.'
  end

end