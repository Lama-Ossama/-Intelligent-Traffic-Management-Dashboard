// ============================================================
//  Intelligent Traffic Management Dashboard
//  Presentation Layer — server.js
//  Reads traffic data from CSV and serves a web dashboard
// ============================================================

const express = require('express');
const fs      = require('fs');
const path    = require('path');
const csv     = require('csv-parser');

const app  = express();
const PORT = 3002;

// ── View engine & static files ────────────────────────────
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));

// ── Helper: read and parse the CSV file ───────────────────
function readTrafficCSV(callback) {
  const results = [];
  const filePath = path.join(__dirname, 'data', 'Traffic.csv');

  // Check that the file exists before trying to parse it
  if (!fs.existsSync(filePath)) {
    return callback(new Error('CSV file not found at data/Traffic.csv'), null);
  }

  fs.createReadStream(filePath)
    .pipe(csv())
    .on('data', (row) => {
      // Normalise column names (trim whitespace, handle casing)
      const record = {
        time:            (row['Time']             || '').trim(),
        date:            (row['Date']             || '').trim(),
        dayOfWeek:       (row['Day of the week']  || '').trim(),
        carCount:        parseInt(row['CarCount']   || 0, 10),
        bikeCount:       parseInt(row['BikeCount']  || 0, 10),
        busCount:        parseInt(row['BusCount']   || 0, 10),
        truckCount:      parseInt(row['TruckCount'] || 0, 10),
        total:           parseInt(row['Total']      || 0, 10),
        trafficSituation:(row['Traffic Situation'] || 'unknown').trim().toLowerCase(),
      };

      // Skip rows that are entirely empty or clearly malformed
      if (!record.time && !record.date) return;

      results.push(record);
    })
    .on('error', (err) => callback(err, null))
    .on('end',   ()    => callback(null, results));
}

// ── Helper: compute summary statistics ────────────────────
function computeStats(data) {
  if (!data || data.length === 0) {
    return {
      totalRecords:   0,
      totalVehicles:  0,
      avgVehicles:    0,
      peakRecord:     null,
      situationCounts:{ low: 0, normal: 0, high: 0, heavy: 0 },
    };
  }

  // Total vehicle count across all records
  const totalVehicles = data.reduce((sum, r) => sum + (r.total || 0), 0);

  // Average vehicles per record
  const avgVehicles = Math.round(totalVehicles / data.length);

  // Record with the highest vehicle total (peak traffic moment)
  const peakRecord = data.reduce(
    (max, r) => (r.total > (max ? max.total : -1) ? r : max),
    null
  );

  // Count how many records fall into each traffic situation
  const situationCounts = { low: 0, normal: 0, high: 0, heavy: 0 };
  data.forEach((r) => {
    const s = r.trafficSituation;
    if (s in situationCounts) situationCounts[s]++;
  });

  return {
    totalRecords: data.length,
    totalVehicles,
    avgVehicles,
    peakRecord,
    situationCounts,
  };
}

// ── Route: GET /  →  render the HTML dashboard ────────────
app.get('/', (req, res) => {
  readTrafficCSV((err, data) => {
    if (err) {
      console.error('Error reading CSV:', err.message);
      return res.status(500).send(`
        <h2>Error loading traffic data</h2>
        <p>${err.message}</p>
        <p>Make sure <strong>data/Traffic.csv</strong> exists inside the project folder.</p>
      `);
    }

    const stats   = computeStats(data);
    // Show the 50 most-recent records in the table (last rows of CSV)
    const recentRecords = data.slice(-50).reverse();

    res.render('index', { stats, recentRecords });
  });
});

// ── Route: GET /api/traffic  →  return raw JSON ───────────
app.get('/api/traffic', (req, res) => {
  readTrafficCSV((err, data) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ count: data.length, data });
  });
});

// ── Start server ──────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`Traffic Dashboard running at http://localhost:${PORT}`);
});