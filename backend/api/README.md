# Netflix Backend API

Node.js/Express API for Netflix clone with authentication, TMDB integration, and user management.

## Docker Setup

### Prerequisites
- Docker and Docker Compose installed
- Update environment variables in `.env` or `docker-compose.yml`

### Quick Start

1. **Clone and navigate to the API directory:**
   ```bash
   cd backend/api
   ```

2. **Update environment variables:**
   - Copy `.env.example` to `.env`
   - Update database credentials and secrets

3. **Build and run with Docker Compose:**
   ```bash
   # Build and start services
   docker-compose up --build

   # Or run in background
   docker-compose up -d --build
   ```

4. **Check logs:**
   ```bash
   docker-compose logs -f api
   ```

5. **Stop services:**
   ```bash
   docker-compose down
   ```

### Manual Docker Build

```bash
# Build the image
docker build -t netflix-backend .

# Run the container
docker run -p 3000:3000 \
  -e DATABASE_URL="your-database-url" \
  -e JWT_SECRET="your-jwt-secret" \
  netflix-backend
```

### Environment Variables

Key variables to configure:
- `DATABASE_URL`: Database connection string
- `JWT_SECRET`: JWT signing secret
- `TMDB_API_KEY`: TMDB API key
- `NODE_ENV`: Environment (development/production)

### Database Setup

The Docker Compose includes a PostgreSQL database. For production, update the database configuration to use your Supabase or other PostgreSQL instance.

### Health Checks

The API includes health check endpoints:
- `GET /health` - Basic health check
- `GET /` - API info

### Development

For development with hot reload:
```bash
# Install dependencies locally
npm install

# Run with nodemon
npm run dev
```

### Production Deployment

For production deployment:
1. Update environment variables for production
2. Use a reverse proxy (nginx) in front of the container
3. Configure proper logging and monitoring
4. Set up database backups

### Troubleshooting

- **Port conflicts**: Change port mapping in `docker-compose.yml`
- **Database connection**: Ensure database is running and credentials are correct
- **Prisma issues**: Run `npx prisma generate` if client generation fails