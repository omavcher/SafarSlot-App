import './shim.js';
import express from 'express';
import env from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import connectDB from './config/connectDB.js';
import helmet from 'helmet'

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
env.config();
connectDB();
const app = express();
app.use(helmet()); 
app.use(express.json());

import userRouter from './routes/user.route.js';
import trainRouter from './routes/train.route.js'
app.use('/api/v1/user',userRouter);
app.use('/api/v1/train',trainRouter);

app.get('/',(req,res)=>{
    res.send('Welcome to Safar Slot');
})

app.listen(process.env.PORT, () => {
    console.log(`Server is running on port ${process.env.PORT}`);
});
