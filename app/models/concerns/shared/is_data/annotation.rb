
module Shared::IsData::Annotation

  extend ActiveSupport::Concern

  # This is indirectly responsible for
  # visual position placement in radial annotator
  # middle is left, top/bottom right

  # see config/initializes/constanst/model/annotations for types

  module ClassMethods
    # @return [Boolean]
    # true if model is an "annotator" (e.g. identifiers, tags, notes, data attributes, alternate values, citations), i.e. data that references another data element through STI
    def annotates?
      respond_to?(:annotated_object)
    end

    # Determines whether the class can be annotated
    # in one of the following ways
    ::ANNOTATION_TYPES.each do |t|
      define_method("has_#{t}?") do
        k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
        self < k ? true : false
      end
    end
  end

  # Determines whether the instance can be annotated
  # in one of the following ways
  ::ANNOTATION_TYPES.each do |t|
    define_method("has_#{t}?") do
      k = "Shared::#{t.to_s.singularize.classify.pluralize}".safe_constantize
      self.class < k ? true : false
    end
  end

  # Doesn't belong here
  def has_loans?
    self.class < Shared::Loanable ? true : false
  end

  # @return [#annotations_hash]
  #   an accessor for the annotations_hash, overwritten by some inheriting classes
  def annotations
    annotations_hash
  end

  def available_annotation_types
    ::ANNOTATION_TYPES.select do |a|
      self.send("has_#{a}?")
    end
  end

  # @return [Hash]
  def annotation_metadata
   h = (available_annotation_types - [:attribution]).inject({}){|hsh, a| hsh.merge!(a => {total: send(a).count})}
   if has_attribution?
     h[:attribution] = {total: (send(:attribution).present? ? 1 : 0)} 
   end
   h 
  end

  protected

  # @return [Hash]
  # Contains all "annotations" for this instance
  def annotations_hash
    result = {}
    result['citations'] = citations if has_citations? && citations.any?
    result['data attributes'] = data_attributes if has_data_attributes? && data_attributes.any? # why no underscore?
    result['identifiers'] = identifiers if has_identifiers? && identifiers.any?
    result['notes'] = notes if has_notes? && notes.any?
    result['tags'] = tags if has_tags? && tags.any?
    result['depictions'] = depictions.order('depictions.position') if has_depictions? && depictions.any?
    result['confidences'] = confidences if has_confidences? && confidences.any?
    result['protocol relationships'] = protocols if has_protocol_relationships? && protocolled?
    result['alternate values'] = alternate_values if has_alternate_values? && alternate_values.any?
    result['attribution'] = attribution if has_attribution? && attribution.any?
    result
  end

end


