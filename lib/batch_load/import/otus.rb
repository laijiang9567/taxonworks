require 'digest/bubblebabble'

module BatchLoad
  # TODO: Originally transliterated from Import::CollectionObjects: Remove this to-do after successful operation.
  class Import::Otus < BatchLoad::Import

    attr_accessor :otus

    def initialize(**args)
      @otus = {}
      super(args)
    end

    def build_otus
      # test_build
      build_objects = {}
      i             = 1 # accounting for headers
      csv.each do |row|
        parse_result = BatchLoad::RowParse.new
        # creation of the possible-objects list
        parse_result.objects.merge!(otu: [])
        # attach the results to the row
        @processed_rows.merge!(i => parse_result)

        # hot-wire the project into the row
        unless row[0].blank?
          row['project_id'] = @project_id.to_s if row['project_id'].blank?
        end

        begin # processing the Otu
          otu            = nil
          otu_attributes = {name: row['otu_name']}
          otu_list       = BatchLoad::ColumnResolver.otu(row)
          otu            = otu_list.item if otu_list.resolvable?
          otu_match      = Digest::SHA256.digest(otu_attributes.to_s)
          otu            = build_objects[otu_match] if otu.blank?
          otu            = Otu.new(otu_attributes) if otu.blank?
          build_objects.merge!(otu_match => otu)
          parse_result.objects[:otu].push(otu)
        end

        i += 1
      end
      @total_lines = i - 1

    end

    def build
      if valid?
        build_otus
        @processed = true
      end
    end
  end
end

