# 🩺 MediScan

### AI-Driven Elderly Medication Safety Assistant


## 📌 Project Overview

MediScan is an AI-powered medication safety assistant built specifically for elderly users.

It transforms complex prescription labels into structured, easy-to-follow medication schedules using **Google Gemini AI**, while maintaining a simplified, high-contrast, senior-first user interface.

MediScan reduces medication errors, prevents double-dosing, and enables independent living through intelligent automation.



## ⚠️ Problem Statement

MediScan addresses three major challenges faced by seniors:

### 1️⃣ Polypharmacy

* Seniors take an average of **5+ medications daily**
* Increased risk of missed doses or double dosing
* Higher chance of adverse drug interactions

### 2️⃣ Vision Barriers

* Tiny font on medication labels
* Difficulty reading or manually logging prescriptions
* Poor contrast in traditional applications

### 3️⃣ Memory Gaps

* Anxiety about whether medication was taken
* Risk of accidental overdose
* Missed life-critical medications (e.g., heart, diabetes, blood pressure)

Studies show that up to **75–96% of seniors admit to medication mistakes at home**.

These are systemic complexity failures — not user negligence.



## 🎯 Our Solution

MediScan removes the interpretation and memory burden from the patient.

Instead of reading, typing, and remembering:

1. 📸 Take a photo
2. 🤖 AI extracts medication details
3. 📅 Automatic schedule is generated
4. ⏱️ Safe time-window logging prevents overdosing

This converts medication management from manual and risky to structured and assisted.



## 🌍 SDG & AI Alignment

### 🏥 SDG 3 – Good Health & Well-being

* Reduces hospital readmissions
* Prevents medication errors
* Improves long-term adherence

### ⚖ SDG 10 – Reduced Inequalities

* Makes healthcare technology senior-friendly
* Bridges digital literacy gap
* Promotes inclusive innovation


### 🤖 AI Integration

We use **Google Gemini API** to convert unstructured prescription label text into structured medication schedules.

This enables:

* Zero typing setup
* Accessibility for motor impairment
* Reduced visual dependency
* Smart parsing of dosage instructions

AI is not decorative — it is the core engine of accessibility.


## ✨ Key Features

### 📸 AI Label Scanning

* Extracts drug names
* Dosages
* Frequency
* Special instructions


### 📅 Smart Calendar

* Visual timeline of doses
* Doctor appointment integration
* Daily clarity view



### 🔔 Intelligent Reminders

* Push notifications
* Requires **“Confirm Intake”**
* Prevents passive skipping


### 🔉 Audio Assistance

* Reads labels aloud
* Reduces pill anxiety


### 📊 Progress Tracking

* Visual streak system
* Historical logs


### 🗺️ Pharmacy Locator

* Integrated Google Maps API
* Locate nearest open pharmacy
* Emergency refill assistance

---

## 📁 Project Structure

```
lib/
├── pages/
│   ├── auth_page.dart
│   ├── calendar_page.dart
│   ├── home_page.dart
│   ├── main_navigation_hub.dart
│   ├── med_form_page.dart
│   ├── profile_page.dart
│   └── scanner_page.dart
│
├── services/
│   ├── ai_service.dart
│   ├── auth_service.dart
│   ├── location_service.dart
│   └── med_service.dart
│
├── auth_gate.dart
├── firebase_options.dart
└── main.dart
```


## ⚙️ Setup Instructions

### 🔹 Prerequisites

Ensure you have the following installed:

* **Flutter SDK (3.x or later)**
* **Dart SDK**
* **Android Studio** (for Android development)
* **Xcode** (for iOS development)
* **Android Emulator or physical device**
* **Google Gemini API Key**


### 🔹 .env Configuration

Create a `.env` file in the root directory:

```
GEMINI_API_KEY=your_gemini_api_key
```

### 🔹 Installation

```bash
git clone https://github.com/Ying038/MediScan.git
cd mediscan
flutter pub get
flutter run
```

## 🏗️ System Architecture

### 🔁 High-Level Flow

```
User Device (Flutter App)
        ↓
Firebase Authentication
        ↓
Cloud Firestore (Schedules & Logs)
        ↓
Gemini API (Text Extraction + Parsing)
        ↓
Structured Medication Object
        ↓
Firebase Analytics
        ↓
Real-Time Dashboard Rendering
        ↓
Time-Window Logging System
```

## 🛠 Technical Implementation

### 🔷 Tech Stack

| Layer            | Technology                    |
| ---------------- | ----------------------------- |
| Frontend         | Flutter                       |
| AI Engine        | Google Gemini API             |
| Authentication   | Firebase Auth                 |
| Database         | Firebase Firestore            |
| Analytics        | Firebase Analytics            |


## 🔬 Google Technology Utilization

##  Flutter 

* Cross-platform mobile development (iOS & Android)
* Single codebase
* Accessible UI customization

### Google Gemini AI

**Cause:**
Prescription labels are unstructured and vary widely in format.

**Effect:**
Gemini performs intelligent parsing and contextual understanding, converting natural language instructions into structured JSON schedules.

This enables:

* Zero-typing onboarding
* Instant schedule generation
* Accessibility-first experience

Without Gemini, users would need manual data entry — defeating the purpose of elderly accessibility.


### Firebase Authentication

**Cause:**
Medical data requires identity-linked, secure access.

**Effect:**
Firebase Auth provides secure sign-in with minimal friction.
It ensures medication records are protected and user-specific.


### Cloud Firestore

**Cause:**
Medication logs must update instantly and persist safely.

**Effect:**
Firestore provides:

* Real-time synchronization
* Offline persistence
* Scalable NoSQL storage
* Secure document-level rules

This ensures:

* Reliable medication history
* Instant UI updates
  

### Firebase Analytics

* Tracks adherence behavior
* Monitors missed-dose patterns

### Benefits

* Serverless architecture
* Automatic scaling
* Built-in security rules
* Real-time synchronization


## 💡 Implementation Details
MediScan consists of five integrated modules, each designed to provide a safe, accessible, and intelligent medication management experience for seniors.

### AI Medication Scanning Module
Users simply take a photo of their medication label using the in-app camera.

* The system leverages multimodal AI to:
* Extract medication name, dosage, and frequency
* Interpret prescription instructions
*Detect special warnings (e.g., “take after meals”)

The AI validates extracted data using built-in safety logic before saving it to the schedule.
This eliminates manual typing and significantly reduces human error during medication entry.

### Smart Scheduling & Reminder Module
Once medication details are captured, MediScan automatically generates a structured dosage schedule.

Features include:
* Visual daily and weekly medication calendar
* Timed push notifications for each dose
* “Confirm Intake” button to prevent accidental double logging
* Missed dose detection with follow-up alerts

The system ensures that no medication is logged twice within unsafe time intervals, adding an additional safety layer.

### Safety & Double-Dose Prevention Module
This module acts as MediScan’s protective layer.

It:
* Checks last logged intake time
* Blocks duplicate confirmations within restricted intervals
* Flags unusual medication patterns
* Notifies users if a potential overdose risk is detected

The system prioritizes prevention over correction, reducing medical risks before they occur.

### Accessibility & Audio Assistance Module
Designed specifically for the Golden Generation, this module focuses on usability and clarity.

Features include:
* High-contrast user interface
* Large, easy-to-press buttons
* Simplified navigation flow
* Text-to-speech label reading
* Verbal confirmation after each logged dose

By minimizing visual strain and cognitive load, MediScan ensures technology remains inclusive and senior-friendly.

### Pharmacy & Healthcare Support Module
This module connects users with nearby healthcare resources.

Capabilities:
* Integrated map view to locate nearby pharmacies
* Displays currently open pharmacies
* Refill reminders based on remaining medication supply
* Quick access to healthcare facilities

This ensures users can act promptly when prescriptions run low.

## ⚔️ Challenges

### 1️⃣ Parsing Ambiguous Instructions

Prescription formats vary dramatically.

**Solution:**
We implemented structured output prompting with Gemini to enforce consistent JSON responses.


### 2️⃣ Preventing Double Logging

Users could attempt multiple confirmations.

**Solution:**
Timestamp validation + one-hour activation window logic.


### 3️⃣ UI Accessibility Testing

Standard mobile UI patterns are unsuitable for elderly users.

**Solution:**
Iterative font scaling, contrast optimization, simplified navigation depth.


## 📈 Future Improvements

### Phase 1: Accessibility Expansion

* Multilingual support
* Voice-command logging
* Caregiver-linked accounts

### Phase 2: Health Integration

* Wearable device sync
* Drug interaction checker
* Emergency alert system

### Phase 3: Smart Healthcare Ecosystem

* Direct pharmacy refill requests
* Physician dashboard access
* Predictive adherence analytics

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange?logo=firebase)
![Google AI](https://img.shields.io/badge/Google-Gemini%20API-red?logo=google)
![SDG 3](https://img.shields.io/badge/SDG-3%20Good%20Health%20and%20Well%20Being-green)
![SDG 10](https://img.shields.io/badge/SDG-10%20Reduced%20Inequalities-pink)


### 👥 Team CAPYbara © KitaHack 2026
