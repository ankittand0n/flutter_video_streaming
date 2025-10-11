const mysql = require('mysql2/promise');
require('dotenv').config();

async function testDatabase() {
    let connection;
    try {
        // Test database connection
        console.log('Attempting to connect to database...');
        connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME
        });
        console.log('✅ Database connection successful!\n');

        // Test genres table
        console.log('Testing genres table...');
        const [genres] = await connection.execute('SELECT COUNT(*) as count FROM genres');
        console.log(`✅ Found ${genres[0].count} genres in the database\n`);

        // Test movies table
        console.log('Testing movies table...');
        const [movies] = await connection.execute('SELECT COUNT(*) as count FROM movies');
        console.log(`✅ Found ${movies[0].count} movies in the database\n`);

        // Test TV series table
        console.log('Testing tv_series table...');
        const [tvSeries] = await connection.execute('SELECT COUNT(*) as count FROM tv_series');
        console.log(`✅ Found ${tvSeries[0].count} TV series in the database\n`);

        // Test user creation
        console.log('Testing user functionality...');
        const [userResult] = await connection.execute(
            'INSERT INTO users (username, email, password_hash, profile_name, subscription_plan, subscription_status, is_active, email_verified) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            ['testuser_' + Date.now(), 'test_' + Date.now() + '@example.com', 'hashedpassword123', 'Test User', 'basic', 'active', 1, 0]
        );
        console.log('✅ User created successfully! User ID:', userResult.insertId);

        // Test watchlist functionality
        console.log('\nTesting watchlist functionality...');
        const [watchlistResult] = await connection.execute(
            'INSERT INTO watchlist (user_id, media_type, media_id, title, poster_path) VALUES (?, ?, ?, ?, ?)',
            [userResult.insertId, 'movie', 123, 'Test Movie', '/path/to/poster.jpg']
        );
        console.log('✅ Watchlist entry added successfully!');

        // Test ratings functionality
        console.log('\nTesting rating functionality...');
        const [ratingResult] = await connection.execute(
            'INSERT INTO ratings (user_id, media_type, media_id, rating) VALUES (?, ?, ?, ?)',
            [userResult.insertId, 'movie', 123, 8.5]
        );
        console.log('✅ Rating added successfully!');

        // Test data relationships
        console.log('\nTesting data relationships...');
        const [userWatchlist] = await connection.execute(`
            SELECT w.*, u.username 
            FROM watchlist w 
            JOIN users u ON w.user_id = u.id 
            WHERE u.id = ?
        `, [userResult.insertId]);
        console.log('✅ User-Watchlist relationship verified:', userWatchlist[0].username === 'testuser');

        // Cleanup test data
        console.log('\nCleaning up test data...');
        await connection.execute('DELETE FROM ratings WHERE user_id = ?', [userResult.insertId]);
        await connection.execute('DELETE FROM watchlist WHERE user_id = ?', [userResult.insertId]);
        await connection.execute('DELETE FROM users WHERE id = ?', [userResult.insertId]);
        console.log('✅ Test data cleaned up successfully!');

        console.log('\n🎉 All database tests completed successfully!');
        console.log('Database structure is working as expected.');

    } catch (error) {
        console.error('\n❌ Error during testing:', error.message);
        if (error.code === 'ER_NO_SUCH_TABLE') {
            console.error('Tables not found. Make sure you have run the database.sql script.');
        } else if (error.code === 'ECONNREFUSED') {
            console.error('Could not connect to MySQL. Make sure the server is running and credentials are correct.');
        }
    } finally {
        if (connection) {
            await connection.end();
            console.log('\nDatabase connection closed.');
        }
    }
}

// Run the tests
console.log('🧪 Starting Database Tests...\n');
testDatabase();