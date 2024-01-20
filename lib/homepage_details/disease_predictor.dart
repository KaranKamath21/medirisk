import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:medirisk/homepage_details/predicted_disease.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class DiseasePredictor extends StatefulWidget {
  const DiseasePredictor({Key? key}) : super(key: key);

  @override
  State<DiseasePredictor> createState() => _DiseasePredictorState();
}

class _DiseasePredictorState extends State<DiseasePredictor> {
  popMsg(String msg) {
    Fluttertoast.showToast(msg: msg);
  }

  late tfl.Interpreter interpreter;
  bool inputComplete = false;
  String predictedDisease = '';
  late Map<String, bool> symptoms = {
    'Itching': false,
    'Skin Rashes': false,
    'Nodal Skin Eruptions': false,
    'Continuous Sneezing': false,
    'Shivering': false,
    'Chills': false,
    'Joint Pain': false,
    'Stomach Pain': false,
    'Acidity': false,
    'Ulcers on Tongue': false,
    'Muscle Wasting': false,
    'Vomitting': false,
    'Burning Micturition': false,
    'Spotting Urination': false,
    'Fatigue': false,
    'Weight Gain': false,
    'Anxiety': false,
    'Cold Hands and Feets': false,
    'Mood Swings': false,
    'Weight Loss': false,
    'Restlessness': false,
    'Lethargy': false,
    'Patches in throat': false,
    'Irregular sugar level': false,
    'Cough': false,
    'High fever': false,
    'Sunken eyes': false,
    'Breathlessness': false,
    'Sweating': false,
    'Dehydration': false,
    'Indigestion': false,
    'Headache': false,
    'Yellowish skin': false,
    'Dark urine': false,
    'Nausea': false,
    'Loss of appetite': false,
    'Pain behind the eyes': false,
    'Back pain': false,
    'Constipation': false,
    'Abdominal Pain': false,
    'Diarrhoea': false,
    'Mild fever': false,
    'Yellow urine': false,
    'Yellowing of eyes': false,
    'Acute liver failure': false,
    'Fluid overload': false,
    'Swelling of stomach': false,
    'Swelled lymph nodes': false,
    'Malaise': false,
    'Blurred and distorted vision': false,
    'Phlegm': false,
    'Throat Irritation': false,
    'Redness of eyes': false,
    'Sinus Pressure': false,
    'Runny Nose': false,
    'Congestion': false,
    'Chest Pain': false,
    'Weakness in limbs': false,
    'Fast Heart rate': false,
    'Pain during bowel movements': false,
    'Pain in anal region': false,
    'Bloody stool': false,
    'Irritation in anus': false,
    'Neck pain': false,
    'Dizziness': false,
    'Cramps': false,
    'Bruising': false,
    'Obesity': false,
    'Swollen legs': false,
    'swollen_blood_vessels': false,
    'Puffy face and eyes': false,
    'Enlarged thyroid': false,
    'Brittle nails': false,
    'Swollen extremities': false,
    'Excessive Hunger': false,
    'Extra marital contacts': false,
    'Drying and tingling lips': false,
    'Slurred speech': false,
    'Knee pain': false,
    'Hip joint pain': false,
    'Muscle weakness': false,
    'Stiff neck': false,
    'Swelling joints': false,
    'Movement stiffness': false,
    'Spinning movements': false,
    'Loss of balance': false,
    'Unsteadiness': false,
    'Weakness of one body side': false,
    'Loss of smell': false,
    'Bladder discomfort': false,
    'Foul smell of urine': false,
    'Continuous feel of urine': false,
    'Passage of gases': false,
    'Internal itching': false,
    'Toxic look (typhos)': false,
    'Depression': false,
    'Irritability': false,
    'Muscle pain': false,
    'Altered Sensorium': false,
    'Red spots over body': false,
    'Belly pain': false,
    'Abnormal Menstruation': false,
    'Dischromic patches': false,
    'Watering from eyes': false,
    'Increased appetite': false,
    'Polyuria': false,
    'Family history': false,
    'Mucoid sputum': false,
    'Rusty sputum': false,
    'Lack of concentration': false,
    'Visual disturbances': false,
    'Receiving blood transfusion': false,
    'Receiving unsterile injections': false,
    'Coma': false,
    'Stomach bleeding': false,
    'Distention of abdomen': false,
    'History of alcohol consumption': false,
    'Fluid overload': false,
    'Blood in sputum': false,
    'Prominent veins on calf': false,
    'Palpitations': false,
    'Painful walking': false,
    'Pus filled pimples': false,
    'Blackheads': false,
    'Scurring': false,
    'Skin peeling': false,
    'Silver like dusting': false,
    'Small dents in nails': false,
    'Inflammatory nails': false,
    'Blister': false,
    'Red sore around nose': false,
    'Yellow crust ooze': false,
    'Prognosis': false,
  };

  List<String> filteredSymptoms = [];

  @override
  void initState() {
    super.initState();
    loadModel();
    filteredSymptoms = symptoms.keys.toList();
  }

  Future<void> loadModel() async {
    interpreter =
        await tfl.Interpreter.fromAsset('assets/models/tf_lite_model.tflite');
    print('Model loaded successfully');
  }

  Future predictDisease() async {
    int checkbit = 0;
    // Prepare input data for the model
    List<int> inputData = [];
    for (var symptom in symptoms.keys) {
      inputData.add(symptoms[symptom]! ? 1 : 0);
      checkbit += (symptoms[symptom]! ? 1 : 0);
    }

    if (checkbit == 0) {
      popMsg("Please select at least one symptom");
      return;
    }

    if (checkbit < 3) {
      popMsg("Please select at least 3 symptoms");
      return;
    }

    // Run model prediction
    List<int> outputShape = interpreter.getOutputTensor(0).shape;
    Map<int, Object> outputs = {
      0: List.filled(outputShape.reduce((a, b) => a * b), 0)
          .reshape(outputShape),
    };

    interpreter.runForMultipleInputs([inputData], outputs);

    setState(() {
      // Access the output tensor and process the probabilities
      List<List<dynamic>> output = (outputs[0] as List<List<dynamic>>);
      List<double> flattenedOutput =
          output.expand((list) => list).cast<double>().toList();

      // Process the output as needed
      // For example, find the disease with the highest probability
      int predictedDiseaseIndex = flattenedOutput.indexOf(
          flattenedOutput.reduce((curr, next) => curr > next ? curr : next));

      // Retrieve the predicted disease based on the index
      predictedDisease = getDiseaseByIndex(predictedDiseaseIndex);

      print("Predicted Disease Index: $predictedDiseaseIndex");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictedDisease(
            diseaseName: predictedDisease,
          ),
        ),
      );

      // inputComplete = true;
    });
  }

  String getDiseaseByIndex(int index) {
    // Define your list of diseases as per the provided list
    List<String> diseases = [
      "Acne",
      "AIDS",
      "Alcoholic hepatitis",
      "Allergy",
      "Arthritis (vertigo) Paroxysmal Positional Vertigo",
      "Bronchial Asthma",
      "Cervical spondylosis",
      "Chicken pox",
      "Chronic cholestasis",
      "Common Cold",
      "Dengue",
      "Diabetes",
      "Dimorphic hemorrhoids (piles)",
      "Drug Reaction",
      "Fungal infection",
      "Gastroenteritis",
      "GERD",
      "Heart attack",
      "Hepatitis A",
      "Hepatitis B",
      "Hepatitis C",
      "Hepatitis D",
      "Hepatitis E",
      "Hypertension",
      "Hyperthyroidism",
      "Hypoglycemia",
      "Hypothyroidism",
      "Impetigo",
      "Jaundice",
      "Malaria",
      "Migraine",
      "Osteoarthritis",
      "Paralysis (brain hemorrhage)",
      "Peptic ulcer disease",
      "Pneumonia",
      "Psoriasis",
      "Tuberculosis",
      "Typhoid",
      "Urinary tract infection",
      "Varicose veins",
    ];

    if (index >= 0 && index < diseases.length) {
      return diseases[index];
    } else {
      return 'Unknown Disease';
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Disease Predictor",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFFDDDAE7),
      ),
      backgroundColor: Color(0xFFFFFFFF),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                // Filter symptoms based on user input
                setState(() {
                  filteredSymptoms = symptoms.keys
                      .where((symptom) =>
                          symptom.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                labelText: 'Search Symptoms',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredSymptoms.length,
              itemBuilder: (context, index) {
                final symptom = filteredSymptoms[index];
                return CheckboxListTile(
                  title: Text(symptom),
                  value: symptoms[symptom] ?? false,
                  onChanged: (value) {
                    setState(() {
                      symptoms[symptom] = value ?? false;
                    });
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              predictDisease();
            },
            child: const Text("Predict Disease"),
          ),
          // if (inputComplete)
          //   Column(
          //     children: [
          //       // Display the results
          //       Text("Predicted Disease: $predictedDisease"),
          //       // You can customize this based on your model's output
          //     ],
          //   ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    interpreter.close();
  }
}
