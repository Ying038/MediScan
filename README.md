# 🩺 MediScan

### AI-Driven Elderly Medication Safety Assistant

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore-orange?logo=firebase)
![Google AI](https://img.shields.io/badge/Google-Gemini%20API-red?logo=google)
![SDG 3](https://img.shields.io/badge/SDG-3%20Good%20Health-green)
![SDG 10 - Reduced Inequalities](https://img.shields.io/badge/SDG-10-E5243B.svg?style=flat&label=Goal%2010&logo=united-nations&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

# 📌 Project Overview

MediScan is an AI-powered medication safety assistant built specifically for elderly users.

It transforms complex prescription labels into structured, easy-to-follow medication schedules using **Google Gemini AI**, while maintaining a simplified, high-contrast, senior-first user interface.

MediScan reduces medication errors, prevents double-dosing, and enables independent living through intelligent automation.

---

# ⚠️ Problem Statement

Elderly patients frequently manage multiple prescriptions simultaneously (polypharmacy), leading to:

* Memory-based dosing errors
* Accidental double-dosing
* Missed medication
* Confusion due to small-print labels
* Lack of post-clinic guidance

Studies show that up to **75–96% of seniors admit to medication mistakes at home**.

These are systemic complexity failures — not user negligence.

---

# 🎯 Our Solution

MediScan removes the interpretation and memory burden from the patient.

Instead of reading, typing, and remembering:

1. 📸 Take a photo
2. 🤖 AI extracts medication details
3. 📅 Automatic schedule is generated
4. ⏱️ Safe time-window logging prevents overdosing

This converts medication management from manual and risky to structured and assisted.

---

# 🌍 SDG & AI Alignment

## 🎯 SDG 3 – Good Health & Well-being

MediScan reduces:

* Hospital readmissions due to medication errors
* Accidental overdoses
* Non-adherence risks

By improving adherence and safety, MediScan directly strengthens preventive healthcare systems.

## 🎯 SDG 10 - Reduced Inequalities 

By providing a senior-optimized digital tool, we ensure that technological advancements in healthcare are inclusive and accessible to the elderly, not just the tech-savvy youth.

---

## 🤖 AI Integration

We use **Google Gemini API** to convert unstructured prescription label text into structured medication schedules.

This enables:

* Zero typing setup
* Accessibility for motor impairment
* Reduced visual dependency
* Smart parsing of dosage instructions

AI is not decorative — it is the core engine of accessibility.

---

# ✨ Key Features

## 📸 AI Prescription Scanning

* Capture medicine label image
* Gemini extracts:

  * Medication name
  * Dosage
  * Frequency
  * Special instructions

---

## 🎨 Elderly-Optimized UI

* High-contrast design
* Large touch targets
* Minimal navigation layers
* Color-coded status:

  * 🟢 Green → Completed
  * 🌸 Pink → Pending

---

## ⏱️ ±1 Hour Safety Window Logic

Medication logging is only enabled within one hour of the scheduled time.

Prevents:

* Double logging
* Early accidental dosing
* Retroactive unsafe edits

---

## 🔢 Dynamic Multi-Dose Tracking

Automatically generates individual buttons for:

* Once daily
* Twice daily
* Thrice daily medications

---

## 📅 Smart Dashboard Filtering

Only future appointments are shown.
Past records are archived automatically.

Reduces cognitive clutter.

---

# 🏗️ System Architecture

## 🔁 High-Level Flow

```
User → Capture Prescription Image
        ↓
Flutter App
        ↓
Gemini API (Text Extraction + Parsing)
        ↓
Structured Medication Object
        ↓
Firebase Firestore
        ↓
Real-Time Dashboard Rendering
        ↓
Time-Window Logging System
```

---

# 🛠 Technical Implementation

## 🔷 Tech Stack

| Layer            | Technology                    |
| ---------------- | ----------------------------- |
| Frontend         | Flutter                       |
| AI Engine        | Google Gemini API             |
| Authentication   | Firebase Auth                 |
| Database         | Firebase Firestore            |

---

# 🔬 Google Technology Utilization (Cause → Effect)

## 1️⃣ Google Gemini API

**Cause:**
Prescription labels are unstructured and vary widely in format.

**Effect:**
Gemini performs intelligent parsing and contextual understanding, converting natural language instructions into structured JSON schedules.

This enables:

* Zero-typing onboarding
* Instant schedule generation
* Accessibility-first experience

Without Gemini, users would need manual data entry — defeating the purpose of elderly accessibility.

---

## 2️⃣ Firebase Authentication

**Cause:**
Medical data requires identity-linked, secure access.

**Effect:**
Firebase Auth provides secure sign-in with minimal friction.
It ensures medication records are protected and user-specific.

---

## 3️⃣ Firebase Firestore

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
* Caregiver visibility potential

---

# 💡 Innovation Highlights

* AI-driven zero-input onboarding
* Safety window logic (prevents overdosing by design)
* Cognitive-load reduction dashboard
* Elderly-first UX philosophy
* Minimalistic tech stack for scalability

---

# ⚔️ Challenges

## 1️⃣ Parsing Ambiguous Instructions

Prescription formats vary dramatically.

**Solution:**
We implemented structured output prompting with Gemini to enforce consistent JSON responses.

---

## 2️⃣ Preventing Double Logging

Users could attempt multiple confirmations.

**Solution:**
Timestamp validation + one-hour activation window logic.

---

## 3️⃣ UI Accessibility Testing

Standard mobile UI patterns are unsuitable for elderly users.

**Solution:**
Iterative font scaling, contrast optimization, simplified navigation depth.

---

# ⚙️ Setup Instructions

## 🔹 Prerequisites

* Flutter 3.x
* Dart SDK
* Firebase project (Auth + Firestore enabled)
* Gemini API key from Google AI Studio

---

## 🔹 .env Configuration

Create a `.env` file in the root directory:

```
FIREBASE_API_KEY=your_firebase_api_key
GEMINI_API_KEY=your_gemini_api_key
```


## 🔹 Firebase Setup

Enable:

* Authentication (Email/Password)
* Firestore Database

---

## 🔹 Installation

```bash
git clone https://github.com/Ying038/MediScan.git
cd mediscan
flutter pub get
flutter run
```

---

# 📈 Future Improvements

## 🧠 AI Enhancements

* Medication interaction detection
* Side-effect risk analysis
* Predictive adherence scoring

---

## 👨‍⚕️ Caregiver Ecosystem

* Caregiver dashboard access
* Remote monitoring
* SMS emergency alerts

---

## 🎙 Accessibility Expansion

* Voice-command medication logging
* Multilingual prescription recognition
* Speech-to-text integration

---

# 👥 Team CAPYbara © KitaHack 2026
