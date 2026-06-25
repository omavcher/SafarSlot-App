import jwt from 'jsonwebtoken'
const authMiddleware = (req,res,next) => {
     try{
         const authHeader = req.headers['authorization'];
         if(!authHeader || !authHeader.startsWith('Bearer ')){
             return res.status(401).json({message:"Unauthorized",success:false});
         }
         const token = authHeader.split(' ')[1];
         const decodedToken = jwt.verify(token,process.env.JWT_SECRET);
         if (!req.body) req.body = {};
         req.body.userId = decodedToken.userId;
         next();    
     }catch(error){
        return res.status(400).json({message:error.message,success:false});
     }
}


export default authMiddleware;