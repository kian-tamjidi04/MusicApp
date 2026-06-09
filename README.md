# MusicApp: Retrospective Practice Tracker

Built natively with Swift and SwiftUI, this application was engineered to solve retrospective practice tracking for musicians. Developed as a foundational educational project focused on end-to-end documentation, computational thinking, and the software development lifecycle, this repository achieved a final mark of 100%. The system architecture heavily utilizes procedural thinking for the decomposition of user requirements, and concurrent thinking to run a metronome simultaneously alongside a practice session timer.

## 1. Project Context & Computational Approach
This repository highlights the backend logic, state management, and systems design required to build the application, moving beyond standard UI implementations. 
* **Procedural Thinking:** Decomposed broad user requirements into sequential, modular functions (e.g. separating target creation from practice tracking).
* **Concurrent Thinking:** Engineered the metronome feature to run asynchronously and concurrently alongside the active practice session timer.

## 2. Stakeholder-Driven Requirements
The feature roadmap was explicitly defined by primary and secondary stakeholder research during the Analysis phase:
* **Primary Stakeholder:** Conducted structured interviews with a music educator to identify the core problem: students fail to engage with written targets. 
* **Market Research:** Gathered quantitative survey data from a cohort of musicians, proving a high demand for integrated metronomes (83.3% request rate) and streak counters (58.3% request rate).

## 3. Gamification Engine & Logic
To combat depleting student attention spans, a robust gamification engine was programmed into the system.
* **Progression System:** Implemented a scalable leveling architecture mapping accumulated XP to specific tiers (e.g., Level 1 at 100 XP, Level 5 at 1000 XP).
* **Virtual Economy:** Programmed an interactive power-up economy allowing users to purchase items like a "streak freezer" to protect daily practice chains, or a "double points token" to multiply session rewards.

## 4. System Architecture & State Management
Robust state management and data persistence were achieved utilizing Core Data, ensuring seamless data transfer across the application's lifecycle.
* **Entity Management:** Established complex entities including CoreInstrument to manage multiple user profiles concurrently, and CoreDifficulty to track user-defined weaknesses across music theory topics.
* **Dynamic Filtering:** Leveraged complex data structures, including dictionaries mapping topics to difficulty ratings, to dynamically sort and filter the theory interface.
<img width="487" height="192" alt="Screenshot 2026-06-09 at 20 23 45" src="https://github.com/user-attachments/assets/8ab385b3-79ea-4100-b323-daa4ad87a453" />

<img width="487" height="192" alt="Screenshot 2026-06-09 at 20 24 09" src="https://github.com/user-attachments/assets/0ea7e494-db5a-458a-aa29-afce876cc2b0" />

## 5. Testing & Validation Rigor
The application underwent a rigorous Iterative and Post-Development Test Plan to ensure data integrity and a frictionless UX.
* **Boundary & Invalid Testing:** Evaluated boundary data for metronome speed limits, timer completions, and invalid input testing to prevent duplicate targets from being saved to the database.
* **Usability Testing:** Conducted extensive post-development usability testing with the primary stakeholder to validate the resolution of the initial problem statement.

Tech Stack: Swift | SwiftUI | Core Data
