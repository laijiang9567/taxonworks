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

describe DataAttributesController, type: :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # DataAttribute. As you add validations to DataAttribute, be sure to
  # adjust the attributes here as well.
  let(:o) {FactoryBot.create(:valid_otu) }
  let(:p) {FactoryBot.create(:valid_controlled_vocabulary_term_predicate) }
  let(:valid_attributes) { 
    { type: 'InternalAttribute',
      attribute_subject_id: o.id,
      attribute_subject_type: o.class.name,
      controlled_vocabulary_term_id: p.id,
      value: 'ABCD' }
  } 

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DataAttributesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET index' do
    it 'assigns all data_attributes as @recent_objects' do
      data_attribute = DataAttribute.create!(valid_attributes)
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to include(data_attribute)
    end
  end

  before {
    request.env['HTTP_REFERER'] = list_otus_path # logical example
  }

  describe 'POST create' do
    before {
      request.env['HTTP_REFERER'] = new_data_attribute_path
    }

    describe 'with valid params' do
      it 'creates a new DataAttribute' do
        expect {
          post :create, params: {data_attribute: valid_attributes}, session: valid_session
        }.to change(DataAttribute, :count).by(1)
      end

      it 'assigns a newly created data_attribute as @data_attribute' do
        post :create, params: {data_attribute: valid_attributes}, session: valid_session
        expect(assigns(:data_attribute)).to be_a(DataAttribute)
        expect(assigns(:data_attribute)).to be_persisted
      end

      it 'redirects to :back' do
        post :create, params: {data_attribute: valid_attributes}, session: valid_session
        expect(response).to redirect_to(otu_path(o))
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved data_attribute as @data_attribute' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(DataAttribute).to receive(:save).and_return(false)
        post :create, params: {data_attribute: {invalid: 'params'}}, session: valid_session
        expect(assigns(:data_attribute)).to be_a_new(DataAttribute)
      end

      it 're-renders the :back template' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(DataAttribute).to receive(:save).and_return(false)
        post :create, params: {data_attribute: {invalid: 'params'}}, session: valid_session
        expect(response).to redirect_to(new_data_attribute_path)
      end
    end
  end

  describe 'PUT update' do
    before {
      request.env['HTTP_REFERER'] = data_attribute_path(1)
    }

    describe 'with valid params' do
      let(:update_params) {ActionController::Parameters.new({value: 'black'}).permit(:value)}

      it 'updates the requested data_attribute' do
        data_attribute = DataAttribute.create! valid_attributes
        # Assuming there are no other data_attributes in the database, this
        # specifies that the DataAttribute created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(DataAttribute).to receive(:update).with(update_params)
        put :update, params: {id: data_attribute.to_param, data_attribute: {value: 'black'}}, session: valid_session
      end

      it 'assigns the requested data_attribute as @data_attribute' do
        data_attribute = DataAttribute.create! valid_attributes
        put :update, params: {id: data_attribute.to_param, data_attribute: valid_attributes}, session: valid_session
        expect(assigns(:data_attribute)).to eq(data_attribute)
      end

      it 'redirects to :back' do
        data_attribute = DataAttribute.create! valid_attributes
        put :update, params: {id: data_attribute.to_param, data_attribute: valid_attributes}, session: valid_session
        expect(response).to redirect_to(otu_path(o))
      end
    end

    describe 'with invalid params' do
      it 'assigns the data_attribute as @data_attribute' do
        data_attribute = DataAttribute.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(DataAttribute).to receive(:save).and_return(false)
        put :update, params: {id: data_attribute.to_param, data_attribute: {invalid: 'parms'}}, session: valid_session
        expect(assigns(:data_attribute)).to eq(data_attribute)
      end

      it 're-renders the :back template' do
        data_attribute = DataAttribute.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(DataAttribute).to receive(:save).and_return(false)
        put :update, params: {id: data_attribute.to_param, data_attribute: {invalid: 'parms'}}, session: valid_session
        expect(response).to redirect_to(data_attribute_path(1))
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested data_attribute' do
      data_attribute = DataAttribute.create! valid_attributes
      expect {
        delete :destroy, params: {id: data_attribute.to_param}, session: valid_session
      }.to change(DataAttribute, :count).by(-1)
    end

    it 'redirects to :back' do
      data_attribute = DataAttribute.create! valid_attributes
      delete :destroy, params: {id: data_attribute.to_param}, session: valid_session
      expect(response).to redirect_to(list_otus_path)
    end
  end

end
