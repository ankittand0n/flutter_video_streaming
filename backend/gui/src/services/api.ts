const BASE = 'http://localhost:3000/api'

function getHeaders(token?: string) {
  const headers: Record<string,string> = { 'Content-Type': 'application/json' }
  if (token) headers['Authorization'] = `Bearer ${token}`
  return headers
}

export async function fetchMovies(query: string = '') {
  const url = `${BASE}/movies${query ? `?search=${encodeURIComponent(query)}` : ''}`
  const res = await fetch(url)
  return res.json()
}

export async function fetchGenres() {
  const res = await fetch(`${BASE}/genres`)
  return res.json()
}

export async function addToWatchlist(token: string, body: any) {
  const res = await fetch(`${BASE}/watchlist`, {
    method: 'POST',
    headers: getHeaders(token),
    body: JSON.stringify(body)
  })
  return res.json()
}

export async function postRating(token: string, body: any) {
  const res = await fetch(`${BASE}/rating`, {
    method: 'POST',
    headers: getHeaders(token),
    body: JSON.stringify(body)
  })
  return res.json()
}

export async function login(emailOrUsername: string, password: string) {
  const isEmail = emailOrUsername.includes('@');
  const body = isEmail 
    ? { email: emailOrUsername, password }
    : { username: emailOrUsername, password };

  const res = await fetch(`${BASE}/auth/login`, {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify(body)
  })
  return res.json()
}

export async function signup(data: any) {
  const res = await fetch(`${BASE}/auth/register`, {
    method: 'POST',
    headers: getHeaders(),
    body: JSON.stringify(data)
  })
  return res.json()
}

export default { fetchMovies, fetchGenres, addToWatchlist, postRating, login, signup }
