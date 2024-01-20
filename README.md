# MediRisk

MediRisk is a cutting-edge Flutter application designed to empower users with a holistic approach to health management. Leveraging advanced technologies, the app comprises three distinctive components, each addressing crucial aspects of healthcare. The first component employs a deep learning model based on neural networks to predict diseases accurately by analyzing user-input symptoms. This model, compiled into a TensorFlow Lite model, boasts an impressive accuracy of near 100%. The second component focuses on mental health analysis, utilizing an interactive quiz to provide users with insights into their psychological well-being. Lastly, the third component records and monitors users’ past medical history, particularly emphasizing respiratory and cardiovascular conditions. The integration of real-time environmental data through the OpenWeather API enables the app to deliver timely alerts and notifications, ensuring users stay informed about potential health risks based on current weather conditions.

## Getting Started

After cloning this repository, follow the steps below to set up and run the application:

1. **Firebase Configuration:**
   - Obtain your Firebase configuration file (`.json`) from the Firebase Console.
   - Replace the existing configuration in the project with your own.

2. **Firestore Setup:**
   - Make necessary changes in the code wherever Firebase Firestore is involved.

3. **OpenWeather API Key:**
   - Get your OpenWeather API key and replace the placeholder in the code with your key.

4. **Development Environment:**
   - Use Android Studio or VS Code for Flutter development.

5. **Run the Application:**
   - Connect a device or use an emulator.
   - Run the Flutter application.

## Additional Information

### Machine Learning Model
- The disease prediction component utilizes a machine learning model created with Python, TensorFlow, and Keras.
- The model is trained on a Kaggle dataset, and its accuracy is optimized for real-world health predictions.

### Security Measures
- User data and health-related information are securely stored in Firebase, emphasizing data privacy.
- Future plans include implementing encryption, access control, and regular security audits.

### Mental Health Feature
- The interactive quiz feature provides users with a preliminary mental health assessment.
- Ongoing efforts involve enhancing this feature using advanced machine learning models or APIs for more accurate assessments.

### Real-time Environmental Monitoring
- The integration of OpenWeather API allows real-time monitoring of environmental conditions, contributing to personalized health alerts.

## Tools and Technologies Used

- Flutter
- Dart
- Python (for creating the machine learning model)
- TensorFlow and TensorFlow Lite
- Android Studio / VS Code
- OpenWeather API
