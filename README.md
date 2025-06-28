# MongoDB Latitude/Longitude Poster with API

This Node.js project does two things in parallel:

✅ Every 3 seconds, it posts latitude/longitude coordinates (from a JSON file) to a MongoDB Atlas database.  
✅ It exposes an HTTP API (via Express) that lets you fetch the **most recently posted** latitude/longitude and timestamp.

---

## 📌 Features

- Reads a list of coordinates from `locations.json`
- Inserts one coordinate into MongoDB every 3 seconds
- Loops through the list forever
- Includes an Express server with:
  - `GET /locations` → fetches the latest inserted location

---

## 🚀 Technologies Used

- Node.js
- Express
- MongoDB (Atlas)

---

## 📂 Project Structure

project/
│
├── postLocations.js # Main Node.js script
├── locations.json # Input list of lat/lng coordinates
├──server.js
└── README.md # This file

yaml
Copy
Edit

---

## 🗺️ Example `locations.json`

Provide your own list of coordinates. Example:

```json
[
  { "latitude": 17.385044, "longitude": 78.486671 },
  { "latitude": 17.386000, "longitude": 78.487000 },
  { "latitude": 17.387500, "longitude": 78.488500 }
]
The script will cycle through these, inserting one every 3 seconds.

🛠️ Installation
1️⃣ Clone the repo:

bash
Copy
Edit
git clone https://github.com/komal-kdev/gps-tracker-location.git
cd gps-tracker-location
2️⃣ Install dependencies:

bash
Copy
Edit
npm install
3️⃣ Add your MongoDB Atlas connection string:

Open postLocations.js and replace:

js
Copy
Edit
const uri = 'YOUR_MONGODB_ATLAS_URI';
with your actual MongoDB connection URI.

▶️ Running the App
bash
Copy
Edit
node postLocations.js
✅ Every 3 seconds, it inserts the next coordinate (with timestamp) into MongoDB.
✅ When it reaches the end of the list, it loops back to the start.
✅ It also starts an HTTP API server.

🌐 API Endpoint
GET /locations
Returns only the most recent inserted location.

Example request:

bash
Copy
Edit
curl http://localhost:3001/locations
Example response:

json
Copy
Edit
{
  "latitude": 17.385044,
  "longitude": 78.486671,
  "timestamp": "2025-06-27T16:01:12.345Z"
}
⚙️ Configuration
Edit these variables in postLocations.js as needed:

js
Copy
Edit
const uri = 'YOUR_MONGODB_ATLAS_URI';
const DB_NAME = 'geoDB';
const COLLECTION_NAME = 'locations';
const PORT = 3001;
✅ Example MongoDB Document
Documents inserted in MongoDB look like:

json
Copy
Edit
{
  "latitude": 17.385044,
  "longitude": 78.486671,
  "timestamp": ISODate("2025-06-27T16:01:12.345Z")
}
📌 Notes
To run open two terminals, on one terminal node postLocations.js and on another terminal node server.js
This script is meant for demo / testing / prototyping.

It cycles forever through your input coordinates.

Make sure your MongoDB cluster and IP access are properly configured.
