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

describe OtuPageLayoutsController, :type => :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # OtuPageLayout. As you add validations to OtuPageLayout, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { strip_housekeeping_attributes(FactoryGirl.build(:valid_otu_page_layout).attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OtuPageLayoutsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all otu_page_layouts as @otu_page_layouts" do
      otu_page_layout = OtuPageLayout.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:otu_page_layouts)).to eq([otu_page_layout])
    end
  end

  describe "GET show" do
    it "assigns the requested otu_page_layout as @otu_page_layout" do
      otu_page_layout = OtuPageLayout.create! valid_attributes
      get :show, {:id => otu_page_layout.to_param}, valid_session
      expect(assigns(:otu_page_layout)).to eq(otu_page_layout)
    end
  end

  describe "GET new" do
    it "assigns a new otu_page_layout as @otu_page_layout" do
      get :new, {}, valid_session
      expect(assigns(:otu_page_layout)).to be_a_new(OtuPageLayout)
    end
  end

  describe "GET edit" do
    it "assigns the requested otu_page_layout as @otu_page_layout" do
      otu_page_layout = OtuPageLayout.create! valid_attributes
      get :edit, {:id => otu_page_layout.to_param}, valid_session
      expect(assigns(:otu_page_layout)).to eq(otu_page_layout)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new OtuPageLayout" do
        expect {
          post :create, {:otu_page_layout => valid_attributes}, valid_session
        }.to change(OtuPageLayout, :count).by(1)
      end

      it "assigns a newly created otu_page_layout as @otu_page_layout" do
        post :create, {:otu_page_layout => valid_attributes}, valid_session
        expect(assigns(:otu_page_layout)).to be_a(OtuPageLayout)
        expect(assigns(:otu_page_layout)).to be_persisted
      end

      it "redirects to the created otu_page_layout" do
        post :create, {:otu_page_layout => valid_attributes}, valid_session
        expect(response).to redirect_to(OtuPageLayout.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved otu_page_layout as @otu_page_layout" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(OtuPageLayout).to receive(:save).and_return(false)
        post :create, {:otu_page_layout => {:invalid => 'parms'}}, valid_session
        expect(assigns(:otu_page_layout)).to be_a_new(OtuPageLayout)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(OtuPageLayout).to receive(:save).and_return(false)
        post :create, {:otu_page_layout => {:invalid => 'parms'}}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested otu_page_layout' do
        otu_page_layout = OtuPageLayout.create! valid_attributes
        # Assuming there are no other otu_page_layouts in the database, this
        # specifies that the OtuPageLayout created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(OtuPageLayout).to receive(:update).with({'name' => 'sunshine'})
        put :update, {:id => otu_page_layout.to_param, :otu_page_layout => {name: 'sunshine'}}, valid_session
      end

      it "assigns the requested otu_page_layout as @otu_page_layout" do
        otu_page_layout = OtuPageLayout.create! valid_attributes
        put :update, {:id => otu_page_layout.to_param, :otu_page_layout => valid_attributes}, valid_session
        expect(assigns(:otu_page_layout)).to eq(otu_page_layout)
      end

      it "redirects to the otu_page_layout" do
        otu_page_layout = OtuPageLayout.create! valid_attributes
        put :update, {:id => otu_page_layout.to_param, :otu_page_layout => valid_attributes}, valid_session
        expect(response).to redirect_to(otu_page_layout)
      end
    end

    describe "with invalid params" do
      it "assigns the otu_page_layout as @otu_page_layout" do
        otu_page_layout = OtuPageLayout.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(OtuPageLayout).to receive(:save).and_return(false)
        put :update, {:id => otu_page_layout.to_param, :otu_page_layout => {:invalid => 'parms'}}, valid_session
        expect(assigns(:otu_page_layout)).to eq(otu_page_layout)
      end

      it "re-renders the 'edit' template" do
        otu_page_layout = OtuPageLayout.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(OtuPageLayout).to receive(:save).and_return(false)
        put :update, {:id => otu_page_layout.to_param, :otu_page_layout => {:invalid => 'parms'}}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested otu_page_layout" do
      otu_page_layout = OtuPageLayout.create! valid_attributes
      expect {
        delete :destroy, {:id => otu_page_layout.to_param}, valid_session
      }.to change(OtuPageLayout, :count).by(-1)
    end

    it "redirects to the otu_page_layouts list" do
      otu_page_layout = OtuPageLayout.create! valid_attributes
      delete :destroy, {:id => otu_page_layout.to_param}, valid_session
      expect(response).to redirect_to(otu_page_layouts_url)
    end
  end

end
