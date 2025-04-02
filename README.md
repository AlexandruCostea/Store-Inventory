# Store-Inventory

## Overview
A powerful mobile application for efficient store inventory management, enabling multiple users to access and update data with real-time synchronization. The app allows for CRUD operations on store items while ensuring data consistency across online and offline modes.

## Features
- **Real-Time Collaboration:** Users see live updates on inventory changes made by themselves and others.<br>
- <img src="https://github.com/AlexandruCostea/Store-Inventory/blob/master/assets/MainPage.jpg" alt="App Overview" width="200" height="400"/>
  <img src="https://github.com/AlexandruCostea/Store-Inventory/blob/master/assets/AddPage.jpg" alt="Add Items" width="200" height="400"/>
  <img src="https://github.com/AlexandruCostea/Store-Inventory/blob/master/assets/UpdatePage.jpg" alt="Add Items" width="200" height="400"/>
  <img src="https://github.com/AlexandruCostea/Store-Inventory/blob/master/assets/DeletePage.jpg" alt="Add Items" width="200" height="400"/>



- **Seamless Online & Offline Support:**
  - Online: Communicates with a remote server for real-time updates.
  - Offline: Uses a local database as a fallback when the server is unreachable.
- **Data Consistency Mechanism:**
  - Any remote changes (either by the current user or from other users) are propagated to the local database when online.
  - Offline changes are logged efficiently. Existing logs get modified whenever possible, in order to keep synchronization efficient (for example, an add and an edit on the same object results in a single add log with the latest data, instead of 2 logs).
- **Communication with Server:**
  - Sends data via **HTTP requests**.
  - Receives updates via **WebSockets**.
- **Comprehensive API Testing:**
  - API endpoints are extensively tested using **Postman** to ensure reliability and correctness.
  - Automated tests validate data synchronization, CRUD operations, and edge cases.

## Technology Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Node.js, Express
- **Database:** SQLite
- **Networking:** HTTP, WebSockets
- **Testing:** Postman

## Installation & Setup

### Prerequisites
- Flutter installed
- Node.js installed (if backend is included in the repository)
- Postman for API testing

### Steps
1. **Clone the repository:**
   ```sh
   git clone https://github.com/your-username/inventory-app.git
   cd store-inventory
   ```
3. **Create a Flutter project for the app (preferably with Android Studio / VSCode):**
4. **Create an environment file:**
     ```sh
       echo "SERVER_URL: <server_path>" > .env
     ```

6. **Initialize and run the Express Server (optional):**
   ```sh
   cd src/server
   npm init
   node index.js
   ```

## API Testing with Postman
The API endpoints have been thoroughly tested using Postman.
- **Postman Collection:** Located in the `/tests/postman/` directory.

## License
This project is licensed under the MIT License.

