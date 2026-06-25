import axios from 'axios';
async function test() {
  try {
    const locRes = await axios.post('http://localhost:8080/api/v1/user/log-in', {
      phone: "1234567890",
      otp: "123456" // wait, login uses OTP?
    });
    console.log(locRes.data);
  } catch (e) {
    console.log(e.response ? e.response.data : e.message);
  }
}
test();
