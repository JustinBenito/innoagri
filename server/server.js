const express = require('express');
const cors = require('cors');
const axios = require('axios');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(express.json());

// Store your API key in environment variables
const GEMINI_API_KEY = process.env.GEMINI_API_KEY; // Set this in your .env file
const GEMINI_API_URL = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent`;

// Chat endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const { message, language } = req.body;

    console.log('Received message:', message);
    console.log('API Key present:', !!GEMINI_API_KEY);
    console.log('API URL:', GEMINI_API_URL);

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    // Prepare the request to Gemini API
    const geminiRequest = {
      contents: [
        {
          parts: [
            {
              text: `${message}\n\nPlease respond only in Tamil, not in English.`
            }
          ]
        }
      ]
    };

    console.log('Sending request to Gemini API...');

    // Make request to Gemini API
    const response = await axios.post(GEMINI_API_URL, geminiRequest, {
      headers: {
        'x-goog-api-key': GEMINI_API_KEY,
        'content-type': 'application/json'
      }
    });

    console.log('Gemini API Response received successfully');

    // Extract response text
    const geminiResponse = response.data.candidates[0].content.parts[0].text ||
                          'பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';

    res.json({ response: geminiResponse });

  } catch (error) {
    console.error('Error calling Gemini API:', error.message);
    console.error('Full error:', error);

    // Handle different types of errors
    if (error.response) {
      // API returned an error status
      const status = error.response.status;
      const message = error.response.data?.error?.message || 'API Error';

      console.error('API Error Status:', status);
      console.error('API Error Response:', JSON.stringify(error.response.data, null, 2));

      res.status(status).json({
        error: `Gemini API Error: ${message}`,
        response: 'பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.'
      });
    } else {
      // Network or other error
      console.error('Network/Server Error:', error);
      res.status(500).json({
        error: 'Server Error',
        response: 'பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.'
      });
    }
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

// Export for serverless deployment (optional)
module.exports = app;