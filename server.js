const express = require('express');
const { MongoClient } = require('mongodb');
const fs = require('fs');

// === EDIT THIS: MongoDB Atlas URI ===
const uri = 'mongodb+srv://komalkunchaparthi:FTx8xuRDMSVfx4bs@tracker.dd8n3c6.mongodb.net/?retryWrites=true&w=majority&appName=tracker';

// === Database/Collection Names ===
const DB_NAME = 'getracker';
const COLLECTION_NAME = 'tracker';
const PORT = 3001;
// === Load JSON file with coordinates ===
const locations = JSON.parse(fs.readFileSync('locations.json', 'utf8'));

// === MongoDB client ===
const client = new MongoClient(uri);
const app = express();

// async function run() {
//   try {
//     await client.connect();
//     console.log('✅ Connected to MongoDB Atlas');

//     const db = client.db(DB_NAME);
//     const collection = db.collection(COLLECTION_NAME);

//     let index = 0;
//     const total = locations.length;

//     if (total === 0) {
//       console.log('⚠️  No locations found in JSON file.');
//       return;
//     }

//     console.log(`📌 Loaded ${total} locations.`);

//     const intervalId = setInterval(async () => {
//     //   if (index >= total) {
//     //     console.log('✅ All locations inserted. Stopping.');
//     //     clearInterval(intervalId);
//     //     await client.close();
//     //     return;
//     //   }

//       const location = locations[index];
//       const document = {
//         latitude: location.lat,
//         longitude: location.lng,
//         timestamp: new Date()
//       };

//       try {
//         const result = await collection.insertOne(document);
//         console.log(`✅ Inserted (${index + 1}/${total}):`, document);
//       } catch (err) {
//         console.error('❌ Insert failed:', err);
//       }

//       index++;
//       if (index >= total) {

//         index = 0;  // loop back to start

//         console.log('🔄 All locations sent. Restarting from first.');

//       }
//     }, 3000);

//   } catch (err) {
//     console.error('❌ Error connecting to MongoDB:', err);
//   }
// }

// async function main() {
//   try {
//     // Connect to MongoDB
//     await client.connect();
//     console.log('✅ Connected to MongoDB Atlas');

//     const db = client.db(DB_NAME);
//     collection = db.collection(COLLECTION_NAME);

//     // Start inserting locations every 3 seconds
//     // startInsertingLocations();

//     // Set up Express API
//     // setupApi();

//   } catch (err) {
//     console.error('❌ Error:', err);
//   }
// }
app.get('/locations', async (req, res) => {
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB Atlas');

    const db = client.db(DB_NAME);
    collection = db.collection(COLLECTION_NAME);
    const result = await collection
      .find({}, { projection: { _id: 0, latitude: 1, longitude: 1, timestamp: 1 } })
      .sort({ timestamp: -1 })
      .limit(1)
      .toArray();

    if (result.length === 0) {
      return res.status(404).json({ message: 'No location found' });
    }

    res.json(result[0]);
  } catch (err) {
    console.error('❌ Error fetching location:', err);
    res.status(500).send('Error fetching location');
  }
});
app.listen(PORT, () => {
    console.log(`🚀 API server running at http://localhost:${PORT}`);
    console.log(`👉 Endpoint available: GET /locations`);
  });


// main();