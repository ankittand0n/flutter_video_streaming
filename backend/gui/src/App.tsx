import React, { useEffect, useState } from 'react'
import Header from './ui/Header'
import Card from './ui/Card'
import Controls from './ui/Controls'
import Login from './ui/Login'
import api from './services/api'

const App: React.FC = () => {
  const [movies, setMovies] = useState<any[]>([])
  const [genres, setGenres] = useState<any[]>([])
  const [query, setQuery] = useState('')
  const [token, setToken] = useState<string | undefined>(() => {
    try { return localStorage.getItem('jwt') ?? undefined } catch { return undefined }
  })

  useEffect(() => {
    load()
  }, [])

  async function load() {
    try {
      const gm = await api.fetchGenres()
      if (gm && gm.data) setGenres(gm.data)

      const mv = await api.fetchMovies()
      if (mv && mv.data) setMovies(mv.data)
    } catch (e) {
      console.error('Load error', e)
    }
  }

  async function doSearch(q: string) {
    setQuery(q)
    const mv = await api.fetchMovies(q)
    if (mv && mv.data) setMovies(mv.data)
  }

  function handleLogin(tokenVal: string) {
    setToken(tokenVal)
    try { localStorage.setItem('jwt', tokenVal) } catch {}
  }

  function handleSignout() {
    setToken(undefined)
    try { localStorage.removeItem('jwt') } catch {}
  }

  return (
    <div className="min-h-screen bg-black text-white">
      <Header token={token} onToken={setToken} onSignout={handleSignout} />
      {!token ? (
        <main className="p-6 pt-6">
          <Login onSuccess={handleLogin} />
        </main>
      ) : (
        <>
          <Controls onSearch={doSearch} genres={genres} />

          <main className="p-6 pt-6">
            <h2 className="text-2xl mb-4">Featured</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {movies.map(m => (
                <Card key={m.id} title={m.title} description={m.overview} movie={m} token={token} />
              ))}
            </div>
          </main>
        </>
      )}
    </div>
  )
}

export default App
