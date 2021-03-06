FactoryBot.define do
  factory :gene_attribute, traits: [:housekeeping] do
    factory :valid_gene_attribute do
      association :descriptor, factory: :valid_descriptor_gene
      association :sequence, factory: :valid_sequence 
      sequence_relationship_type { SequenceRelationship::ReversePrimer }
#     association :controlled_vocabulary_term, factory: :valid_controlled_vocabulary_term
    end
  end
end
