const express = require('express');
const app = express();
const PORT = 3001;

// Basic route to test
app.get('/', (req, res) => {
    res.json({ message: 'Test server running' });
});

// Error handler
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    process.exit(1);
});

// Start server with retry mechanism
const startServer = (port) => {
    try {
        const server = app.listen(port, () => {
            console.log(`Test server running on port ${port}`);
        }).on('error', (error) => {
            console.error(`Failed to start on port ${port}:`, error.message);
            if (error.code === 'EADDRINUSE') {
                console.log('Trying next port...');
                startServer(port + 1);
            }
        });
    } catch (error) {
        console.error('Server start error:', error);
    }
};

console.log('Attempting to start test server...');
startServer(PORT);