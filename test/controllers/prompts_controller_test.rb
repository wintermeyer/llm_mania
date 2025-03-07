require "test_helper"

class PromptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Set up Devise mapping explicitly for this test
    @request ||= ActionDispatch::TestRequest.create
    Devise.mappings[:user] = Devise.mappings[:user] || Devise::Mapping.new(:user, {})

    # Create user with subscription and LLMs
    @user = create(:user)
    @subscription = create(:subscription, max_prompt_length: 1500, private_prompts_allowed: true)
    @llm1 = create(:llm, name: "Model 1", size: 7, creator: "OpenAI")
    @llm2 = create(:llm, name: "Model 2", size: 13, creator: "Anthropic")
    create(:subscription_llm, subscription: @subscription, llm: @llm1)
    create(:subscription_llm, subscription: @subscription, llm: @llm2)
    create(:subscription_history, user: @user, subscription: @subscription)

    sign_in @user
  end

  test "should get new" do
    get new_prompt_path
    assert_response :success
    assert_select "h1", text: "Create a New Prompt"
    assert_select "h2", text: "Select Language Models"
    assert_select "input[type='checkbox'][name='llm_ids[]']", count: 2
  end

  test "should create prompt with selected LLMs" do
    prompt_attributes = attributes_for(:prompt)

    assert_difference("Prompt.count") do
      post prompts_path, params: {
        prompt: prompt_attributes,
        llm_ids: [@llm1.id.to_s, @llm2.id.to_s]
      }
    end

    assert_redirected_to root_path
    assert_equal "Prompt was successfully created.", flash[:notice]

    prompt = Prompt.last
    assert_equal prompt_attributes[:content], prompt.content
  end

  test "should create prompt with only one LLM selected" do
    prompt_attributes = attributes_for(:prompt)

    assert_difference("Prompt.count") do
      post prompts_path, params: {
        prompt: prompt_attributes,
        llm_ids: [@llm1.id.to_s]
      }
    end

    assert_redirected_to root_path
    assert_equal "Prompt was successfully created.", flash[:notice]

    prompt = Prompt.last
    assert_equal prompt_attributes[:content], prompt.content
  end

  test "should create prompt with no LLMs selected" do
    prompt_attributes = attributes_for(:prompt)

    assert_difference("Prompt.count") do
      post prompts_path, params: {
        prompt: prompt_attributes
      }
    end

    assert_redirected_to root_path
    assert_equal "Prompt was successfully created.", flash[:notice]

    prompt = Prompt.last
    assert_equal prompt_attributes[:content], prompt.content
    assert_equal "waiting", prompt.status
    assert_equal 0, prompt.llm_jobs.count
  end

  test "should not create prompt with invalid data" do
    assert_no_difference("Prompt.count") do
      post prompts_path, params: { prompt: { content: "", private: "0" } }
    end

    assert_response :unprocessable_entity
    assert_select "div", text: /There were problems with your submission/
  end

  test "should require authentication" do
    sign_out @user
    get new_prompt_path
    assert_redirected_to new_user_session_path
  end
end
