class Tasks::Nomenclature::BrowseController < ApplicationController
  include TaskControllerConfiguration

  def index
    @taxon_name = TaxonName.where(project_id: sessions_current_project_id).find(params[:id]) if !params[:id].blank?
    @taxon_name ||= Project.find(sessions_current_project_id).root_taxon_name
    redirect_to :new_taxon_name_task, notice: 'No names to browse yet.' and return if @taxon_name.nil?
    @data = NomenclatureCatalog.data_for(@taxon_name)
  end

end
