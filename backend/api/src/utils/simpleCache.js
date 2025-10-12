// Simple in-memory cache with TTL
const store = new Map();

function set(key, value, ttlMs = 300000) { // default 5 minutes
  const expireAt = Date.now() + ttlMs;
  store.set(key, { value, expireAt });
}

function get(key) {
  const entry = store.get(key);
  if (!entry) return null;
  if (Date.now() > entry.expireAt) {
    store.delete(key);
    return null;
  }
  return entry.value;
}

function del(key) {
  store.delete(key);
}

module.exports = { set, get, del };
