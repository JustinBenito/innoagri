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
const CLAUDE_API_KEY = process.env.CLAUDE_API_KEY; // Set this in your .env file
const CLAUDE_API_URL = 'https://api.anthropic.com/v1/messages';

// Chat endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const { message, language } = req.body;

    if (!message) {
      return res.status(400).json({ error: 'Message is required' });
    }

    // Prepare the request to Claude API
    const claudeRequest = {
      model: 'claude-3-haiku-20240307',
      max_tokens: 512,
      messages: [
        {
          role: 'user',
          content: `${message}\n\nPlease respond only in Tamil, not in English.`
        }
      ]
    };

    // Make request to Claude API
    const response = await axios.post(CLAUDE_API_URL, claudeRequest, {
      headers: {
        'x-api-key': CLAUDE_API_KEY,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json'
      }
    });

    // Extract response text
    const claudeResponse = response.data.content[0].text || 
                          'பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';

    res.json({ response: claudeResponse });

  } catch (error) {
    console.error('Error calling Claude API:', error.message);
    
    // Handle different types of errors
    if (error.response) {
      // API returned an error status
      const status = error.response.status;
      const message = error.response.data?.error?.message || 'API Error';
      
      res.status(status).json({ 
        error: `Claude API Error: ${message}`,
        response: 'பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.' 
      });
    } else {
      // Network or other error
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