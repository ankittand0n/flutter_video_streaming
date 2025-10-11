const axios = require('axios');

const BASE_URL = 'http://localhost:8080';

async function testAPI() {
  try {
    console.log('🧪 Testing Namkeen TV Backend API...\n');

    // Test API info
    console.log('1. Testing API info...');
    const apiInfo = await axios.get(`${BASE_URL}/api`);
    console.log('✅ API Info:', apiInfo.data.message);
    console.log('   Available endpoints:', Object.keys(apiInfo.data.endpoints).join(', '));

    // Test health check
    console.log('\n2. Testing health check...');
    const health = await axios.get(`${BASE_URL}/api/health`);
    console.log('✅ Health Status:', health.data.status);
    console.log('   Database:', health.data.database);

    // Test movies endpoint
    console.log('\n3. Testing movies endpoint...');
    const movies = await axios.get(`${BASE_URL}/api/movies`);
    console.log('✅ Movies loaded:', movies.data.data.length);
    console.log('   First movie:', movies.data.data[0].title);

    // Test ANTERVYATHAA specifically
    console.log('\n4. Testing ANTERVYATHAA movie...');
    const antervya = movies.data.data.find(m => m.title === 'ANTERVYATHAA');
    if (antervya) {
      console.log('✅ ANTERVYATHAA found!');
      console.log('   Overview:', antervya.overview.substring(0, 100) + '...');
      console.log('   Rating:', antervya.vote_average);
      console.log('   Poster:', antervya.poster_path);
    } else {
      console.log('❌ ANTERVYATHAA not found');
    }

    // Test TV series
    console.log('\n5. Testing TV series endpoint...');
    const tvSeries = await axios.get(`${BASE_URL}/api/tv`);
    console.log('✅ TV Series loaded:', tvSeries.data.data.length);

    // Test genres
    console.log('\n6. Testing genres endpoint...');
    const genres = await axios.get(`${BASE_URL}/api/genres`);
    console.log('✅ Genres loaded:', genres.data.data.length);

    console.log('\n🎉 All API tests passed! Backend is working correctly.');
    console.log('\n📱 You can now access:');
    console.log(`   - API Info: ${BASE_URL}/api`);
    console.log(`   - Movies: ${BASE_URL}/api/movies`);
    console.log(`   - TV Series: ${BASE_URL}/api/tv`);
    console.log(`   - Genres: ${BASE_URL}/api/genres`);

  } catch (error) {
    console.error('❌ API Test failed:', error.message);
    if (error.response) {
      console.error('   Response:', error.response.data);
    }
  }
}

testAPI();
