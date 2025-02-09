require "test_helper"

class LlmModelsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @llm_model = llm_models(:one)
    @admin = users(:admin)
    sign_in @admin
  end

  test "should get index" do
    get llm_models_url
    assert_response :success
  end

  test "should get new" do
    get new_llm_model_url
    assert_response :success
  end

  test "should create llm_model" do
    assert_difference("LlmModel.count") do
      post llm_models_url, params: { llm_model: {
        is_active: true,
        name: "Mistral 7B",
        size: 7000,
        ollama_name: "mistral:7b"
      } }
    end

    assert_redirected_to llm_model_url(LlmModel.last)
  end

  test "should show llm_model" do
    get llm_model_url(@llm_model)
    assert_response :success
  end

  test "should get edit" do
    get edit_llm_model_url(@llm_model)
    assert_response :success
  end

  test "should update llm_model" do
    patch llm_model_url(@llm_model), params: { llm_model: {
      is_active: false,
      name: @llm_model.name,
      size: 250000,
      ollama_name: "claude3:opus2"
    } }
    assert_redirected_to llm_model_url(@llm_model)

    # Verify the model was updated
    @llm_model.reload
    assert_equal false, @llm_model.is_active
    assert_equal 250000, @llm_model.size
    assert_equal "claude3:opus2", @llm_model.ollama_name
  end

  test "should destroy llm_model" do
    assert_difference("LlmModel.count", -1) do
      delete llm_model_url(@llm_model)
    end

    assert_redirected_to llm_models_url
  end
end
