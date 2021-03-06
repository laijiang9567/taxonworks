require_dependency 'application_enumeration'

# Contains methods used in /config/initializers/constants/ranks.rb to generate Rank Classes
module Ranks

  # @return [Boolean] true if rank.to_s is the name of a NomenclaturalRank.
  # @param [String] rank
  def self.valid?(rank)
    ::RANKS.include?(rank.to_s)
  end

  # @param [Symbol] code
  # @param [Symbol] rank
  # @return [String] representing the name of the NomenclaturalRank class
  #   Ranks::lookup(:iczn, 'superfamily')   # => 'NomenclaturalRank::Iczn::FamilyGroup::Superfamily'
  def self.lookup(code, rank)
    rank = rank.to_s
    raise if ![:iczn, :icn, :icnp, :ictv].include?(code)
    r = rank.downcase
    case code
      when :iczn
        ::ICZN_LOOKUP[r]
      when :icnp
        ::ICNB_LOOKUP[r]
      when :ictv
        ::ICTV_LOOKUP[r]
      when :icn
        ::ICN_LOOKUP[r]
      else
        return false
    end
  end

end
