# MAD Fixed Exercise 3 - Networking

This repository contains a small UIKit login app for the REST networking
exercise. It sends an email and password to Firebase Authentication and shows
either a success alert or an understandable error message.

## Run the app

1. Open `MADNetworkingExercise.xcodeproj` in Xcode.
2. Select an iPhone simulator.
3. Press **Run**.
4. The exercise credentials are already filled in. Press **Login**.

## File overview

- `ViewController.swift` builds the small login screen and displays alerts.
- `Networking.swift` creates the POST request and handles its asynchronous
  response.
- `User.swift` models a successful Firebase response.
- `NetworkingError.swift` contains all required errors and the models for a
  Firebase error response.

The implementation uses completion handlers because that is the topic of the
exercise. It intentionally does not use newer `async/await` syntax.
