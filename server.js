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

async function connectToMongo() {
  if (!client) {
    client = new MongoClient(uri);
    await client.connect();
    console.log('✅ Connected to MongoDB Atlas()');
  }
  const db = client.db(DB_NAME);
  collection = db.collection(COLLECTION_NAME);
}


app.get('/locations', async (req, res) => {
  try {
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

app.get('/locations/history', async (req, res) => {
  try {
    const { from, to } = req.query;    

    if (!from || !to) {
      return res.status(400).json({ message: 'Missing "from" or "to" query parameters. Format: YYYY-MM-DD' });
    }
    const fromDate = new Date(from);
    const toDate = new Date(to);

    if (isNaN(fromDate) || isNaN(toDate)) {
      return res.status(400).json({ message: 'Invalid date format. Use YYYY-MM-DD.' });
    }

    toDate.setHours(23, 59, 59, 999);

    const results = await collection
      .find(
        { timestamp: { $gte: fromDate, $lte: toDate } },
        { projection: { _id: 0, latitude: 1, longitude: 1, timestamp: 1 } }
      )
      .sort({ timestamp: 1 })
      .toArray();

    res.json(results);
    
  } catch (err) {
    console.error('❌ Error fetching history:', err);
    res.status(500).send('Error fetching history');
  }
});


async function startServer() {
  try {
    await connectToMongo();
   // Start Express
    app.listen(PORT, () => {
      console.log(`🚀 API server running at http://localhost:${PORT}`);
      console.log(`👉 GET /locations          → Latest location`);
      console.log(`👉 GET /locations/history  → History with ?from=YYYY-MM-DD&to=YYYY-MM-DD`);
    });
  } catch (err) {
    console.error('❌ Failed to start server:', err);
    process.exit(1);
  }
}
startServer();