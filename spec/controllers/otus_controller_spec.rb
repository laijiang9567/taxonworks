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

describe OtusController, :type => :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { strip_housekeeping_attributes(FactoryGirl.build(:valid_otu).attributes)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # OtusController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all otus as @otus" do
      otu = Otu.create!(valid_attributes)
      get :index, {}, valid_session
      # The following means that @otus = Otu.all in the controller.
      expect(assigns(:recent_objects)).to include(otu)
    end
  end

  describe "GET show" do
    it "assigns the requested otu as @otu" do
      otu = Otu.create! valid_attributes
      get :show, {:id => otu.to_param}, valid_session
      expect(assigns(:otu)).to eq(otu)
    end
  end

  describe "GET new" do
    it "assigns a new otu as @otu" do
      get :new, {}, valid_session
      expect(assigns(:otu)).to be_a_new(Otu)
    end
  end

  describe "GET edit" do
    it "assigns the requested otu as @otu" do
      otu = Otu.create! valid_attributes
      get :edit, {:id => otu.to_param}, valid_session
      expect(assigns(:otu)).to eq(otu)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Otu" do
        expect {
          post :create, {:otu => valid_attributes}, valid_session
        }.to change(Otu, :count).by(1)
      end

      it "assigns a newly created otu as @otu" do
        post :create, {:otu => valid_attributes}, valid_session
        expect(assigns(:otu)).to be_a(Otu)
        expect(assigns(:otu)).to be_persisted
      end

      it "redirects to the created otu" do
        post :create, {:otu => valid_attributes}, valid_session
        expect(response).to redirect_to(Otu.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved otu as @otu" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Otu).to receive(:save).and_return(false)
        post :create, {:otu => {"name" => "invalid value"}}, valid_session
        expect(assigns(:otu)).to be_a_new(Otu)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Otu).to receive(:save).and_return(false)
        post :create, {:otu => {"name" => "invalid value"}}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested otu" do
        otu = Otu.create! valid_attributes
        # Assuming there are no other otus in the database, this
        # specifies that the Otu created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(Otu).to receive(:update).with({"name" => "MyString"})
        put :update, {:id => otu.to_param, :otu => {"name" => "MyString"}}, valid_session
      end

      it "assigns the requested otu as @otu" do
        otu = Otu.create! valid_attributes
        put :update, {:id => otu.to_param, :otu => valid_attributes}, valid_session
        expect(assigns(:otu)).to eq(otu)
      end

      it "redirects to the otu" do
        otu = Otu.create! valid_attributes
        put :update, {:id => otu.to_param, :otu => valid_attributes}, valid_session
        expect(response).to redirect_to(otu)
      end
    end

    describe "with invalid params" do
      it "assigns the otu as @otu" do
        otu = Otu.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Otu).to receive(:save).and_return(false)
        put :update, {:id => otu.to_param, :otu => {"name" => "invalid value"}}, valid_session
        expect(assigns(:otu)).to eq(otu)
      end

      it "re-renders the 'edit' template" do
        otu = Otu.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Otu).to receive(:save).and_return(false)
        put :update, {:id => otu.to_param, :otu => {"name" => "invalid value"}}, valid_session
        expect(response).to render_template("edit")
      end
    end

    describe "DELETE destroy" do
      it "destroys the requested otu" do
        otu = Otu.create! valid_attributes
        expect {
          delete :destroy, {:id => otu.to_param}, valid_session
        }.to change(Otu, :count).by(-1)
      end

      it "redirects to the otus list" do
        otu = Otu.create! valid_attributes
        delete :destroy, {:id => otu.to_param}, valid_session
        expect(response).to redirect_to(otus_url)
      end
    end

  end
end
