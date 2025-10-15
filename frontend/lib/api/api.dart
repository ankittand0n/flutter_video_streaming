// Legacy TMDB client disabled.
// All network requests should go through `ApiService` (backend) now.
// If this file is imported anywhere, it will throw at runtime to prevent accidental external API calls.

Never useLegacyTMDBClient() {
  throw UnsupportedError('Legacy TMDB client disabled. Use ApiService instead.');
}
