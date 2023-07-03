//#Important! Click the "generate tests" button if you have made any changes to this file.

//#Read more about Gherkin syntax https://cucumber.io/docs/gherkin/reference/
//#Read more about bdd_widget_test package https://pub.dev/packages/bdd_widget_test 

Feature: Tests
  Scenario : Obtain current device location
    Given the app is running
    Given the location function is enabled
    When the obtenerUbicacion() function is called
    Then the app should retrieve the latitude and longitude
    And the app should fetch the address corresponding to the coordinates
    Then the app should display the full address in the user interface
  
  Scenario : User takes a photo
    Given the app is running
    Given the user has granted camera access permission
    When the user selects to take a photo
    Then the app should open the camera
    Then the app should display the captured photo
    And the app should show a progress indicator
    And the app should send the photo to the function infer()
    And the app should send the infer results to the function updateIcons()
    And the app should hide the progress indicator
  
  Scenario : Perform inference on image
    Given the app is running
    Given the device is connected to the internet
    When the image file is valid
    Then the app should encode the image file into base64 format
    And the app should send a POST request to the inference API with the encoded image
    And the app should receive a response from the API
    Then the app should decode the response body
  
  Scenario : Update icons based on inference results
    Given the app is running
    Given the app has the inference results
    Then the app should display the predicted icons
  
  Scenario : User sends a request
    Given the app is running
    Given the device is connected to the internet
    Given the app has the address and selected options
    When the user submits the request
    Then the app should display a progress indicator
    And the app should send the request to the server
    And the app should receive a response from the server
    And the app should hide the progress indicator
    And the app should send the response to the function showAlerDialog()
  
  Scenario : Display alert dialog with appropriate text
    Given the app is running
    When the app needs to display an alert dialog
    Then the app should show the alert dialog with the provided text
    When the user taps the "Cerrar" button
    Then the app should close the alert dialog
    
