require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /terms" do
    it "returns http success" do
      get "/static_pages/terms"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /privacy_policy" do
    it "returns http success" do
      get "/static_pages/privacy_policy"
      expect(response).to have_http_status(:success)
    end
  end

end
