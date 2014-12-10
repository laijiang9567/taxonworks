# The identifier that is globaly unique.
#
# Curators of a specific project assert one canonical global identifier per type for each object, this 
# identifier is identified by having .relation.nil?.  If the curators feel there are multiple global identifiers 
# for a given instance they must provide an explicit relationship between the canonical identifier and the 
# alternate identifiers.
#
# @!attribute relation 
#   @return [String]
#   Defines the relationship between the curator asserted canonical identifier and other identifiers
#   of the same type. Must be provided for every global identifier of the same type beyond the first.
#   Relations are drawn from skos (http://www.w3.org/TR/skos-reference/#mapping) 
#
class Identifier::Global < Identifier 

  # see http://www.w3.org/TR/skos-reference/#mapping 
  RELATIONS = { 
    'skos:broadMatch' => 'Broad match (implies a whole and parts, or hierarchical relation).',    
    'skos:narrowMatch' => 'Narrow match (implies a whole and parts, or hierarchical relation).',  
    'skos:relatedMatch' => 'Related match (an associative relation, neither more general nor specific).',
    'skos:closeMatch' => 'Close match (almost the same, but not interchangable).',  
    'skos:exactMatch' => 'Exact match (the same, interchangable)'
  }

  validates :namespace_id, absence: true
  validates :relation, inclusion: { in: RELATIONS.keys }, allow_nil: true 
  validate :permit_only_one_global_without_relation_supplied_per_type

  # Identifier can only be used once, i.e. mapped to a single TW concept
  validates_uniqueness_of :identifier, scope: [:project_id]

  protected

  def set_cached_value
    self.cached = identifier
  end

  def permit_only_one_global_without_relation_supplied_per_type
    if identifier_object && identifier_object.identifiers.where(type: self.type.to_s).any? 
      errors.add(:relation, " an existing identifier of type #{self.type} exists, a relation for this identifier must be provided") if self.relation.nil?
    end
  end

end
