

@NumberVerification
Feature: Camara Number Verification API

# Input to be provided by the implementation to the tests
# References to OAS spec schemas refer to schemas specified in
# https://raw.githubusercontent.com/camaraproject/NumberVerification/main/code/API_definitions/number_verification.yaml

  Background: Common Number Verification setup
    Given the resource "/number-verification/v0"  as  base url
    And the header "Content-Type" is set to "application/json"
    And the header "Authorization" is set to a valid access token
    And the header "x-correlator" is set to a UUID value
    And the request body is compliant with the schema NumberVerificationRequestBody
    And the response body is compliant with the schema NumberVerificationMatchResponse
    And the header "x-correlator" is set to a UUID value
    And NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1 is compliant with the schema DevicePhoneNumber
    And NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER2 is compliant with the schema DevicePhoneNumber
    And NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1 is different to NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER2

  @NumberVerification_verify0_phoneNumber_does_not_match_schema
  Scenario Outline: phoneNumber value does not comply with the schema
    Given the request body property "$.phoneNumber" is set to: <phone_number_value>
    When the HTTP "POST" request is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | phone_number_value |
      | string_value       |
      | 1234567890         |
      | +12334foo22222     |
      | +00012230304913849 |
      | 123                |
      | ++49565456787      |

  @NumberVerification_verify1_xcorrelator_does_not_match_schema
  Scenario Outline: x-correlator request header value does not comply with the schema
    Given the request header "x-correlator" is set to: <xcorrelator_value>
    When the HTTP "POST" request is sent
    Then the response status code is 400
    And the response property "$.status" is 400
    And the response property "$.code" is "INVALID_ARGUMENT"
    And the response property "$.message" contains a user friendly text

    Examples:
      | xcorrelator_value  |
      | string_value       |
      | boink              |


  @NumberVerification_verify100_match_true
  Scenario:  verify phone number NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1, network connection and access token matches NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1
    Given they use the base url over a mobile connection
    And the resource is "/verify"
    And they acquired a valid access token associated with NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1 through OIDC authorization code flow or CIBA
    And one of the scopes associated with the access token is number-verification:verify
    When the HTTPS "POST" request is sent
    And the mobile connection is associated with NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1
    And the request body has the field phoneNumber with a value of NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response body complies with the OAS schema at "/components/schemas/SendCodeResponse"
    Then the response status code is 200
    And the response property "$.devicePhoneNumberVerified" is true


  @NumberVerification_verify2_nonempty_match_false
  Scenario:  verify phone number NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1, network connection and access token matches NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER2
    Given they use the base url over a mobile connection
    And the resource is "/verify"
    And they acquired a valid access token associated with NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1 through OIDC authorization code flow or CIBA
    And one of the scopes associated with the access token is number-verification:verify
    When the HTTPS "POST" request is sent
    And the mobile connection is associated with NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER1
    And the request body has the field phoneNumber with a value of NUMBERVERIFY_VERIFY_MATCH_PHONENUMBER2
    And the response header "x-correlator" has same value as the request header "x-correlator"
    And the response header "Content-Type" is "application/json"
    And the response body complies with the OAS schema at "/components/schemas/SendCodeResponse"
    Then the response status code is 200
    And the response property "$.devicePhoneNumberVerified" is false




