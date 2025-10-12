import React, { useEffect, useState } from 'react'
import Header from './ui/Header'
import Card from './ui/Card'
import Controls from './ui/Controls'
import Login from './ui/Login'
import MovieForm from './ui/MovieForm'
import TVSeriesForm from './ui/TVSeriesForm'
import api from './services/api'

const App: React.FC = () => {
  const [movies, setMovies] = useState<any[]>([])
  const [tvSeries, setTVSeries] = useState<any[]>([])
  const [genres, setGenres] = useState<any[]>([])
  const [query, setQuery] = useState('')
  const [activeTab, setActiveTab] = useState<'movies' | 'tv'>('movies')
  const [token, setToken] = useState<string | undefined>(() => {
    try { return localStorage.getItem('jwt') ?? undefined } catch { return undefined }
  })
  const [showMovieForm, setShowMovieForm] = useState(false)
  const [showTVForm, setShowTVForm] = useState(false)
  const [editingMovie, setEditingMovie] = useState<any>(null)
  const [editingTVSeries, setEditingTVSeries] = useState<any>(null)

  useEffect(() => {
    load()
  }, [])

  async function load() {
    try {
      const gm = await api.fetchGenres()
      if (gm && gm.data) setGenres(gm.data)

      const mv = await api.fetchMovies()
      if (mv && mv.data) setMovies(mv.data)

      const tv = await api.fetchTVSeries()
      if (tv && tv.data) setTVSeries(tv.data)
    } catch (e) {
      console.error('Load error', e)
    }
  }

  async function doSearch(q: string) {
    setQuery(q)
    try {
      if (activeTab === 'movies') {
        const mv = await api.fetchMovies(q)
        if (mv && mv.data) setMovies(mv.data)
      } else {
        const tv = await api.fetchTVSeries(q)
        if (tv && tv.data) setTVSeries(tv.data)
      }
    } catch (e) {
      console.error('Search error', e)
    }
  }

  function handleLogin(tokenVal: string) {
    setToken(tokenVal)
    try { localStorage.setItem('jwt', tokenVal) } catch {}
  }

  function handleSignout() {
    setToken(undefined)
    try { localStorage.removeItem('jwt') } catch {}
  }

  function handleAddMovie() {
    setEditingMovie(null)
    setShowMovieForm(true)
  }

  function handleEditMovie(movie: any) {
    setEditingMovie(movie)
    setShowMovieForm(true)
  }

  function handleAddTVSeries() {
    setEditingTVSeries(null)
    setShowTVForm(true)
  }

  function handleEditTVSeries(tvSeries: any) {
    setEditingTVSeries(tvSeries)
    setShowTVForm(true)
  }

  function handleFormSuccess() {
    setShowMovieForm(false)
    setShowTVForm(false)
    setEditingMovie(null)
    setEditingTVSeries(null)
    load() // Reload data
  }

  function handleFormCancel() {
    setShowMovieForm(false)
    setShowTVForm(false)
    setEditingMovie(null)
    setEditingTVSeries(null)
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
            {/* Navigation Tabs */}
            <div className="flex justify-between items-center mb-6">
              <div className="flex space-x-4">
                <button
                  onClick={() => setActiveTab('movies')}
                  className={`px-4 py-2 rounded-lg font-medium ${
                    activeTab === 'movies'
                      ? 'bg-red-600 text-white'
                      : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                  }`}
                >
                  Movies
                </button>
                <button
                  onClick={() => setActiveTab('tv')}
                  className={`px-4 py-2 rounded-lg font-medium ${
                    activeTab === 'tv'
                      ? 'bg-red-600 text-white'
                      : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
                  }`}
                >
                  TV Series
                </button>
              </div>

              <button
                onClick={activeTab === 'movies' ? handleAddMovie : handleAddTVSeries}
                className="px-4 py-2 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700"
              >
                Add {activeTab === 'movies' ? 'Movie' : 'TV Series'}
              </button>
            </div>

            <h2 className="text-2xl mb-4">
              {activeTab === 'movies' ? 'Featured Movies' : 'Featured TV Series'}
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {(activeTab === 'movies' ? movies : tvSeries).map(item => (
                <Card
                  key={item.id}
                  title={item.title || item.name}
                  description={item.overview}
                  content={item}
                  token={token}
                  contentType={activeTab === 'movies' ? 'movie' : 'tv'}
                  onEdit={activeTab === 'movies' ? handleEditMovie : handleEditTVSeries}
                />
              ))}
            </div>
          </main>
        </>
      )}

      {showMovieForm && (
        <MovieForm
          movie={editingMovie}
          onSuccess={handleFormSuccess}
          onCancel={handleFormCancel}
        />
      )}

      {showTVForm && (
        <TVSeriesForm
          tvSeries={editingTVSeries}
          onSuccess={handleFormSuccess}
          onCancel={handleFormCancel}
        />
      )}
    </div>
  )
}

export default App
