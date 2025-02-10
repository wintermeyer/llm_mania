require "application_system_test_case"

class LlmModelsTest < ApplicationSystemTestCase
  setup do
    @admin = users(:user_one)
    @admin.update!(is_admin: true)
    @regular_user = users(:user_two)

    @llm_model = llm_models(:one)
    sign_in @admin
  end

  test "visiting the index as admin shows all models and new button" do
    visit llm_models_url
    assert_selector "h1", text: "LLM Models"
    assert_selector "a", text: "Add model"
  end

  test "visiting the index as regular user hides new button" do
    sign_in @regular_user
    visit llm_models_url
    assert_selector "h1", text: "LLM Models"
    assert_no_selector "a", text: "Add model"
  end

  test "admin can access new LLM model page directly" do
    visit new_llm_model_url
    assert_selector "h1", text: "New LLM Model"
    assert_selector "form" do
      assert_selector "input[name='llm_model[name]']"
      assert_selector "input[name='llm_model[ollama_name]']"
      assert_selector "input[name='llm_model[size]']"
      assert_selector "input[name='llm_model[is_active]']"
    end
  end

  test "creating a new LLM model as admin" do
    visit llm_models_url
    click_on "Add model"

    fill_in "Name", with: "GPT-4 Turbo"
    fill_in "Ollama name", with: "gpt4:turbo"
    fill_in "Size", with: "1_000_000"
    check "Active"

    click_on "Create model"

    assert_text "LLM model was successfully created"
    assert_text "GPT-4 Turbo"

    # Verify the slug was automatically generated
    assert_current_path %r{/llm_models/gpt-4-turbo}
  end

  test "cannot create LLM model as regular user" do
    sign_in @regular_user
    visit new_llm_model_url

    assert_text "You are not authorized to access this page"
    assert_current_path root_path
  end

  test "updating an LLM model as admin" do
    visit llm_model_url(@llm_model)
    click_on "Edit", match: :first

    fill_in "Name", with: "Updated Model"
    fill_in "Ollama name", with: "updated:latest"
    fill_in "Size", with: "2000000"
    click_on "Update model"

    assert_text "LLM model was successfully updated"
    assert_text "Updated Model"

    # Verify the slug was automatically updated
    assert_current_path %r{/llm_models/updated-model}
  end

  test "destroying an LLM model as admin" do
    visit llm_model_url(@llm_model)
    accept_confirm do
      click_on "Delete", match: :first
    end

    assert_text "LLM model was successfully destroyed"
  end
end
