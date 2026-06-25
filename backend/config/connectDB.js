import mongoose from "mongoose";

const connectDB = async ()=>{
    try{
         await mongoose.connect(process.env.DB_LINK);
         console.log('MONGODB connected');
    }catch(err){
        console.log(`MONGODB ERROR: ${err}`);
    }
}

export default connectDB;