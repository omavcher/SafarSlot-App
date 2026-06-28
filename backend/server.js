import './shim.js';
import express from 'express';
import http from 'http';
import env from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import cron from 'node-cron';
import connectDB from './config/connectDB.js';
import { connectRedis } from './config/redis.js';
import { runWarmCache } from './jobs/warmCache.js';
import { attachLiveTrainSocket } from './ws/liveTrainSocket.js';
import helmet from 'helmet';
import compression from 'compression';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
env.config();
connectDB();
await connectRedis();

const app = express();
app.use(compression());
app.use(helmet()); 
app.use(express.json());

import userRouter from './routes/user.route.js';
import trainRouter from './routes/train.route.js';
app.use('/api/v1/user', userRouter);
app.use('/api/v1/train', trainRouter);

app.get('/', (req, res) => {
  res.send('Welcome to Safar Slot');
});

const server = http.createServer(app);
attachLiveTrainSocket(server);

// Warm cache daily at 6:00 AM IST
cron.schedule('30 0 * * *', () => {
  runWarmCache().catch((err) => console.error('[WarmCache] Cron error:', err.message));
}, { timezone: 'Asia/Kolkata' });

// Warm cache on startup (non-blocking)
runWarmCache().catch((err) => console.warn('[WarmCache] Startup warm skipped:', err.message));

server.listen(process.env.PORT, () => {
  console.log(`Server is running on port ${process.env.PORT}`);
});
