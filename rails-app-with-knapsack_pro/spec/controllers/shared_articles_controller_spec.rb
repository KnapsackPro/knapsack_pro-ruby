require_relative 'shared'

nested_shared_specs_for_articles_controller_index do
  it do
    subject

    expect(assigns(:articles)).to eq articles
    expect(response).to be_successful
  end
end
