import axios from "axios"

export const getPNR = async (req,res)=>{
    try{
        const {pnr}=req.body;
        if (pnr.length !== 10) {
  return res.status(400).json({
    success: false,
    message: "Please Provide Correct PNR",
  });
}
        const URL = `https://cttrainsapi.confirmtkt.com/api/v2/ctpro/mweb/${pnr}?querysource=ct-mweb&locale=en&getHighChanceText=true&livePnr=false`
       const response = await axios.post(URL, { proPlanName: "" });
       const pnrDetails = response.data?.data?.pnrResponse || response.data;
       res.status(200).json({
        success:true,
        message:"PNR Status Fetched Successfully",
        data: pnrDetails
       });
    }catch(error){
        console.error("Get PNR Error", error.message);
        res.status(500).json({success:false,message:error.message})
    }
}

export const stationsList = async (req,res)=>{
  try{
       const search = req.params.search;
       if (!search) {
         return res.status(400).json({ success: false, message: "Search query is required" });
       }
       const URL = `https://www.redbus.in/rails/api/solarSearch?search=${search}`;
       const response = await axios.get(URL);
       const resData = response.data.response;
       res.status(200).json({success:true,resData});
  }catch(err){
    const apiError = err.response?.data || err.message;
    console.error("Station List Error", apiError);
    const statusCode = err.response?.status || 500;
    const message = err.response?.data?.error?.message || err.message || "Station service error";
    res.status(statusCode === 500 ? 502 : statusCode).json({success:false,message});
  }
}

export const getTrainNameCode = async (req,res)=>{
    try{
          const search = req.params.search;
       if (!search) {
         return res.status(400).json({ success: false, message: "Search query is required" });
       }
        const URL = `https://www.redbus.in/railways/api/SolrTrainSearch?search=${search}`

        const response = await axios.get(URL);
        const resData = response.data.response;
        res.status(200).json({success:true,resData});

    }catch(err){
        res.status(500).json({success:false,message:err.message})
    }
}



export const liveTrainStatus = async (req,res)=>{
   try {
    const {trainNo} = req.body;
    if (!search) {
         return res.status(400).json({ success: false, message: "Search train no is required" });
       }

    const URL = `https://www.redbus.in/railways/api/getLtsDetails?trainNo=${trainNo}`;
    const response = await axios.get(URL);
    const resData = response.data;
    res.status(200).json({success:true,resData});
   } catch (error) {
            res.status(500).json({success:false,message:err.message})
   }
}



// export const CreateSavedRoutes

// export const getSavedRoutes


export const CoachPosition = async (req,res) =>{
    try {
      const {trainNo,station} = req.body;
      const URL = `https://www.redbus.in/railways/api/getCoachPosition?trainNo=${trainNo}&stn=${station}`
    const response = await axios.get(URL);
    const resData = response.data;
    res.status(200).json({success:true,resData});
   } catch (error) {
            res.status(500).json({success:false,message:err.message})
   }
}


