namespace :tw do
  namespace :project_import do
    namespace :sf_import do
      require 'fileutils'
      require 'logged_task'
      namespace :specimens do

        desc 'time rake tw:project_import:sf_import:specimens:collection_objects user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collection_objects => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Importing specimen records as collection objects...'

          # total (see below)
          # type (Specimen, Lot, RangedLot --  Dmitry uses lot, not ranged lot)
          # preparation_type_id (TW integer, include SF text as data attribute?)
          # respository_id (Dmitry manually reconciled these); manually reconciled, not all will be found, add sf_depo_id and sf_depo_string as attribute
          # buffered_collecting_event (no SF data)
          # buffered_determinations (no SF data)
          # buffered_other_labels (no SF data)
          # ranged_lot_category_id (leave nil)
          # collecting_event_id
          # accessioned_at (no SF data)
          # deaccession_reason (no SF data)
          # deaccessioned_at (no SF data)
          # housekeeping

          # add specimen note
          # add specimen status note (identifier?): 0 = presumed Ok, 1 = missing, 2 = destroyed, 3 = lost, 4 = unknown, 5 = missing?, 6 = destroyed?, 7 = lost?, 8 = damaged, 9 = damaged?, 10 = no data entered
          # specimen dataflags: 1 = ecological relationship, 2 = character data not yet implemented, 4 = image, 8 = sound, 16 = include specimen locality in maps, 32 = image of specimen label

          # About total:
          # @!attribute total
          #   @return [Integer]
          #   The enumerated number of things, as asserted by the person managing the record.  Different totals will default to different subclasses.  How you enumerate your collection objects is up to you.  If you want to call one chunk of coral 50 things, that's fine (total = 50), if you want to call one coral one thing (total = 1) that's fine too.  If not nil then ranged_lot_category_id must be nil.  When =1 the subclass is Specimen, when > 1 the subclass is Lot.

          # cat # = identifier on collecting event, controlled vocab term - create sf.specimen_id to catalog number hash (can do here)
          # where does the biocuration_class_id come from?
          # requires collection_object_id (biological_collection_object_id)
          # basis of record = confidence on collection object
          # preparation type = controlled vocabulary term for collection object
          # specimen count and description = BiocurationClass, object tied to collection_object (??)

          # Columns in tblSpecimens not accounted for:
          #   SpecimenStatus
          #   DepoCatNo -- recorded in hash for now, will be identifier  <<< NO, add as import_attribute
          #   SourceID citation to collection object (refID) + description as import attribute
          #   BasisOfRecord  type 5 will be asserted distribution, ignore 3, 4, and 6 (for all of 5 bor, what doesn't have refid in sourceid)
          #   VerbatimLabel NOT USED in SF, perhaps buffered collecting event


          # no count = 1?

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_user_id = import.get('SFFileUserIDToTWUserID') # for housekeeping
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_sf_unique_id = import.get('SFSpecimenToUniqueIDs') # get the unique_id for given SF specimen_id
          get_tw_collecting_event_id = import.get('SFUniqueIDToTWCollectingEventID') # use unique_id as key to collecting_event_id
          get_tw_repo_id = import.get('SFDepoIDToTWRepoID')
          get_sf_depo_string = import.get('SFDepoIDToSFDepoString')
          get_biocuration_class_id = import.get('SpmnCategoryIDToBiocurationClassID')
          get_specimen_category_counts = import.get('SFSpecimenIDCategoryIDCount')
          get_sf_source_metadata = import.get('SFSourceMetadata')
          get_sf_identification_metadata = import.get('SFIdentificationMetadata')
          # get_tw_otu_id = import.get('SFTaxonNameIDToTWOtuID')
          get_nomenclator_string = import.get('SFNomenclatorIDToSFNomenclatorString')
          get_sf_ident_qualifier = import.get('SFIdentQualifier') # key = nomenclator_id, value = ?, aff., cf., nr. ph.
          get_tw_source_id = import.get('SFRefIDToTWSourceID')
          get_sf_verbatim_ref = import.get('RefIDToVerbatimRef')


          # to get associated OTU, get TW taxon id, then get OTU from TW taxon id
          get_tw_taxon_name_id = import.get('SFTaxonNameIDToTWTaxonNameID')
          get_otu_from_tw_taxon_id = import.get('TWTaxonNameIDToOtuID')

          get_tw_collection_object_id = {} # key = SF.SpecimenID, value = TW.collection_object.id OR TW.container.id

          depo_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'SpecimenDepository', short_name: 'Depo')


          path = @args[:data_directory] + 'tblSpecimens.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          error_counter = 0
          saved_counter = 0

          file.each_with_index do |row, i|
            specimen_id = row['SpecimenID']
            next if specimen_id == '0'

            next if get_specimen_category_counts[specimen_id].blank? # ignore no critter counts for now

            project_id = get_tw_project_id[row['FileID']]
            place_in_collection_keyword = Keyword.find_or_create_by(name: 'PlaceInCollection', definition: 'possible SF source of identification', project_id: project_id)

            sf_depo_id = row['DepoID']
            repository_id = get_tw_repo_id.has_key?(sf_depo_id) ? get_tw_repo_id[sf_depo_id] : nil

            collecting_event_id = get_tw_collecting_event_id[get_sf_unique_id[specimen_id]]

            logger.info "working with SF.SpecimenID: #{specimen_id}, SF.FileID: #{row['FileID']} \n"


            # get otu id from sf taxon name id, a taxon determination, called 'the primary otu id'   (what about otus without tw taxon names?)

            # list of import_attributes (aka data_attribute with type = 'ImportAttribute'):
            data_attributes_attributes = []

            # Note: collection_objects are made for all specimen records, regardless of basis of record (for now)
            #   -- except when there is no count
            if row['BasisOfRecord'].to_i > 0
              basis_of_record_string = case row['BasisOfRecord'].to_i
                                         when 1
                                           'Preserved specimen'
                                         when 2
                                           'Fossil specimen'
                                         when 3
                                           'Image (still or video)'
                                         when 4
                                           'Audio recording'
                                         when 5
                                           'Checklist/Literature/Map'
                                         when 6
                                           'Personal observation'
                                       end
              basis_of_record = {type: 'ImportAttribute',
                                 import_predicate: 'basis_of_record',
                                 value: basis_of_record_string,
                                 project_id: project_id}
              puts "BasisOfRecord: '#{basis_of_record_string}'"
              data_attributes_attributes.push(basis_of_record)
            end

            if row['PreparationType'].present?
              preparation_type = {type: 'ImportAttribute',
                                  import_predicate: 'preparation_type',
                                  value: row['PreparationType'],
                                  project_id: project_id}
              puts "PreparationType: '#{row['PreparationType']}'"
              data_attributes_attributes.push(preparation_type)
            end

            dataflags = row['DataFlags'].to_i
            if dataflags > 0
              dataflags_array = Utilities::Numbers.get_bits(dataflags)

              # for bit_position in 0..status_flags_array.length - 1 # length is number of bits set
              dataflag_text = ''
              dataflags_array.each do |bit_position|
                # 1 = ecological relationship, 2 = character data not yet implemented, 4 = image, 8 = sound, 16 = include specimen locality in maps, 32 = image of specimen label
                case bit_position # array use .join(','), flatten?
                  when 0 # ecological relationship (1)
                    dataflag_text = '(ecological relationship)'
                  when 1 # character data not yet implemended (2)
                    dataflag_text.concat('(character data not yet implemented)')
                  when 2 # image (4)
                    dataflag_text.concat('(image)')
                  when 3 # sound (8)
                    dataflag_text.concat('(sound)')
                  when 4 # include specimen locality in maps (16)
                    dataflag_text.concat('(include specimen locality in maps)')
                  when 5 # image of specimen label (32)
                    dataflag_text.concat('(image of specimen label)')
                end
                specimen_dataflags = {type: 'ImportAttribute',
                                      import_predicate: 'specimen_dataflags',
                                      value: dataflag_text,
                                      project_id: project_id}
                puts "Specimen dataflags text: '#{dataflag_text}'"
                data_attributes_attributes.push(specimen_dataflags)
              end
            end

            specimen_status_id = row['SpecimenStatusID'].to_i
            if specimen_status_id > 0 && specimen_status_id != 10 # 0 = presumed Ok, 10 = no data entered
              specimen_status_string = case specimen_status_id
                                         when 1
                                           'missing'
                                         when 2
                                           'destroyed'
                                         when 3
                                           'lost'
                                         when 4
                                           'unknown'
                                         when 5
                                           'missing?'
                                         when 6
                                           'destroyed?'
                                         when 7
                                           'lost?'
                                         when 8
                                           'damaged'
                                         when 9
                                           'damaged?'
                                       end
              specimen_status = {type: 'ImportAttribute',
                                 import_predicate: 'specimen_status',
                                 value: specimen_status_string,
                                 project_id: project_id}
              puts "specimen_status_string (SpecimenStatusID): '#{specimen_status_string}' ('#{specimen_status_id}')"
              data_attributes_attributes.push(specimen_status)
            end

            citations_attributes = [] # if empty array will be ignored in metadata
            if row['SourceID'] != '0'
              sf_source_id = row['SourceID']

              if get_sf_source_metadata.has_key?(sf_source_id) && get_sf_source_metadata[sf_source_id]['ref_id'].to_i > 0 # SF.Source has RefID, create citation for collection object (assuming it will be created)

                # @todo: Why isn't get_tw_source_id used to get RefID, and if get_tw_source_id.has_key? RefID is false, should be attaching verbatim ref string????


                sf_source_ref_id = get_sf_source_metadata[sf_source_id]['ref_id'].to_i
                puts "SF.SourceID, RefID: '#{sf_source_id}', '#{sf_source_ref_id}'"
                citations_attributes.push({source_id: sf_source_ref_id, project_id: project_id})
              end

              if get_sf_source_metadata[sf_source_id]['description'].present? # SF.Source has description, create an import_attribute
                sf_source_description_text = get_sf_source_metadata[sf_source_id]['description']
                sf_source_description = {type: 'ImportAttribute',
                                         import_predicate: 'sf_source_description',
                                         value: sf_source_description_text,
                                         project_id: project_id}
                puts "Description: '#{sf_source_description_text}'"
                data_attributes_attributes.push(sf_source_description)
              end
            end

            if sf_depo_id > '0'
              sf_depo_string = {type: 'ImportAttribute',
                                import_predicate: 'sf_depo_string',
                                value: get_sf_depo_string[sf_depo_id],
                                project_id: project_id}
              puts "get_sf_depo_string[sf_depo_id]: '#{get_sf_depo_string[sf_depo_id]}'"
              data_attributes_attributes.push(sf_depo_string)
            end

            metadata = {notes_attributes: [{text: row['Note'],
                                            project_id: project_id,
                                            created_at: row['CreatedOn'],
                                            updated_at: row['LastUpdate'],
                                            created_by_id: get_tw_user_id[row['CreatedBy']],
                                            updated_by_id: get_tw_user_id[row['ModifiedBy']]}],

                        data_attributes_attributes: data_attributes_attributes,
                        citations_attributes: citations_attributes,

                        # data_attributes to do:
                        #   import_attribute if identification.IdentifierName
                        #   other fields in tblIdentifications: HigherTaxonName, NomenclatorID, TaxonIdentNote, TypeTaxonNameID, RefID, IdentifierName/Year,
                        #     PlaceInCollection, IdentificationModeNote, VerbatimLabel

                        # HigherTaxonName > 0 or NomenclatorID > 0 create new determination (should only be one or other)
                        # To find OTU from NomenclatorID, match cached taxon name then get OTU


            }

            # At this point all the related metadata except specimen category and count must be set

            begin

              ApplicationRecord.transaction do
                current_objects = [] # stores all objects created in the row below temporarily

                # This outer loop loops through total, category pairs, we create
                # a new collection object for each pair
                get_specimen_category_counts[specimen_id].each do |specimen_category_id, count|

                  collection_object = CollectionObject::BiologicalCollectionObject.new(
                      metadata.merge(
                          total: count,
                          collecting_event_id: collecting_event_id,
                          repository_id: repository_id,

                          biocuration_classifications_attributes: [{biocuration_class_id: get_biocuration_class_id[specimen_category_id.to_s], project_id: project_id}],

                          taxon_determinations_attributes: [{otu_id: get_otu_from_tw_taxon_id[get_tw_taxon_name_id[row['TaxonNameID']]], project_id: project_id}],
                          # taxon_determination notes here?

                          # metadata attributes:

                          # citations_attributes: citations_attributes,


                          # housekeeping for collection_object
                          project_id: project_id,
                          created_at: row['CreatedOn'],
                          updated_at: row['LastUpdate'],
                          created_by_id: get_tw_user_id[row['CreatedBy']],
                          updated_by_id: get_tw_user_id[row['ModifiedBy']]
                      ))

                  collection_object.save!

                  puts "Collection object is saved, number #{saved_counter += 1}"

                  current_objects.push(collection_object)

                end

                # At this point the collection objects have been saved successfully


                # 1) if there were two collection objects with the same SF specimen ID, then put them
                # in a virtual container
                # 2) If there is an "identifier", associate it with a single collection object or the container (if applicable)
                identifier = nil
                if row['DepoCatNo'].present?
                  identifier = Identifier::Local::CatalogNumber.new(
                      identifier: "SF.DepoID #{sf_depo_id},  #{row['DepoCatNo']}",
                      namespace: depo_namespace,
                      project_id: project_id)

                  if current_objects.count == 1
                    # The "Identifier" is attached to the only collection object that is created

                    current_objects.first.identifiers << identifier if identifier

                  elsif current_objects.count > 1
                    # There is more than one object, put them in a virtual container
                    c = Container::Virtual.create!(project_id: project_id)
                    current_objects.each do |o|
                      o.put_in_container(c)
                    end

                    c.identifiers << identifier if identifier

                  else
                    puts "OOPS" # would this happen?
                  end
                end


                if get_sf_identification_metadata.has_key?(specimen_id)
                  get_sf_identification_metadata[specimen_id].each do |identification|
                    current_objects.each do |o|

                      # Add subsequent determinations
                      target_nomenclator = nil
                      otu = nil

                      if identification['nomenclator_id'].present?
                        nomenclator_id = identification['nomenclator_id']
                        target_nomenclator = get_nomenclator_string[nomenclator_id]
                      elsif identification['higher_taxon_name'].present?
                        target_nomenclator = identification['higher_taxon_name']
                      end

                      if taxon_name = TaxonName.where(cached: target_nomenclator, project_id: project_id).first
                        otu = taxon_name.otus.first
                      else
                        otu = Otu.create!(name: target_nomenclator, taxon_name_id: get_tw_taxon_name_id[row['TaxonNameID']], project_id: project_id) # target_nomenclator nil?
                      end

                      # create conditional attributes here
                      data_attributes_attributes = []

                      source_id = nil
                      verbatim_sf_ref = nil
                      if identification['ref_id'].to_i > 0
                        sf_ref_id = identification['ref_id']
                        if get_tw_source_id.has_key?(sf_ref_id)
                          source_id = get_tw_source_id[sf_ref_id]
                        else # no TW source equiv, use verbatim as data_attribute
                          verbatim_sf_ref = {type: 'ImportAttribute',
                                             import_predicate: "verbatim_sf_ref_id_#{sf_ref_id}",
                                             value: get_sf_verbatim_ref[sf_ref_id],
                                             project_id: project_id}
                          data_attributes_attributes.push(verbatim_sf_ref)
                        end


                      end
                      # if RefID > 0.......  , notes_attributes, confidences_attributes
                      # data attribute on VerbatimLabel
                      # ident_qualifier_text: based on nomenclator_id and if get_sf_ident_qualifier.has_key? nomenclator_id


                      t = TaxonDetermination.create!(
                          otu: otu,
                          material: o,
                          # source_id: source_id,
                          # notes_attributes:,
                          # confidences_attributes: ConfidenceLevel.find_or_create_by(name: <thing that has cf>, project_id:)}],
                          # project_id: project_id
                      )
                      t.move_to_bottom # so it's not the first record

                      # need IdentifierName


                      # nomenclator rank and rank qualifier text         CVT and confidences for each project    keyword is to tag as confidence level is to confidences
                      #
                      # unify: cf. ? aff. nr.
                      #
                      #                         c = cr; aff together
                      #
                      # attached to determination


                      # VerbatimLabel	41		“2 mi NE Gold Butte, NV, Clark Co., VI-16-1988, R.C. Bechtel, J.L. Carpenter, .J.B. Knight Collectors, Black Light  Trap” “HOLOTYPE Arenivaga haringtoni Hopkins, 2012” [red label with black border]			CollectionObject#buffered_collecting_event
                      # put as data_attribute (import_attribute) on determination


                      if identification['place_in_collection'] == '1'
                        # o.keywords << place_in_collection_keyword     # equivalent to line below
                        # o.tags << Tag.new(keyword: place_in_collection_keyword, project_id: o.project_id)
                        o.tags.create!(keyword: place_in_collection_keyword, project_id: project_id)
                      end


                      type_kind_id = identification['type_kind_id'].to_i # exclude TypeKindID = undefined (0) and unknown (6)
                      if [1, 2, 3, 4, 8, 10].include? type_kind_id
                        type_text = case type_kind_id
                                      when 1
                                        'holotype'
                                      when 2
                                        if o.total == 1
                                          'syntype'
                                        else
                                          'syntypes'
                                        end
                                      when 3
                                        'neotype'
                                      when 4
                                        'lectotype'
                                      when 8
                                        if o.total == 1
                                          'paratype'
                                        else
                                          'paratypes'
                                        end
                                      when 10
                                        if o.total == 1
                                          'paralectotype'
                                        else
                                          'paralectotypes'
                                        end
                                    end
                        TypeMaterial.create!(protonym_id: get_tw_taxon_name_id[row['TaxonNameID']],
                                             material: o, # = collection_object/biological_collection_object
                                             type_type: type_text,
                                             project_id: project_id)
                        puts "type_material created for '#{type_text}'"

                      elsif [5, 7, 9].include? type_kind_id
                        # create a data_attribute
                        type_kind = case type_kind_id
                                      when 5
                                        'unspecified primary type'
                                      when 7
                                        'allotype'
                                      when 9
                                        'topotype'
                                    end
                        ImportAttribute.create!(import_predicate: 'SF.TypeKind',
                                                value: type_kind,
                                                project_id: project_id,
                                                attribute_subject: o)
                        puts "data_attribute for type_kind created for '#{type_kind}'"
                      end
                    end
                  end
                end


                puts 'CollectionObject created'
                get_tw_collection_object_id[specimen_id] = current_objects.collect {|a| a.id} # an array of collection object ids for this specimen_id

              end

            rescue ActiveRecord::RecordInvalid => e
              logger.error "CollectionObject ERROR SF.SpecimenID = #{specimen_id} (#{error_counter += 1}): " + e.record.errors.full_messages.join(';')
            end
          end

          import.set('SFSpecimenIDToCollObjID', get_tw_collection_object_id)
          puts 'SFSpecimenIDToCollObjID'
          ap get_tw_collection_object_id

        end


        desc 'time rake tw:project_import:sf_import:specimens:get_ident_qualifier_from_nomenclator user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :get_ident_qualifier_from_nomenclator => [:data_directory, :environment, :user_id] do |logger|
          logger.info '!!!!! NOTE: Re-analyze table data for new abbreviations !!!!!'

          logger.info 'Creating hash of NomenclatorID and IdentQualifier...'
          # need to test for has_key?

          get_sf_ident_qualifier = {} # key = SF.SourceID, value = hash (SourceID, FileID, RefID, Description)

          path = @args[:data_directory] + 'tblNomenclator.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|

            next if row['IdentQualifier'].blank?
            nomenclator_id = row['NomenclatorID']
            ident_qualifier = row['IdentQualifier']

            logger.info "Working with SF.NomenclatorID = '#{nomenclator_id}, IdentQualifier = '#{ident_qualifier}' \n"

            ident_qualifier_text = case ident_qualifier
                                     when '?', '(?)'
                                       '?'
                                     when 'aff.', 'sp. aff.', 'sp affinis'
                                       'aff.'
                                     when 'cf', 'cf.', 'f.'
                                       'cf.'
                                     when 'near', 'nr.'
                                       'nr.'
                                     when 'ph.'
                                       'ph.'
                                     else
                                       nil
                                   end

            next if ident_qualifier_text == nil
            get_sf_ident_qualifier[nomenclator_id] = ident_qualifier_text

          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFIdentQualifier', get_sf_ident_qualifier)

          puts 'SFIdentQualifier'
          ap get_sf_ident_qualifier
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_sf_identification_metadata user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_sf_identification_metadata => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating SF tblIdentifications metadata...'

          get_sf_identification_metadata = {} # key = SF.SpecimenID, value = array of hashes [{SeqNum => s, relevant columns => etc}, {}]

          path = @args[:data_directory] + 'tblIdentifications.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|
            specimen_id = row['SpecimenID']
            seqnum = row['SeqNum']

            logger.info "Working with SF.SpecimenID = '#{specimen_id}', SeqNum = '#{seqnum}' \n"

            this_ident = {
                :seqnum => seqnum,
                :higher_taxon_name => row['HigherTaxonName'],
                :nomenclator_id => row['NomenclatorID'],
                :taxon_ident_note => row['TaxonIdentNote'],
                :type_kind_id => row['TypeKindID'],
                :topotype => row['Topotype'],
                :type_taxon_name_id => row['TypeTaxonNameID'],
                :ref_id => row['RefID'],
                :identifier_name => row['IdentifierName'],
                :year => row['Year'],
                :place_in_collection => row['PlaceInCollection'],
                :identification_mode_note => row['IdentificationModeNote'],
                :verbatim_label => row['VerbatimLabel']
            }

            if get_sf_identification_metadata[specimen_id] # this is the same SpecimenID as last row with another seqnum, add another identification record
              get_sf_identification_metadata[specimen_id].push this_ident

            else # this is a new SpecimenID, start new identification
              get_sf_identification_metadata[specimen_id] = [this_ident]
            end

          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFIdentificationMetadata', get_sf_identification_metadata)

          puts 'SFIdentificationMetadata'
          ap get_sf_identification_metadata
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_sf_source_metadata user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_sf_source_metadata => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating SF tblSources metadata...'

          get_sf_source_metadata = {} # key = SF.SourceID, value = hash (SourceID, FileID, RefID, Description)

          path = @args[:data_directory] + 'tblSources.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|
            source_id = row['SourceID']
            next if source_id == '0'

            logger.info "Working with SF.SourceID = '#{source_id}' \n"

            get_sf_source_metadata[source_id] = {file_id: row['FileID'], ref_id: row['RefID'], description: row['Description']}
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFSourceMetadata', get_sf_source_metadata)

          puts 'SFSourceMetadata'
          ap get_sf_source_metadata
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_specimen_category_counts user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_specimen_category_counts => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating specimen category counts...'

          get_specimen_category_counts = {} # key = SF.SpecimenID, value = array [category0, count0] [category1, count1]
          #previous_specimen_id = '0'

          path = @args[:data_directory] + 'tblSpecimenCounts.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

          file.each do |row|
            specimen_id = row['SpecimenID']
            specimen_category_id = row['SpmnCategoryID'].to_i
            count = row['Count'].to_i.abs

            logger.info "Working with SF.SpecimenID = '#{specimen_id}', specimen_category_id = '#{specimen_category_id}', count = '#{count}' \n"

            if get_specimen_category_counts[specimen_id] # specimen_id == previous_specimen_id # this is the same SpecimenID as last row, add another category/count
              get_specimen_category_counts[specimen_id].push [specimen_category_id, count]

            else # this is a new SpecimenID, start new category/count
              get_specimen_category_counts[specimen_id] = [[specimen_category_id, count]]
              # previous_specimen_id = specimen_id
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFSpecimenIDCategoryIDCount', get_specimen_category_counts)

          puts 'SFSpecimenIDCategoryIDCount'
          ap get_specimen_category_counts
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_biocuration_classes user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_biocuration_classes => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Creating biocuration classes...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')

          get_biocuration_class_id = {} # key = SF.tblSpecimenCategories.SpmnCategoryID, value = TW.biocuration_class.id

          path = @args[:data_directory] + 'sfSpecimenCategories.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            spmn_category_id = row['SpmnCategoryID']
            next if spmn_category_id == '0'
            project_id = get_tw_project_id[row['FileID']]

            logger.info "Working with SF.SpmnCategoryID '#{spmn_category_id}', SF.FileID '#{row['FileID']}', project.id = '#{project_id}' \n"

            biocuration_class = BiocurationClass.create!(name: row['SingularName'], definition: row['PluralName'], project_id: project_id)
            get_biocuration_class_id[spmn_category_id] = biocuration_class.id.to_s
          end

          import.set('SpmnCategoryIDToBiocurationClassID', get_biocuration_class_id)

          puts 'SpmnCategoryIDToBiocurationClassID'
          ap get_biocuration_class_id
        end


        desc 'time rake tw:project_import:sf_import:specimens:import_sf_depos user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :import_sf_depos => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Importing SF depo_strings and SF to TW depo/repo mappings...'

          get_sf_depo_string = {} # key = sf.DepoID, value = sf.depo_string
          get_tw_repo_id = {} # key = sf.DepoID, value = tw respository.id; ex. ["23, 25, 567"] => {1 => tw_repo_id, 2 => tw_repo_id, 3 => tw_repo_id}
          # Note: Many SF DepoIDs will not be mapped to TW repo_ids

          count_found = 0

          path = @args[:data_directory] + 'sfDepoStrings.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            depo_id = row['DepoID']

            depo_string = row['DepoString']

            logger.info "Working with SF.DepoID '#{depo_id}', SF.NomenclatorString '#{depo_string}' (count #{count_found += 1}) \n"

            get_sf_depo_string[depo_id] = depo_string
          end

          path = @args[:data_directory] + 'sfTWDepoMappings.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|
            sf_depo_id_array = row['SFDepoIDarray']
            next if sf_depo_id_array.blank?

            tw_repo_id = row['TWDepoID']
            logger.info "Working with TWD/RepoID '#{tw_repo_id}', SFDepoIDarray '#{sf_depo_id_array}' \n"

            sf_depo_id_array = sf_depo_id_array.split(", ").map(&:to_i)
            sf_depo_id_array.each do |each_id|
              get_tw_repo_id[each_id] = tw_repo_id
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFDepoIDToSFDepoString', get_sf_depo_string)
          import.set('SFSpecimenIDToCatalogNumber', get_depo_catalog_number)

          puts 'SFDepoIDToSFDepoString'
          ap get_sf_depo_string

          puts 'SFDepoIDToTWRepoID'
          ap get_tw_repo_id

        end


        desc 'time rake tw:project_import:sf_import:specimens:collecting_events user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :collecting_events => [:data_directory, :environment, :user_id] do |logger|

          logger.info 'Building new collecting events...'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          get_tw_project_id = import.get('SFFileIDToTWProjectID')
          get_sf_geo_level4 = import.get('SFGeoLevel4')

          # var = get_sf_geo_level4['lskdfj']['Name']

          get_tw_collecting_event_id = {} # key = sfUniqueLocColEvents.UniqueID, value = TW.collecting_event_id

          # SF.TimePeriodID to interval code (https://paleobiodb.org/data1.2/intervals/single.json?name='')
          TIME_PERIOD_MAP = {
              768 => 1, # Cenozoic
              784 => 12, # Quaternary
              790 => 32, # Holocene
              795 => 33, # Pleistocene
              800 => 13, # Tertiary
              804 => 25, # Neogene
              805 => 34, # Pliocene
              806 => 35, # Miocene
              808 => 26, # Paleogene
              809 => 36, # Oligocene
              810 => 37, # Eocene
              811 => 38, # Paleocene
              1024 => 2, # Mesozoic
              1040 => 14, # Cretaceous
              1056 => 15, # Jurassic
              1072 => 16, # Triassic
              1280 => 3, # Paleozoic
              1296 => 17, # Permian
              1312 => 18, # Carboniferous
              1316 => 27, # Pennsylvanian
              1320 => 28, # Mississippian
              1328 => 19, # Devonian
              1344 => 20, # Silurian
              1360 => 21, # Ordovician
              1376 => 22, # Cambrian
              # 1536 => nil,  # Precambrian
              1552 => 752, # Proterozoic
              1568 => 753, # Archaean vs. Archean
              1584 => 11 # Hadean
          }.freeze

          path = @args[:data_directory] + 'sfUniqueLocColEvents.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          # FileID
          # Level1ID	Level2ID	Level3ID	Level4ID
          # Latitude	Longitude	PrecisionCode
          # Elevation	MaxElevation
          # TimePeriodID
          # LocalityDetail
          # TimeDetail
          # DataFlags, ignore: bitwise, 1 = ecological relationship, 2 = character data (not implemented?), 4 = image, 8 = sound, 16 = include specimen locality in maps, 32 = image of specimen label
          # Country	State	County
          # BodyOfWater
          # PrecisionRadius
          # LatLongFrom, ignore
          # CollectorName
          # Year MonthDay
          # DaysToEnd
          # UniqueID

          counter = 0
          error_counter = 0

          # Working with TW.project_id = 3, UniqueID = 42414 (count 42414): Year 1993, Month 2, Day 29 (not a leap year), FileID = 1, TaxonNameID = 1140695, CollectEventID = 6584
          # ActiveRecord::RecordInvalid: Validation failed: Start date day 29 is not a valid start_date_day for the month provided
          # [0] 1993,
          # [1] 2,
          # [2] 29,
          # [3] nil,
          # [4] nil,
          # [5] nil


          file.each do |row|
            project_id = get_tw_project_id[row['FileID']]

            logger.info "Working with TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (count #{counter += 1}) \n"

            this_year, this_month, this_day = row['Year'], row['Month'], row['Day']

            # in rescue below, used collect_event.errors vs. c.error
            # if (this_year == '1900' || this_year == '1993') && this_month == '2' && this_day == '29'
            #   this_month, this_day = '3', '1'
            # end

            d = this_day != "0"
            m = this_month != "0"
            y = !((this_year == "1000") || (this_year == "0"))
            dte = row['DaysToEnd'].to_i.abs != 0

            start_date_year, start_date_month, start_date_day,
                end_date_year, end_date_month, end_date_day =

                case [y, m, d, dte] # year, month, day, days_to_end

                  when [true, true, true, true] # have (year, month, day, days_to_end)

                  when [true, true, true, false] # have (year, month, day), no days_to_end
                    [this_year.to_i, this_month.to_i, this_day.to_i, nil, nil, nil]

                  when [true, true, false, false] # have (year, month), no (day, days_to_end)
                    [this_year.to_i, this_month.to_i, nil, nil, nil, nil]

                  when [true, false, false, false] # have year, no (month, day, days_to_end)
                    [this_year.to_i, nil, nil, nil, nil, nil]

                  when [false, true, true, false] # no year, have (month, day), no days_to_end
                    [nil, this_month.to_i, this_day.to_i, nil, nil, nil]

                  when [false, true, true, true] # no year, have (month, day, days_to_end)
                    sdm = this_month.to_i
                    sdd = this_day.to_i
                    dte = row['DaysToEnd'].to_i.abs
                    start_date = Date.new(1999, sdm, sdd) # an arbitrary non-leap year
                    end_date = dte.days.from_now(start_date)

                    [nil, sdm, sdd, nil, end_date.month, end_date.year]

                  else
                    [nil, nil, nil, nil, nil, nil]
                end


            data_attributes_bucket = {
                data_attributes_attributes: [],
                # project_id: project_id  # cannot universally assign project_id to all array attribute hashes
                # rest of housekeeping?
            }

            if row['TimeDetail'].present?
              time_detail = {type: 'ImportAttribute', import_predicate: 'TimeDetail', value: row['TimeDetail'], project_id: project_id}
              data_attributes_bucket[:data_attributes_attributes].push(time_detail)
            end

            location_string = {type: 'ImportAttribute', import_predicate: 'CountryStateCounty',
                               value: [row['Country'], row['State'], row['County']].join(':'), project_id: project_id}
            data_attributes_bucket[:data_attributes_attributes].push(location_string)

            if row['BodyOfWater'].present?
              body_of_water = {type: 'ImportAttribute', import_predicate: 'BodyOfWater', value: row['BodyOfWater'], project_id: project_id}
              data_attributes_bucket[:data_attributes_attributes].push(body_of_water)
            end

            p_code = row['PrecisionCode'].to_i
            if p_code > 0
              value = case p_code
                        when 1 then
                          'from locality label'
                        when 2 then
                          'estimated from map and locality label'
                        when 3 then
                          'based on county or similar modest area specified on locality label'
                        when 4 then
                          'estimated from less specific locality label'
                        else
                          'error'
                      end

              precision_code = {type: 'ImportAttribute', import_predicate: 'PrecisionCode', value: value, project_id: project_id}
              data_attributes_bucket[:data_attributes_attributes].push(precision_code)
            end

            # do we still need next line?
            # start_date_year, end_date_year = nil, nil if row['Year'] == "1000"

            ap [start_date_year, start_date_month, start_date_day, end_date_year, end_date_month, end_date_day]

            # metadata = {
            #     # data_attributes_attributes: data_attributes_bucket
            #
            #
            # }.merge(data_attributes_bucket)


            lat, long = row['Latitude'], row['Longitude']
            c = CollectingEvent.new(
                {
                    verbatim_latitude: (lat.length > 0) ? lat : nil,
                    verbatim_longitude: (long.length > 0) ? long : nil,
                    maximum_elevation: row['MaxElevation'].to_i,
                    verbatim_locality: row['LocalityDetail'],
                    verbatim_collectors: row['CollectorName'],
                    start_date_day: start_date_day,
                    start_date_month: start_date_month,
                    start_date_year: start_date_year,
                    end_date_day: end_date_day,
                    end_date_month: end_date_month,
                    end_date_year: end_date_year,
                    geographic_area: get_tw_geographic_area(row, logger, get_sf_geo_level4),

                    project_id: project_id
                    # paleobio_db_interval_id: TIME_PERIOD_MAP[row['TimePeriodID']], # TODO: Matt add attribute to CE !! rember ENVO implications
                }.merge(data_attributes_bucket)
            )

            begin
              c.save!
              logger.info "UniqueID #{row['UniqueID']} written"

              get_tw_collecting_event_id[row['UniqueID']] = c.id.to_s

              begin
                pr = row['PrecisionRadius'].to_i
                c.generate_verbatim_data_georeference(true, no_cached: true) # reference self, no cache
                if c.georeferences.any?
                  c.georeferences[0].error_radius = pr unless pr == '0'
                else
                  # georeference failed (bad lat/long?)
                end

              rescue ActiveRecord::RecordInvalid

                logger.error "Error: TW.project_id = #{project_id}, UniqueID = #{row['UniqueID']} (error count #{error_counter += 1}) \n"
              end

            rescue ActiveRecord::RecordInvalid # bad date?
              logger.error "CollectEvent error: FileID = #{row['FileID']}, UniqueID = #{row['UniqueID']}, Year = #{this_year}, Month = #{this_month}, Day = #{this_day}, DaysToEnd = #{row['DaysToEnd']}, (error count #{error_counter += 1})" + c.errors.full_messages.join(';')
              next
            end
          end

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFUniqueIDToTWCollectingEventID', get_tw_collecting_event_id)

          puts 'SFUniqueIDToTWCollectingEventID'
          ap get_tw_collecting_event_id

        end

        # Find a TW geographic_area
        # @todo JDT HELP!
        def get_tw_geographic_area(row, logger, sf_geo_level4_hash)

          tw_area = nil
          l1, l2, l3, l4 = row['Level1ID'], row['Level2ID'], row['Level3ID'], row['Level4ID']
          l1 = '' if l1 == '0'
          l2 = '' if l2 == '-'
          l3 = '' if l3 == '---'
          l4 = '' if l4 == '---'
          t1 = l1
          t2 = t1 + l2
          t3 = t2 + l3
          tdwg_id = l1
          tdwg_id = t3 if l4 == ''
          tdwg_id = t2 if l3 == ''
          tdwg_id = t1 if l2 == ''
          tdwg_id.strip!

          if tdwg_id.blank?
            case l4
              when /\d+/ # any digits, needs translation
                # TODO @MB if level 4 is a number, look up county name in SFGeoLevel4
                # packet = 0
                name = sf_geo_level4_hash[(t3 + t4)][:name].chomp('County').strip
                tw_area = GeographicArea.where("\"tdwgID\" like '#{t3}%' and name like '%#{name}%'").first
              when /[a-z]/i # if it exists, it might be directly findable
                tdwg_id = (t3 + '-' + l4).strip
                tw_area = GeographicArea.where(tdwgID: tdwg_id).first
                if tw_area.nil? # fall back to next larger container
                  tw_area = GeographicArea.where(tdwgID: t3).first
                end
              else # must be ''
                tw_area = GeographicArea.where(tdwgID: t3).first
            end
          end

          logger.info "target tdwg id: #{tdwg_id}"

          tw_area
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_sf_geo_level4_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        # consists of unique_key: (level3_id, level4_id, name, country_code)
        LoggedTask.define :create_sf_geo_level4_hash => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running create_sf_geo_level4_hash...'

          get_sf_geo_level4 = {} # key = unique_key (combined level3_id + level4_id), value = level3_id, level4_id, name, country_code (from tblGeoLevel4)

          path = @args[:data_directory] + 'sfGeoLevel4.txt'
          file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each_with_index do |row, i|

            logger.info "working with UniqueKey #{row['UniqueKey']}"

            get_sf_geo_level4[row['UniqueKey']] = {level3_id: row['Level3ID'], level4_id: row['Level4ID'], name: row['Name'], country_code: row['CountryCode']}
          end

          puts 'Getting ready to display results -- takes longer than it seems it should!'

          import = Import.find_or_create_by(name: 'SpeciesFileData')
          import.set('SFGeoLevel4', get_sf_geo_level4)

          puts 'SFGeoLevel4'
          ap SFGeoLevel4
        end


        desc 'time rake tw:project_import:sf_import:specimens:create_specimen_unique_id user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/'
        LoggedTask.define :create_specimen_unique_id => [:data_directory, :environment, :user_id] do |logger|
          # Can be run independently at any time

          logger.info 'Running new specimen lists (hash, array)...'

          # get_new_preserved_specimen_id = [] # array of SF.SpecimenIDs with BasisOfRecord = 0 (not stated) but with DepoID or specimen count
          get_sf_unique_id = {} # key = SF.SpecimenID, value = sfUniqueLocColEvents.UniqueID


          # logger.info '1. Getting new preferred specimen ids'
          #
          # path = @args[:data_directory] + 'sfAddPreservedSpecimens.txt'
          # file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')
          #
          # file.each do |row|
          #   get_new_preserved_specimen_id.push(row[0])
          # end


          logger.info '2. Getting SF SpecimenID to UniqueID hash'

          count = 0

          path = @args[:data_directory] + 'sfSpecimenToUniqueIDs.txt'
          file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

          file.each do |row|
            puts "SpecimenID = #{row['SpecimenID']}, count #{count += 1} \n"
            get_sf_unique_id[row['SpecimenID']] = row['UniqueLocColEventID']
          end


          import = Import.find_or_create_by(name: 'SpeciesFileData')
          # import.set('SFNewPreservedSpecimens', get_new_preserved_specimen_id)
          import.set('SFSpecimenToUniqueIDs', get_sf_unique_id)

          # puts 'SFNewPreservedSpecimens'
          # ap get_new_preserved_specimen_id

          puts 'SFSpecimenToUniqueIDs'
          ap get_sf_unique_id
        end

      end
    end
  end
end

