require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe ProjectMembersController, :type => :controller do
  before {
    sign_in_administrator 
    @unplaced_user = FactoryGirl.create(:valid_user)
  }

  # This should return the minimal set of attributes required to create a valid
  # ProjectMember. As you add validations to ProjectMember, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { {user_id: @unplaced_user.id, project_id: 1 } }
  let(:invalid_attributes) { {user_id: @unplaced_user.id, project_id: nil } } # also invalid for _many_
  let(:create_many_valid_attributes) { { user_ids: [@unplaced_user.id], project_id: 1} }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProjectMembersController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET new" do
    it "assigns a new project_member as @project_member" do
      get :new, {project_member: {project_id: 1}}, valid_session
      expect(assigns(:project_member)).to be_a_new(ProjectMember)
    end
  end

  describe "GET edit" do
    it "assigns the requested project_member as @project_member" do
      project_member = ProjectMember.create! valid_attributes
      get :edit, {:id => project_member.to_param}, valid_session
      expect(assigns(:project_member)).to eq(project_member)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new ProjectMember" do
        expect {
          post :create, {:project_member => valid_attributes}, valid_session
        }.to change(ProjectMember, :count).by(1)
      end

      it "assigns a newly created project_member as @project_member" do
        post :create, {:project_member => valid_attributes}, valid_session
        expect(assigns(:project_member)).to be_a(ProjectMember)
        expect(assigns(:project_member)).to be_persisted
      end

      it "redirects to the project overview page" do
        post :create, {:project_member => valid_attributes}, valid_session
        expect(response).to redirect_to(project_path(1))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved project_member as @project_member" do
        post :create, {:project_member => invalid_attributes}, valid_session
        expect(assigns(:project_member)).to be_a_new(ProjectMember)
      end

      it "re-renders the 'new' template" do
        post :create, {:project_member => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "POST create_many" do
    describe "with valid params" do
      it "creates a new ProjectMember" do
        expect {
          post :create_many, {:project_member => create_many_valid_attributes}, valid_session
        }.to change(ProjectMember, :count).by(1)
      end
    end

    describe "with invalid params (no project_id)" do
      it "assigns a stubbed project_member as @project_member" do
        post :create_many, {:project_member => invalid_attributes}, valid_session
        expect(response.status).to eq(404)
        #expect(response).to render_template('many_new')
        #expect(assigns(:project_member)).to be_a_new(ProjectMember)
      end
    end

    describe "with invalid params (invalid user_id)" do
      it "assigns a stubbed project_member as @project_member" do
        post :create_many, {:project_member => invalid_attributes.merge(project_id: 1, user_ids: [12312, 123321])}, valid_session
        expect(response).to redirect_to( many_new_project_members_path) 
      end
    end
  end 

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        { is_project_administrator:  true}
      }

      it "updates the requested project_member" do
        project_member = ProjectMember.create! valid_attributes
        put :update, {id: project_member.to_param, project_member: new_attributes }, valid_session
        project_member.reload
        expect(assigns(:project_member)).to eq(project_member)
      end

      it "assigns the requested project_member as @project_member" do
        project_member = ProjectMember.create! valid_attributes
        put :update, {:id => project_member.to_param, :project_member => valid_attributes}, valid_session
        expect(assigns(:project_member)).to eq(project_member)
      end

      it "redirects to the project_member" do
        project_member = ProjectMember.create! valid_attributes
        put :update, {:id => project_member.to_param, :project_member => valid_attributes}, valid_session
        expect(response).to redirect_to(project_path(1))
      end
    end

    describe "with invalid params" do
      it "assigns the project_member as @project_member" do
        project_member = ProjectMember.create! valid_attributes
        put :update, {:id => project_member.to_param, :project_member => invalid_attributes}, valid_session
        expect(assigns(:project_member)).to eq(project_member)
      end

      it "re-renders the 'edit' template" do
        project_member = ProjectMember.create! valid_attributes
        put :update, {:id => project_member.to_param, :project_member => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested project_member" do
      project_member = ProjectMember.create! valid_attributes
      expect {
        delete :destroy, {:id => project_member.to_param}, valid_session
      }.to change(ProjectMember, :count).by(-1)
    end

    it "redirects to the related project page" do
      project_member = ProjectMember.create! valid_attributes
      delete :destroy, {:id => project_member.to_param}, valid_session
      expect(response).to redirect_to(project_path(1))
    end
  end

end
