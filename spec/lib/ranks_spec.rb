require 'spec_helper'
require 'ranks'

describe 'Ranks' do

  context 'constants' do
    context 'are build without error from config/initializers/ranks.rb' do
      specify '::RANKS' do
        expect(RANKS).to be_true
      end

      specify '::ICN' do
        expect(ICN).to be_true
      end

      specify '::ICN_LOOKUP' do
        expect(ICN_LOOKUP).to be_true
        expect(ICN_LOOKUP.class).to eq(Hash)
      end

      specify '::ICZN' do
        expect(ICZN).to be_true
      end

      specify '::ICZN_LOOKUP' do
        expect(ICZN).to be_true
        expect(ICZN_LOOKUP.class).to eq(Hash)
      end
    end

    context 'class methods' do

      specify "top_rank returns top assignable rank" do
        # The top two levels 
        expect(Ranks.top_rank(NomenclaturalRank::Iczn)).to eq(NomenclaturalRank::Iczn::HigherClassificationGroup::Superkingdom)
        expect(Ranks.top_rank(NomenclaturalRank::Icn)).to eq(NomenclaturalRank::Icn::HigherClassificationGroup::Kingdom)

        # Behaviour is a little different
        expect(Ranks.top_rank(NomenclaturalRank::Iczn::FamilyGroup)).to eq(NomenclaturalRank::Iczn::FamilyGroup::SuperfamilyGroup)
      end

      specify "ordered_ranks_for returns descendant classes" do
        expect(Ranks.ordered_ranks_for(NomenclaturalRank::Icn::FamilyGroup)).to eq(
          [NomenclaturalRank::Icn::FamilyGroup::Family,
           NomenclaturalRank::Icn::FamilyGroup::Subfamily,
           NomenclaturalRank::Icn::FamilyGroup::Tribe,
           NomenclaturalRank::Icn::FamilyGroup::Subtribe]
        )
      end

      specify "rank.lookup return false" do
        expect(Ranks.lookup(:iczn, 'false')).to be_false
      end

      specify "rank.lookup return proper class for ICZN rank" do
        expect(Ranks.lookup(:iczn, 'Family').to_s).to eq("NomenclaturalRank::Iczn::FamilyGroup::Family")
      end

      specify "rank.lookup return proper class for ICN rank" do
        expect(Ranks.lookup(:icn, 'Family').to_s).to eq("NomenclaturalRank::Icn::FamilyGroup::Family")
      end

    end


  end
end 





