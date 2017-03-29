class TaxonNameClassification::Icnb::NotEffectivelyPublished < TaxonNameClassification::Icnb

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000082'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnb::EffectivelyPublished)
  end

  def self.gbif_status
    'invalidum'
  end

end