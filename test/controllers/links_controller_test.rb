require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_original_url = "https://example.com"
    @valid_short_url = "#{Shorten::Application::BASE_URL}abc123def"
    @base_url = Shorten::Application::BASE_URL
  end

  # Tests for encode_params method
  test "encode_params with valid URL should succeed" do
    post "/encode", params: { original_link: @valid_original_url }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response["short_link"]
    assert json_response["expiry_date"]
    assert json_response["short_link"].starts_with?(@base_url)
  end

  test "encode_params with missing original_link should return bad request" do
    post "/encode", params: {}
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_match(/original_link/, json_response["message"])
  end

  test "encode_params with blank original_link should return bad request" do
    post "/encode", params: { original_link: "" }
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_match(/original_link/, json_response["message"])
  end

  test "encode_params with nil original_link should return bad request" do
    post "/encode", params: { original_link: nil }
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_match(/original_link/, json_response["message"])
  end

  test "encode_params with invalid URL format should return unprocessable entity" do
    post "/encode", params: { original_link: "invalid-url" }
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_match(/not a valid url format/, json_response["message"])
  end

  test "encode_params with ftp URL should return unprocessable entity" do
    post "/encode", params: { original_link: "ftp://example.com" }
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_match(/not a valid url format/, json_response["message"])
  end

  test "encode_params with URL exceeding 80k characters should return unprocessable entity" do
    long_url = "https://example.com/" + "a" * 80000
    post "/encode", params: { original_link: long_url }
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_match(/only process urls up to 80k chars/, json_response["message"])
  end

  test "encode_params with URL just under 80k characters should succeed" do
    # Create a URL that's just under 80k characters
    long_url = "https://example.com/" + "a" * 79978
    post "/encode", params: { original_link: long_url }
    assert_response :success
  end

  test "encode_params with http URL should succeed" do
    post "/encode", params: { original_link: "http://example.com" }
    assert_response :success
  end

  test "encode_params with https URL should succeed" do
    post "/encode", params: { original_link: "https://example.com" }
    assert_response :success
  end

  test "encode_params with complex URL should succeed" do
    complex_url = "https://example.com/path/to/resource?param1=value1&param2=value2#fragment"
    post "/encode", params: { original_link: complex_url }
    assert_response :success
  end

  # Tests for decode_params method
  test "decode_params with valid short link should succeed" do
    # First create a short link
    post "/encode", params: { original_link: @valid_original_url }
    encode_response = JSON.parse(response.body)
    short_link = encode_response["short_link"]

    # Then decode it
    post "/decode", params: { short_link: short_link }
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @valid_original_url, json_response["original_link"]
    assert json_response["expiry_date"]
  end

  test "decode_params with missing short_link should return bad request" do
    post "/decode", params: {}
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_match(/short_link/, json_response["message"])
  end

  test "decode_params with blank short_link should return bad request" do
    post "/decode", params: { short_link: "" }
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_match(/short_link/, json_response["message"])
  end

  test "decode_params with nil short_link should return bad request" do
    post "/decode", params: { short_link: nil }
    assert_response :bad_request

    json_response = JSON.parse(response.body)
    assert_match(/short_link/, json_response["message"])
  end

  test "decode_params with invalid URL format should return unprocessable entity" do
    post "/decode", params: { short_link: "invalid-url" }
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_match(/not a valid url format/, json_response["message"])
  end

  test "decode_params with wrong base URL should return unprocessable entity" do
    wrong_base_url = "https://wrong.com/abc123def"
    post "/decode", params: { short_link: wrong_base_url }
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_match(/invalid shortlink/, json_response["message"])
  end

  test "decode_params with incorrect short link size should return unprocessable entity" do
    # Short link should be base_url + 9 characters
    too_short = @base_url + "abc"
    post "/decode", params: { short_link: too_short }
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_match(/invalid shortlink size/, json_response["message"])
  end

  test "decode_params with too long short link should return unprocessable entity" do
    too_long = @base_url + "abc123defghij"
    post "/decode", params: { short_link: too_long }
    assert_response :unprocessable_entity

    json_response = JSON.parse(response.body)
    assert_match(/invalid shortlink size/, json_response["message"])
  end

  test "decode_params with case insensitive base URL should work" do
    # The validation should be case insensitive for base URL
    # First create a short link
    post "/encode", params: { original_link: @valid_original_url }
    encode_response = JSON.parse(response.body)
    short_link = encode_response["short_link"]

    # Convert domain to uppercase while keeping protocol lowercase
    # https://shorten.com/ -> https://SHORTEN.COM/
    uppercase_short_link = short_link.sub("shorten.com", "SHORTEN.COM")

    # This should still work because validation is case insensitive
    post "/decode", params: { short_link: uppercase_short_link }
    assert_response :success
  end

    test "decode_params with non-existent short link should return not found" do
    # Create a short link with correct format but non-existent code
    non_existent_short_link = @base_url + "nonexist1" # 9 characters total
    post "/decode", params: { short_link: non_existent_short_link }
    assert_response :not_found

    json_response = JSON.parse(response.body)
    assert_match(/Link not found/, json_response["message"])
  end

  test "decode_params with expired link should return gone" do
    # Create a link that expires immediately
    post "/encode", params: { original_link: @valid_original_url }
    encode_response = JSON.parse(response.body)
    short_link = encode_response["short_link"]

    # Find the link and expire it
    link_code = short_link.gsub(@base_url, "")
    link = Link.find_by(short_link: link_code)
    link.update!(expiry_date: 1.minute.ago)

    post "/decode", params: { short_link: short_link }
    assert_response :gone

    json_response = JSON.parse(response.body)
    assert_match(/expired/, json_response["message"])
  end

  # Integration tests for the full flow
  test "full encode-decode cycle should work correctly" do
    original_url = "https://example.com/test/path?param=value"

    # Encode
    post "/encode", params: { original_link: original_url }
    assert_response :success
    encode_response = JSON.parse(response.body)
    short_link = encode_response["short_link"]

    # Verify the short link format
    assert short_link.starts_with?(@base_url)
    assert_equal @base_url.length + UrlShortener::SHORTEN_URL_SIZE, short_link.length

    # Decode
    post "/decode", params: { short_link: short_link }
    assert_response :success
    decode_response = JSON.parse(response.body)

    # Verify we get back the original URL
    assert_equal original_url, decode_response["original_link"]
    assert decode_response["expiry_date"]
  end

  test "decode_params should extract correct short code from URL" do
    # Create a short link
    post "/encode", params: { original_link: @valid_original_url }
    encode_response = JSON.parse(response.body)
    short_link = encode_response["short_link"]

    # Verify the short code extraction logic
    expected_short_code = short_link.last(UrlShortener::SHORTEN_URL_SIZE)

    post "/decode", params: { short_link: short_link }
    assert_response :success

    # The fact that decode succeeds means the short code was extracted correctly
    json_response = JSON.parse(response.body)
    assert_equal @valid_original_url, json_response["original_link"]
  end

  test "multiple encode requests should generate unique short links" do
    short_links = []

    5.times do
      post "/encode", params: { original_link: @valid_original_url }
      assert_response :success
      encode_response = JSON.parse(response.body)
      short_links << encode_response["short_link"]
    end

    # All short links should be unique
    assert_equal 5, short_links.uniq.length
  end
end
