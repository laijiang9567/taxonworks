require 'fileutils'

### rake tw:project_import:species_file:create_users user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/working/ no_transaction=true

## check out default user_id if SF.FileUserID < 1

namespace :tw do
  namespace :project_import do
    namespace :sf_start do

      # Outstanding issues for ProjectSources
      #   Add data_attribute to ProjectSources from sfVerbatimRefs (this is instead of dealing with tblRefs.ContainingRefID)
      #   Add tblRefs.Note as?
      #   Currently ProjectSources do not allow data_attributes or notes


      # Following tasks no longer used because SF.unpublished_sources added as TW.verbatim_sources in create_sources 6 June 2016
      # desc 'convert TW.sources of bibtex type = book to be bibtex type = unpublished'
      # task :update_sources_with_unpublished_info => [:data_directory, :environment, :user_id] do
      #   ### time rake tw:project_import:species_file:update_sources_with_unpublished_info user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      #   # @todo: Not found: Bayard. Date unknown. Dolling's Manuscript Parts. << AccessCode = 1 << RefID = 29143, PubID = 15058; not sure why this failed
      #
      #   species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
      #   get_pub_id_unpublished_info = species_file_data.get('SFPubIDUnpublishedSourceTitle')
      #   get_source_id = species_file_data.get('SFRefIDToTWSourceID')
      #
      #   # Read each RefID:PubID; if PubID is included in Book hash, update source record.
      #
      #   path = @args[:data_directory] + 'working/tblRefs.txt'
      #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")
      #
      #   error_count = 0
      #   successful_update_counter = 0
      #
      #   file.each_with_index do |row, i|
      #     next if get_pub_id_unpublished_info[row['PubID']].nil?
      #     next if (row['Title'].empty? and row['PubID'] == '0' and row['Series'].empty? and row['Volume'].empty? and row['Issue'].empty? and row['ActualYear'].empty? and row['StatedYear'].empty?) or row['AccessCode'] == '4'
      #
      #     puts "working with RefID #{row['RefID']} = SourceID #{get_source_id[row['RefID']]}, PubID = #{row['PubID']}"
      #
      #     source = Source.find_by(id: get_source_id[row['RefID']].to_i)
      #     # if can't find
      #     if source.nil?
      #       puts "Error: Source not found (RefID = #{row['RefID']}), Error #{error_count += 1}"
      #     elsif source.class == Source::Verbatim
      #       puts "Verbatim source, skipping"
      #     elsif not source.update(get_pub_id_unpublished_info[row['PubID']].merge({bibtex_type: 'unpublished'})) # merges hash of titles with changed bibtex_type info
      #       puts "Failed to update,  Error #{error_count += 1}, msg: #{source.errors.messages}"
      #     else
      #       successful_update_counter += 1
      #     end
      #
      #   end
      #   puts "Unpublished sources processed = #{successful_update_counter}, Errors = #{error_count}"
      # end
      #
      # desc 'create unpublished sources array'
      # task :create_sf_unpublished_sources_array => [:data_directory, :environment, :user_id] do
      #   ### time rake tw:project_import:species_file:create_sf_unpublished_sources_array user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      #
      #   species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
      #   sf_pub_id_unpublished_sources_array = []
      #
      #   path = @args[:data_directory] + 'working/tblPubs.txt'
      #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")
      #
      #   file.each_with_index do |row, i|
      #     next unless row['PubType'] == '4' # unpublished source
      #
      #     print "working with PubID #{row['PubID']} \n"
      #
      #     sf_pub_id_unpublished_sources_array.push(row['PubID'])
      #   end
      #
      #   species_file_data.set('SFPubIDUnpublishedSourcesArray', sf_pub_id_unpublished_sources_array)
      #   ap sf_pub_id_unpublished_sources_array
      # end

      # desc 'create unpublished sources hash consisting of title only'
      # task :create_sf_unpublished_source_hash => [:data_directory, :environment, :user_id] do
      #   ### time rake tw:project_import:species_file:create_sf_unpublished_source_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      #
      #   species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
      #   sf_pub_id_to_unpublished_title = {}
      #
      #   path = @args[:data_directory] + 'working/tblPubs.txt'
      #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")
      #
      #   file.each_with_index do |row, i|
      #     next unless row['PubType'] == '4' # unpublished source
      #
      #     print "working with PubID #{row['PubID']} \n"
      #
      #     sf_pub_id_to_unpublished_title[row['PubID']] = {title: row['ShortName']}
      #   end
      #
      #   species_file_data.set('SFPubIDUnpublishedSourceTitle', sf_pub_id_to_unpublished_title)
      #   ap sf_pub_id_to_unpublished_title
      # end

      desc 'update TW.sources of bibtex type = book'
      task :update_sources_with_book_info => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:species_file:update_sources_with_book_info user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
        # @todo Not found: Slater, J.A. Date unknown. A Catalogue of the Lygaeidae of the world. << RefID = 44058, PubID = 21898

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_pub_id_book_info = species_file_data.get('SFPubIDTitlePublisherAddress')
        get_source_id = species_file_data.get('SFRefIDToTWSourceID')

        # Read each RefID:PubID; if PubID is included in Book hash, update source record.

        path = @args[:data_directory] + 'working/tblRefs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        error_count = 0
        successful_update_counter = 0

        file.each_with_index do |row, i|
          next if get_pub_id_book_info[row['PubID']].nil?
          next if (row['Title'].empty? and row['PubID'] == '0' and row['Series'].empty? and row['Volume'].empty? and row['Issue'].empty? and row['ActualYear'].empty? and row['StatedYear'].empty?) or row['AccessCode'] == '4'

          puts "working with RefID #{row['RefID']} = SourceID #{get_source_id[row['RefID']]}, PubID = #{row['PubID']}"

          source = Source.find_by(id: get_source_id[row['RefID']].to_i)
          # if can't find
          if source.nil?
            puts "Error: Source not found (RefID = #{row['RefID']}), Error #{error_count += 1}"
          elsif source.class == Source::Verbatim
            puts "Verbatim source, skipping"
          elsif not source.update(get_pub_id_book_info[row['PubID']])
            puts "Failed to update,  Error #{error_count += 1}, msg: #{source.errors.messages}"
          else
            successful_update_counter += 1
          end

        end
        puts "Books processed = #{successful_update_counter}, Errors = #{error_count}"
      end

      desc 'create book hash consisting of book_title:, publisher:, and place_published: (address)'
      task :create_sf_book_hash => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:species_file:create_sf_book_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        sf_pub_id_to_booktitle_publisher_address = {}

        path = @args[:data_directory] + 'working/tblPubs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          next unless row['PubType'] == '3' # book

          print "working with PubID #{row['PubID']}"

          sf_pub_id_to_booktitle_publisher_address[row['PubID']] = {booktitle: row['ShortName'], publisher: row['Publisher'], address: row['PlacePublished']}
        end

        species_file_data.set('SFPubIDTitlePublisherAddress', sf_pub_id_to_booktitle_publisher_address)
        ap sf_pub_id_to_booktitle_publisher_address
      end

      desc 'create RefIDToPubID hash      UNUSED!!'
      task :create_ref_id_to_pub_id_hash => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:species_file:create_ref_id_to_pub_id_hash user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        sf_ref_id_to_sf_pub_id_hash = {}

        path = @args[:data_directory] + 'working/tblRefs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each do |row|
          sf_ref_id_to_sf_pub_id_hash[row['RefID']] = row['PubID']
        end

        species_file_data.set('SFRefIDToPubID', sf_ref_id_to_sf_pub_id_hash)
        puts 'SF.RefID to SF.PubID'
        ap sf_ref_id_to_sf_pub_id_hash

      end

      desc 'run rake between sources and source roles'
      task :run_tasks_between_sources_and_source_roles => [:create_source_editor_array, :create_source_roles] do
        ### time rake tw:project_import:species_file:run_tasks_between_sources_and_source_roles user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
        # Takes >64 minutes to run
        puts 'Done with :create_source_editor_array, :create_source_roles'
      end

      desc 'create source roles'
      task :create_source_roles => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:species_file:create_source_roles user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_person_id = species_file_data.get('SFPersonIDToTWPersonID')
        get_source_id = species_file_data.get('SFRefIDToTWSourceID')
        get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        source_editor_array = species_file_data.get('TWSourceEditorList') # if source.id is in array

        path = @args[:data_directory] + 'working/tblRefAuthors.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        error_counter = 0

        file.each_with_index do |row, i|

          # Check if TW.source record is verbatim, reloop
          # source_id = get_source_id[row['RefID']].to_i
          source_id = get_source_id[row['RefID']]
          next if source_id.nil?
          source_id = source_id.to_i
          # next if Source.find(source_id).class == Source::Verbatim # Source.find(source_id).type == 'Source::Verbatim'
          next if Source.find(source_id).try(:class) == Source::Verbatim # Source.find(source_id).type == 'Source::Verbatim'

          print "working with RefID #{row['RefID']} = SourceID #{source_id}, position #{row['SeqNum']} \n"

          # project_id = ProjectSource.find_by_source_id(source_id).project_id

          # set flag if person is also editor; after role.save, make new record if is_editor
          is_editor = source_editor_array.include?(source_id)

          role = Role.new(
              person_id: get_person_id[row['PersonID']],
              type: 'SourceAuthor',
              role_object_id: source_id,
              role_object_type: 'Source',
              position: row['SeqNum'],
              # project_id: project_id,   # don't use for SourceAuthor or SourceEditor
              created_at: row['CreatedOn'],
              updated_at: row['LastUpdate'],
              created_by_id: get_user_id[row['CreatedBy']],
              updated_by_id: get_user_id[row['ModifiedBy']]
          )

          if role.save

            if is_editor
              role = Role.new(
                  person_id: get_person_id[row['PersonID']],
                  type: 'SourceEditor',
                  role_object_id: source_id,
                  role_object_type: 'Source',
                  position: row['SeqNum'],
                  # project_id: project_id,
                  created_at: row['CreatedOn'],
                  updated_at: row['LastUpdate'],
                  created_by_id: get_user_id[row['CreatedBy']],
                  updated_by_id: get_user_id[row['ModifiedBy']]
              )

              unless role.save
                error_counter += 1
                puts "     ERROR (#{error_counter}, editor): " + role.errors.full_messages.join(';')
                puts "  RefID: #{row['RefID']}, position: #{row['SeqNum']}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
              end
            end

          else
            error_counter += 1
            puts "     ERROR (#{error_counter}, author): " + role.errors.full_messages.join(';')
            puts "  RefID: #{row['RefID']}, position: #{row['SeqNum']}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
          end
        end

      end

      desc 'create source editor array (via tblRefs)'
      task :create_source_editor_array => [:data_directory, :environment, :user_id] do
        ### time rake tw:project_import:species_file:create_source_editor_array user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        # is_editor, tblRefs.flags & 2 = 2 if set
        # loop through Refs and store only those w/editors

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        get_source_id = species_file_data.get('SFRefIDToTWSourceID')
        tw_source_id_editor_list = []

        path = @args[:data_directory] + 'working/tblRefs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each do |row|
          print "working with #{row['RefID']} \n"

          tw_source_id_editor_list.push(get_source_id[row['RefID']]) if row['Flags'].to_i & 2 == 2
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('TWSourceEditorList', tw_source_id_editor_list)

        puts 'TWSourceEditorList'
        ap tw_source_id_editor_list
      end

      desc 'run all rake tasks through sources without no_ref_list'
      ### rake time tw:project_import:species_file:run_tasks_through_sources user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      task :run_tasks_through_sources => [:create_users, :create_people, :map_serials, :map_pub_type,
                                          :map_ref_link, :list_verbatim_refs, :create_projects, :create_sources] do
        # task :run_tasks_through_sources => [:create_users, :create_people, :map_serials, :map_pub_type, :create_no_ref_list_array,
        #                                     :map_ref_link, :list_verbatim_refs, :create_projects, :create_sources] do
        puts 'Ran create_users, create_people, map_serials, map_pub_type, map_ref_link, list_verbatim_refs, create_project, create_sources'
      end

      desc 'create sources'
      task :create_sources => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:species_file:create_sources user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        puts 'Running create_sources...'

        # @todo

        # tblRefs columns to import: Title, PubID, Series, Volume, Issue, RefPages, ActualYear, StatedYear, LinkID, LastUpdate, ModifiedBy, CreatedOn, CreatedBy
        # tblRefs other columns: RefID => Source.identifier, FileID => used when creating ProjectSources, ContainingRefID => sfVerbatimRefs contains full
        #   RefStrings attached as data_attributes in ProjectSources (no need for ContainingRefID), AccessCode => n/a, Flags => identifies editor
        #   (use when creating roles and generating author string from tblRefAuthors), Note => attach to ProjectSources, CiteDataStatus => can be derived,
        #   Verbatim => not used

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        # get_person_id = species_file_data.get('SFPersonIDToTWPersonID') # not needed until roles
        get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        get_serial_id = species_file_data.get('SFPubIDToTWSerialID') # for FK
        get_pub_type = species_file_data.get('SFPubIDToPubType') # = bibtex_type (1=journal=>article, 2=unused, 3=book or cd=>book, 4=unpublished source=>unpublished)
        get_ref_link = species_file_data.get('RefIDToRefLink') # key is SF.RefID, value is URL string
        get_verbatim_ref = species_file_data.get('RefIDToVerbatimRef') # key is SF.RefID, value is verbatim string
        # no_ref_list = species_file_data.get('SFNoRefList') # contains array of RefInRef ids w/only author info
        get_project_id = species_file_data.get('SFFileIDToTWProjectID')

        # get_source_id = sf_start_data.get('SFRefIDToTWSourceID') # cross ref hash
        # get_source_id ||= {} # make empty hash if doesn't exist (otherwise it would be nil)
        get_source_id = {} # make empty hash
        sf_ref_id_to_tw_source_id = get_source_id

        # byebug

        # Namespace for Identifier
        # source_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblRefs', short_name: 'SF RefID')

        error_counter = 0

        path = @args[:data_directory] + 'working/tblRefs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          # break if i == 20
          # next if row["RefID"].to_i < 38387
          ref_id = row['RefID']
          # next if no_ref_list.include?(ref_id)
          next if (row['Title'].empty? and row['PubID'] == '0' and row['Series'].empty? and row['Volume'].empty? and row['Issue'].empty? and row['ActualYear'].empty? and row['StatedYear'].empty?) or row['AccessCode'] == '4'

          print "working with #{ref_id} \n"

          pub_type = get_pub_type[row['PubID']]

          actual_year = row['ActualYear']
          # actual_year = nil if actual_year == '0'
          stated_year = row['StatedYear']
          # stated_year = nil if stated_year == '0'

          if actual_year == '0' or stated_year == '0' or actual_year.include?('-') or stated_year.include?('-') or pub_type == 'unpublished'
            # create a verbatim source
            source = Source::Verbatim.new(
                verbatim: get_verbatim_ref[ref_id],
                # url: row['LinkID'].to_i > 0 ? get_ref_link[ref_id] : nil,   # Not compatible with verbatim
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_user_id[row['CreatedBy']],
                updated_by_id: get_user_id[row['ModifiedBy']]
            )
          else
            source = Source::Bibtex.new(
                bibtex_type: pub_type,
                title: row['Title'],
                serial_id: get_serial_id[row['PubID']],
                series: row['Series'],
                volume: row['Volume'],
                number: row['Issue'],
                pages: row['RefPages'],
                year: actual_year,
                stated_year: stated_year,
                url: row['LinkID'].to_i > 0 ? get_ref_link[ref_id] : nil,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_user_id[row['CreatedBy']],
                updated_by_id: get_user_id[row['ModifiedBy']]
            )
          end

          if source.save

            # source.identifiers << Identifier::Local::Import.new(namespace: source_namespace, identifier: ref_id)
            sf_ref_id_to_tw_source_id[ref_id] = source.id

            # populate project_sources:  Can I just do create here?
            ProjectSource.create!(
                project_id: get_project_id[row['FileID']],
                source_id: source.id,
                created_at: row['CreatedOn'],
                updated_at: row['LastUpdate'],
                created_by_id: get_user_id[row['CreatedBy']],
                updated_by_id: get_user_id[row['ModifiedBy']]
            )

          else
            error_counter += 1
            puts "     ERROR (#{error_counter}): " + source.errors.full_messages.join(';')
            puts "  RefID: #{ref_id}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
          end
        end

        # Write to Imports
        species_file_data.set('SFRefIDToTWSourceID', sf_ref_id_to_tw_source_id)
        puts 'SF.RefID to TW.source_id'
        ap sf_ref_id_to_tw_source_id

      end

      desc 'create projects'
      # create mb as project member, admin, for each project??
      task :create_projects => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:sf_start:create_projects user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        puts 'Running create_projects...'

        species_file_data = Import.find_or_create_by(name: 'SpeciesFileData')
        # Is it really really necessary to track original creator, etc? Don't think so.
        # get_user_id = species_file_data.get('FileUserIDToTWUserID') # for housekeeping
        get_project_id = species_file_data.get('SFFileIDToTWProjectID') # cross ref hash
        get_project_id ||= {} # make empty hash if doesn't exist (otherwise it would be nil)
        sf_file_id_to_tw_project_id = get_project_id

        path = @args[:data_directory] + 'working/tblFiles.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row, i|
          file_id = row['FileID']
          next if file_id == "0" # was integer 0 which failed!

          website_name = row['WebsiteName'].downcase # want to be lower case

          project = Project.new(
              name: "#{website_name}_species_file",
              created_at: Time.now, # row['CreatedOn'],
              updated_at: Time.now, # row['LastUpdate'],
              created_by_id: $user_id, # get_user_id[row['CreatedBy']],
              updated_by_id: $user_id # get_user_id[row['ModifiedBy']]
          )

          if project.save

            sf_file_id_to_tw_project_id[file_id] = project.id

            # create mb as project member for each project
            # pm = ProjectMember.new(user: user, project: project, is_project_administrator: true)
            # pm.save! if pm.valid?


          else
            error_counter += 1
            puts "     ERROR (#{error_counter}): " + source.errors.full_messages.join(';')
            puts "  FileID: #{file_id}, sf row created by: #{row['CreatedBy']}, sf row updated by: #{row['ModifiedBy']}    "
          end
        end

        # Write to Imports
        species_file_data.set('SFFileIDToTWProjectID', sf_file_id_to_tw_project_id)
        puts 'SF.FileID to TW.project_id'
        ap sf_file_id_to_tw_project_id

      end

      desc 'list SF.RefID to VerbatimRefString'
      task :list_verbatim_refs => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:sf_start:list_verbatim_refs user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        puts 'Running list_verbatim_refs...'

        ref_id_to_verbatim_ref = {}

        path = @args[:data_directory] + 'direct_from_sf/sf_verbatim_refs.txt'
        file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

        file.each do |row|
          # byebug
          # puts row.inspect
          ref_id = row['RefID']
          print "working with #{ref_id} \n"
          ref_id_to_verbatim_ref[ref_id] = row['RefString']
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('RefIDToVerbatimRef', ref_id_to_verbatim_ref)

        puts 'RefID to VerbatimRef'
        ap ref_id_to_verbatim_ref

      end

      desc 'map SF.RefID to Link URL'
      task :map_ref_link => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:sf_start:map_ref_link user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        puts 'Running map_ref_link...'

        ref_id_to_ref_link = {}

        path = @args[:data_directory] + 'direct_from_sf/ref_id_to_ref_link.txt'
        file = CSV.read(path, col_sep: "\t", headers: true, encoding: 'BOM|UTF-8')

        file.each do |row|
          # byebug
          # puts row.inspect
          ref_id = row['RefID']
          print "working with #{ref_id} \n"
          ref_id_to_ref_link[ref_id] = row['RefLink']
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('RefIDToRefLink', ref_id_to_ref_link)

        puts 'RefID to Link URL'
        ap ref_id_to_ref_link

      end

      # :create_no_ref_list_array is now created on the fly in :create_sources (data conflicts)
      # desc 'make array from no_ref_list'
      # task :create_no_ref_list_array => [:data_directory, :environment, :user_id] do
      #   ### rake tw:project_import:sf_start:create_no_ref_list_array user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      #   sf_no_ref_list = []
      #
      #   path = @args[:data_directory] + 'direct_from_sf/no_ref_list.txt'
      #   file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-8')
      #
      #   file.each do |row|
      #     sf_no_ref_list.push(row[0])
      #   end
      #
      #   i = Import.find_or_create_by(name: 'SpeciesFileData')
      #   i.set('SFNoRefList', sf_no_ref_list)
      #
      #   puts 'SF no_ref_list'
      #   ap sf_no_ref_list
      #
      # end

      desc 'map SF.PubID by SF.PubType'
      ### time rake tw:project_import:sf_start:create_sources user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      task :map_pub_type => [:data_directory, :environment, :user_id] do
        ### rake tw:project_import:sf_start:create_sources user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/

        puts 'Running map_put_type...'

        sf_pub_id_to_pub_type = {}

        path = @args[:data_directory] + 'working/tblPubs.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: "UTF-16:UTF-8")

        file.each_with_index do |row|

          pub_type = row['PubType']
          if pub_type == '1'
            pub_type_string = 'article'
          elsif pub_type == '3'
            pub_type_string = 'book'
          elsif pub_type == '4'
            pub_type_string = 'unpublished'
          else
            pub_type_string = '**ERROR**'
          end

          sf_pub_id_to_pub_type[row['PubID']] = pub_type_string
        end

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('SFPubIDToPubType', sf_pub_id_to_pub_type)

        puts 'SF.PubID to PubType'
        ap sf_pub_id_to_pub_type

      end

      desc 'map SF.PubID to TW.serial_id'
      task :map_serials => [:environment, :user_id] do

        puts 'Running map_serials...'

        # Build hash similar to file_user_id_to_tw_user_id for SF.PubID (many) to one TW.serial_id
        # DataAttributes associated with a serial record contain multiple SF.PubIDs

        # [4/26/16, 3:21:24 PM] diapriid: erial.includes(:data_attributes).where(data_attributes: {value: 18151, controlled_vocabulary_term_id: 999}).first
        # [4/26/16, 3:22:37 PM] diapriid: Serial.includes(:data_attributes).where(data_attributes: {value: 18151, import_predicate: 'SF ID'}).first
        # [4/26/16, 3:22:50 PM] diapriid: a =  Serial.includes(:data_attributes).where(data_attributes: {value: 18151, import_predicate: 'SF ID'}).first
        # [4/26/16, 3:22:53 PM] diapriid: a.id

        # pubs = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').limit(10).pluck(:value, :attribute_subject_id)
        sf_pub_id_to_tw_serial_id = DataAttribute.where(import_predicate: 'SF ID', attribute_subject_type: 'Serial').pluck(:value, :attribute_subject_id).to_h

        i = Import.find_or_create_by(name: 'SpeciesFileData')
        i.set('SFPubIDToTWSerialID', sf_pub_id_to_tw_serial_id)

        puts 'SF.PubID to TW.serial_id'
        ap sf_pub_id_to_tw_serial_id
      end

      desc 'create people'
      ### time rake tw:project_import:sf_start:create_people user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      task :create_people => [:data_directory, :environment, :user_id] do

        puts 'Running create_people...'

        # Two loops:
        # Loop # 1
        # loop through entire table (22004 entries)
        # process only those rows where row['PrefID'] == 0
        # create person, how to assign original housekeeping (save hashes from create_users)?
        # save person, validate, etc.
        # save PersonID as identifier or data_attribute or ?? << probably identifier/local import identifier
        # save Role (bitmap) as data_attribute (?) for later role assignment; Role & 256 = 256 should indicate name is deletable, but it is often incorrectly set!
        # make SF.PersonID and TW.person.id hash (for processing in second loop)
        #
        # Loop # 2
        # loop through entire table
        # process only those rows where row['PrefID'] > 0
        # identify tw.person.id via row['PrefID'] in hash
        # create alternate_value for tw.person.id using last_name only

        # tblPeople: PersonID, FileID, PrefID, [PersonRegID], FamilyName, GivenName, GivenInitials, Suffix, *Role*, [Status], LastUpdate, ModifiedBy, CreatedOn, CreatedBy
        #   Identifiers: PersonID; DataAttributes: FileID, Role; Do not import: PersonRegID; GivenName/GivenInitials: If GN is blank, use GI
        #
        # People: id, type, last_name, first_name, created_at, updated_at, suffix, prefix, created_by_id, updated_by_id, cached

        # @project = Project.find_by_name('Orthoptera Species File')
        # $project_id = @project.id

        import = Import.find_or_create_by(name: 'SpeciesFileData')
        get_tw_user_id = import.get('FileUserIDToTWUserID') # for housekeeping

        get_tw_person_id ||= {} # make empty hash if doesn't exist (otherwise it would be nil), used in loop 2

        # create Namespace for Identifier (used in loop below): Species File, tblPeople, SF PersonID
        # 'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID')     # 'Key3' was key in hash @data.keywords.merge! ??
        # auth_user_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblAuthUsers', short_name: 'SF AuthUserID')
        person_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblPeople', short_name: 'SF PersonID')

        # No longer using InternalAttribute for following import values; using ImportAttribute instead since it doesn't require a project_id
        # file_id = Predicate.find_or_create_by(name: 'FileID', definition: 'SpeciesFile.FileID', project_id: $project_id)
        # person_roles = Predicate.find_or_create_by(name: 'Roles', definition: 'Bitmap of person roles', project_id: $project_id)
        # example of internal attr:
        # person.data_attributes << InternalAttribute.new(predicate: person_roles, value: row['Role'])
        # person.identifiers.new(type: 'Identifier::Local::Import', namespace: person_namespace, identifier: person_id)
        # # probably only writes to memory, to save in db, use <<

        path = @args[:data_directory] + 'working/tblPeople.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

        # loop 1: Get preferred records only

        error_counter = 0

        file.each_with_index do |row, i|
          person_id = row['PersonID']
          next if get_tw_person_id[person_id] # do not create if already exists

          pref_id = row['PrefID']
          next if pref_id.to_i > 0 # alternate spellings will be handled in second loop

          print "working with #{person_id} \n"

          person = Person::Vetted.new(
              # type: 'Person_Vetted',
              last_name: row['FamilyName'],
              first_name: row['GivenNames'].blank? ? row['GivenInitials'] : row['GivenNames'],
              created_at: row['CreatedOn'],
              updated_at: row['LastUpdate'],
              suffix: row['Suffix'],
              # prefix: '',
              created_by_id: get_tw_user_id[row['CreatedBy']],
              updated_by_id: get_tw_user_id[row['ModifiedBy']]
              # cached: '?'
          )

          if person.save

            person.data_attributes << ImportAttribute.new(import_predicate: 'FileID', value: row['FileID'])
            person.data_attributes << ImportAttribute.new(import_predicate: 'Role', value: row['Role'])

            person.identifiers << Identifier::Local::Import.new(namespace: person_namespace, identifier: person_id)

            get_tw_person_id[person_id] = person.id

          else
            error_counter += 1
            puts "     Person ERROR (#{error_counter}): " + person.errors.full_messages.join(';')
          end

        end

        import.set('SFPersonIDToTWPersonID', get_tw_person_id) # write to db
        puts 'SFPersonIDToTWPersonID'
        ap get_tw_person_id

        # loop 2: Get non-preferred records and save as alternate values

        file.each_with_index do |row, i| # uses path & file from loop 1
          pref_id = row['PrefID']
          next if pref_id.to_i == 0 # handle only non-preferred records

          non_pref_family_name = row['FamilyName'] # use the non-preferred person's family name as default alternate name

          if get_tw_person_id[pref_id]
            puts "working with #{get_tw_person_id[pref_id]}"
            # pref_person.alternate_values.new(value: non_pref_family_name, type: 'AlternateValue::AlternateSpelling', alternate_value_object_attribute: 'last_name')
            a = AlternateValue::AlternateSpelling.new(
                alternate_value_object_type: 'Person',
                alternate_value_object_id: get_tw_person_id[pref_id],
                value: non_pref_family_name,
                alternate_value_object_attribute: 'last_name'
            )
            if a.valid?
              a.save!
              puts "added attribute"
            else
              puts "invalid attribute"
            end
          end
        end
      end

      desc 'create users'
      ### time rake tw:project_import:sf_start:create_users user_id=1 data_directory=/Users/mbeckman/src/onedb2tw/
      task :create_users => [:data_directory, :environment, :user_id] do

        puts 'Running create_users...'

        # ProjectMembers: id, project_id, user_id, created_at, updated_at, created_by_id, updated_by_id, is_project_administrator
        #   * Cannot annotate a project_member
        # Users: id, email, password_digest, created_at, updated_at, remember_token, created_by_id, updated_by_id, is_administrator,
        #   password_reset_token, password_reset_token_date, name, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip,
        #   hub_tab_order, api_access_token, is_flagged_for_password_reset, footprints, sign_in_count,
        #     * Annotations: FullName, TaxaShowSpecs, CiteShowSpecs, SpmnShowSpecs
        #     * Since no annotations for project_member, could add notes to Users for (Access, LastLogin, NumLogins, LastEdit, NumEdits) by SF

        # tblFileUsers: FileUserID, AuthUserID, FileID, Access, LastLogin, NumLogins, LastEdit, NumEdits, CreatedOn, CreatedBy
        # tblAuthUsers: AuthUserID, Name, HashedPassword, FullName, TaxaShowSpecs, CiteShowSpecs, SpmnShowSpecs, LastUpdate, ModifiedBy,
        #   CreatedOn, CreatedBy

        # Fields for potential data attributes
        #   AuthUserID

        # create a ControlledVocabularyTerm of type Predicate (to be used in DataAttribute in User instance below)
        # predicates = {
        #     'AuthUserID' => Predicate.find_or_create_by(name: 'AuthUserID', definition: 'Unique user name id', project_id: $project_id)
        # }
        # Now that User is identifiable, we can use an identifier for the unique AuthUserID (vs. FileUserID)
        # Create Namespace for Identifier: Species File, tblAuthUsers, SF AuthUserID
        # 'Key3' => Namespace.find_or_create_by(name: '3i_Source_ID', short_name: '3i_Source_ID')     # 'Key3' was key in hash @data.keywords.merge! in 3i.rake ??
        auth_user_namespace = Namespace.find_or_create_by(institution: 'Species File', name: 'tblAuthUsers', short_name: 'SF AuthUserID')

        # find unique editors/admin, i.e. people getting users accounts in TW
        unique_auth_users = {} # unique sf.authorized users with edit+ access, not stored in Import, used only in this task
        sf_file_user_id_to_sf_auth_user_id = {} # not stored in Import; multiple file users map onto same auth user
        get_tw_user_id = {} # key = sf.file_user_id, value = tw.user_id
        get_sf_file_id = {} # key = sf.file_user_id, value sf.file_id; for future use when creating projects and project members

        @user_index = {}
        project_url = 'speciesfile.org'

        path = @args[:data_directory] + 'working/tblFileUsers.txt'
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

        file.each_with_index do |row, i|
          au_id = row['AuthUserID']
          fu_id = row['FileUserID']
          next if [0, 8].freeze.include?(row['Access'].to_i)

          puts "WARNING - NON UNIQUE FileUserID: #{fu_id}" if sf_file_user_id_to_sf_auth_user_id[fu_id]

          sf_file_user_id_to_sf_auth_user_id[fu_id] = au_id

          if unique_auth_users[au_id]
            unique_auth_users[au_id].push fu_id
          else
            unique_auth_users[au_id] = [fu_id]
          end

          get_sf_file_id[fu_id] = row['FileID']
        end

        path = @args[:data_directory] + 'working/tblAuthUsers.txt'
        print "Creating users\n"
        raise "file #{path} not found" if not File.exists?(path)
        file = CSV.foreach(path, col_sep: "\t", headers: true, encoding: 'UTF-16:UTF-8')

        error_counter = 0

        file.each_with_index do |row, i|
          au_id = row['AuthUserID']

          print "working with AuthUser: #{au_id}"

          if unique_auth_users[au_id]
            puts "is a unique user, creating:  #{i}: #{row['Name']}"

            user = User.new(
                name: row['Name'],
                password: '12345678',
                email: 'auth_user_id' + au_id.to_s + '_random' + rand(1000).to_s + '@' + project_url
            )

            if user.save

              unique_auth_users[au_id].each do |fu_id|
                get_tw_user_id[fu_id] = user.id.to_s # @ Making user.id into string for consistency of all hash values being strings
              end

              @user_index[row['FileUserID']] = user.id # maps multiple FileUserIDs onto single TW user.id

              # create AuthUserID as DataAttribute as InternalAttribute for table users
              # user.data_attributes << InternalAttribute.new(predicate: predicates['AuthUserID'], value: au_id)
              # Now using an identifier for this:
              user.identifiers.new(type: 'Identifier::Local::Import', namespace: auth_user_namespace, identifier: au_id)

              # Do not create project_members right now; store hash of file_user_id => file_id in Import table
              # ProjectMember.create(user: user, project: @project)

            else
              error_counter += 1
              puts "     User ERROR (#{error_counter}): " + user.errors.full_messages.join(';')
            end

          else
            print " skipping, public access only\n"
          end
        end

        # Save the file user mappings to the import table
        import = Import.find_or_create_by(name: 'SpeciesFileData')
        import.set('SFFileUserIDToTWUserID', get_tw_user_id)
        import.set('SFFileUserIDToSFFileID', get_sf_file_id) # will be used when tables containing FileID are imported

        # display user mappings
        puts 'unique authorized users with edit+ access'
        ap unique_auth_users # list of unique authorized users (who have edit+ access via FileUserIDs)
        puts 'multiple FileUserIDs mapped to single AuthUserID'
        ap sf_file_user_id_to_sf_auth_user_id # map multiple FileUserIDs onto single AuthUserID
        puts 'SFFileUserIDToTWUserID'
        ap get_tw_user_id # map multiple FileUserIDs on single TW user.id
        puts 'SFFileUserIDToSFFileID'
        ap get_sf_file_id

      end

    end
  end
end



