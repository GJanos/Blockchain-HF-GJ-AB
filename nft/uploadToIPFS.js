const axios = require('axios')
const FormData = require('form-data')
const fs = require('fs')
require('dotenv').config({ path: '.env' });
const JWT = process.env.JWT;

const pinFileToIPFS = async () => {
    const formData = new FormData();
    const src = "nft/metadata5.json";
    //const src = "nft/5.png";
    
    const file = fs.createReadStream(src)
    formData.append('file', file)
    
    const pinataMetadata = JSON.stringify({
      name: 'Red',
    });
    formData.append('pinataMetadata', pinataMetadata);
    
    const pinataOptions = JSON.stringify({
      cidVersion: 0,
    })
    formData.append('pinataOptions', pinataOptions);

    try{
      const res = await axios.post("https://api.pinata.cloud/pinning/pinFileToIPFS", formData, {
        maxBodyLength: "Infinity",
        headers: {
          'Content-Type': `multipart/form-data; boundary=${formData._boundary}`,
          'Authorization': `Bearer ${JWT}`
        }
      });
      console.log("https://ipfs.io/ipfs/"+res.data.IpfsHash);
    } catch (error) {
      console.log(error);
    }
}
pinFileToIPFS()

