const { MongoClient } = require('mongodb');
const fs = require('fs');

// === EDIT THIS: MongoDB Atlas URI ===
const uri = 'mongodb+srv://komalkunchaparthi:FTx8xuRDMSVfx4bs@tracker.dd8n3c6.mongodb.net/?retryWrites=true&w=majority&appName=tracker';

// === Database/Collection Names ===
const DB_NAME = 'getracker';
const COLLECTION_NAME = 'tracker';

// === Load JSON file with coordinates ===
const locations = JSON.parse(fs.readFileSync('locations.json', 'utf8'));

// === MongoDB client ===
const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    console.log('✅ Connected to MongoDB Atlas');

    const db = client.db(DB_NAME);
    const collection = db.collection(COLLECTION_NAME);

    let index = 0;
    const total = locations.length;

    if (total === 0) {
      console.log('⚠️  No locations found in JSON file.');
      return;
    }

    console.log(`📌 Loaded ${total} locations.`);

    const intervalId = setInterval(async () => {

      const location = locations[index];
      const document = {
        latitude: location.lat,
        longitude: location.lng,
        timestamp: new Date()
      };

      try {
        const result = await collection.insertOne(document);
        console.log(`✅ Inserted (${index + 1}/${total}):`, document);
      } catch (err) {
        console.error('❌ Insert failed:', err);
      }

      index++;
      if (index >= total) {

        index = 0;  // loop back to start

        console.log('🔄 All locations sent. Restarting from first.');

      }
    }, 3000);

  } catch (err) {
    console.error('❌ Error connecting to MongoDB:', err);
  }
}

run();
