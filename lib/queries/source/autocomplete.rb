module Queries
  module Source
    class Autocomplete < Queries::Query

      # Either match against all Sources (default) or just those with ProjectSource 
      # @return [Boolean]
      # @param limit_to_project [String] `true` or `false`
      attr_accessor :limit_to_project

      def initialize(string, project_id: nil, limit_to_project: false)
        @limit_to_project = limit_to_project
        super
      end

      # @return [ActiveRecord::Relation]
      def or_clauses
        clauses = [
          only_ids,               # only intgers provided
          cached,                 # should hit titles when provided alone, unfragmented string matches
          fragment_year_matches   # keyword style ANDs years
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end

      # @return [String]
      def where_sql
        or_clauses.to_sql
      end

      # @return [ActiveRecord::Relation, nil]
      #    if user provides 5 or fewer strings and any number of years look for any string && year
      def fragment_year_matches
        if fragments.any?
          s = table[:cached].matches_any(fragments)
          s = s.and(table[:year].eq_any(years)) if !years.empty? 
          s
        else
          nil
        end 
      end

      def base_query
        ::Source.select('sources.*').includes(author_roles: [:person], editor_roles: [:person])
      end

      # @return [ActiveRecord::Relation]
      def all
        Source.where(where_sql).limit(500).distinct.order(:cached)
      end

      # @return [ActiveRecord::Relation]
      #   if and only iff author string matches
      def autocomplete_exact_author
        a = table[:cached_author_string].matches(query_string)
        base_query.where(a.to_sql).limit(20) 
      end 

      # @return [ActiveRecord::Relation]
      #   author matches any full word exactly
      def autocomplete_any_author
        a = table[:cached_author_string].matches_regexp('\m' + query_string + '\M')
        base_query.where(a.to_sql).limit(20) 
      end 

      # @return [ActiveRecord::Relation]
      #   author matches partial string 
      def autocomplete_partial_author
        a = table[:cached_author_string].matches('%' + query_string + '%')
        base_query.where(a.to_sql).limit(5) 
      end 

      # @return [ActiveRecord::Relation]
      #   author matches partial string 
      def autocomplete_year
        a = table[:year].eq_any(years)
        base_query.where(a.to_sql).limit(5) 
      end 

      # @return [ActiveRecord::Relation]
      #   title matches start 
      def autocomplete_start_of_title
        a = table[:title].matches(query_string + '%')
        base_query.where(a.to_sql).limit(5) 
      end 

      # @return [ActiveRecord::Relation]
      #   author matches partial string 
      def autocomplete_wildcard_pieces
        a = table[:cached].matches(wildcard_pieces)
        base_query.where(a.to_sql).limit(5) 
      end 

      # @return [ActiveRecord::Relation]
      #   year, suffix 
      def autocomplete_year_letter
        year_letter = query_string.match(/\d{4}([a-zAZ]+)/).to_a.last
        a = table[:year].eq(years.first).and(table[:year_suffix].eq(year_letter))
        base_query.where(a.to_sql).limit(10) 
      end

     def autocomplete_author_year_letter
       autocomplete_year_letter.merge(autocomplete_exact_author)
     end 

      # @return [Array]
      def autocomplete
        queries = [
          autocomplete_exact_author 
        ]

        queries.compact!
       #queries.push Source.where(only_ids.to_sql).limit(20).order(:cached) if only_ids
       #queries.push Source.where(cached.to_sql).limit(20).order(:cached) if cached
       #queries.push Source.where(fragment_year_matches.to_sql).limit(20).order(:cached) if fragment_year_matches

        updated_queries = []
        queries.each_with_index do |q ,i|  
          a = q.joins(:project_sources).where(member_of_project_id.to_sql) if project_id && !limit_to_project
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..19]
      end

      # @return [ActiveRecord::Relation]
      def by_project_all
        ::Source.where(where_sql).limit(500).distinct.order(:cached).joins(:project_sources).where(member_of_project_id.to_sql)
      end

      def table
        ::Source.arel_table
      end

      def project_sources_table
        ProjectSource.arel_table
      end

      def author_roles_table 
        AuthorRole.arel_table
      end 

      def authors_table
        Person.arel_table
      end 

      def authors_join
        table.join(author_roles_table).on(
          table[:id].eq(author_roles[:role_object_id]),
          author_roles[:role_object_type].eq('Author')
        ).join(authors_table).on(
          author_roles[:person_id].eq(authors_table[:id])
        )
      end

      def member_of_project_id
        project_sources_table[:project_id].eq(project_id)
      end

    end
  end
end