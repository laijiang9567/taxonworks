class TaxonNameClassification::Iczn::Unavailable::Suppressed::NotInOfficialListOfAvailableNamesInZoology < TaxonNameClassification::Iczn::Unavailable::Suppressed

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000221'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Iczn::Unavailable::Suppressed,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedAndInvalidWorks,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedFamilyGroupNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedGenericNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::OfficialIndexOfRejectedSpecificNamesInZoology,
        TaxonNameClassification::Iczn::Unavailable::Suppressed::Work)
  end

end
