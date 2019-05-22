require 'rails_helper'

RSpec.describe 'Patients API', type: :request do
  # initialize test data 
  let!(:patients) { create_list(:patient, 10) }
  let(:patient_id) { patients.first.id }

  # Test suite for GET /patients
  describe 'GET /patients' do
    # make HTTP get request before each example
    before { get '/patients' }

    it 'returns patients' do
      # Note `json` is a custom helper to parse JSON responses
      expect(json).not_to be_empty
      expect(json.size).to eq(10)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  # Test suite for GET /patients/:id
  describe 'GET /patients/:id' do
    before { get "/patients/#{patient_id}" }

    context 'when the record exists' do
      it 'returns the patient' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(patient_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the record does not exist' do
      let(:patient_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find patient/)
      end
    end
  end

  # Test suite for POST /patients
  describe 'POST /patients' do
    # valid payload
    let(:valid_attributes) { { dni: '38601813', first_name: 'Eugenio', last_name: 'Gómez', birthdate: "31/10/1994", patient_type: '1' } }

    context 'when the request is valid' do
      before { post '/patients', params: valid_attributes }

      it 'creates a patient' do
        expect(json['title']).to eq('Learn Elm')
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when the request is invalid' do
      before { post '/patients', params: { title: 'Foobar' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/Validation failed: Created by can't be blank/)
      end
    end
  end

  # Test suite for PUT /patients/:id
  describe 'PUT /patients/:id' do
    let(:valid_attributes) { { title: 'Shopping' } }

    context 'when the record exists' do
      before { put "/patients/#{patient_id}", params: valid_attributes }

      it 'updates the record' do
        expect(response.body).to be_empty
      end

      it 'returns status code 204' do
        expect(response).to have_http_status(204)
      end
    end
  end

  # Test suite for DELETE /patients/:id
  describe 'DELETE /patients/:id' do
    before { delete "/patients/#{patient_id}" }

    it 'returns status code 204' do
      expect(response).to have_http_status(204)
    end
  end
end