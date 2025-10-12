const express = require('express');
const http = require('http');

describe('Server Tests', () => {
    let server;
    const PORT = process.env.TEST_PORT || 3001;

    beforeAll((done) => {
        const app = express();
        app.get('/test', (req, res) => res.json({ status: 'ok' }));
        server = app.listen(PORT, () => done());
    });

    afterAll((done) => {
        if (server) server.close(done);
    });

    test('Server starts successfully', () => {
        expect(server.listening).toBe(true);
    });

    test('Test endpoint returns correct response', (done) => {
        http.get(`http://localhost:${PORT}/test`, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => {
                expect(JSON.parse(data)).toEqual({ status: 'ok' });
                done();
            });
        });
    });
});