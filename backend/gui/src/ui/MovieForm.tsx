import React, { useState } from 'react'
import api from '../services/api'

interface MovieFormProps {
  movie?: any
  onSuccess: () => void
  onCancel: () => void
}

const MovieForm: React.FC<MovieFormProps> = ({ movie, onSuccess, onCancel }) => {
  const [formData, setFormData] = useState({
    title: movie?.title || '',
    overview: movie?.overview || '',
    release_date: movie?.release_date ? new Date(movie.release_date).toISOString().split('T')[0] : '',
    vote_average: movie?.vote_average || '',
    genre_ids: movie?.genre_ids ? JSON.parse(movie.genre_ids).join(', ') : '',
    video_url: movie?.video_url || '',
    trailer_url: movie?.trailer_url || ''
  })
  const [loading, setLoading] = useState(false)
  const [posterFile, setPosterFile] = useState<File | null>(null)
  const [backdropFile, setBackdropFile] = useState<File | null>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const submitData = new FormData()
      submitData.append('title', formData.title)
      submitData.append('overview', formData.overview)
      submitData.append('release_date', formData.release_date)
      submitData.append('vote_average', formData.vote_average ? parseFloat(formData.vote_average) : '')
      submitData.append('genre_ids', JSON.stringify(formData.genre_ids.split(',').map(g => g.trim())))
      submitData.append('video_url', formData.video_url)
      submitData.append('trailer_url', formData.trailer_url)

      if (posterFile) submitData.append('poster', posterFile)
      if (backdropFile) submitData.append('backdrop', backdropFile)

      const token = localStorage.getItem('jwt')
      if (!token) {
        alert('Please login first')
        return
      }

      const headers: Record<string,string> = { 'Authorization': `Bearer ${token}` }

      if (movie) {
        // Update existing movie
        const response = await fetch(`${import.meta.env.VITE_API_URL}/movies/${movie.id}`, {
          method: 'PUT',
          headers,
          body: submitData
        })
        const result = await response.json()
        if (result.success) {
          alert('Movie updated successfully!')
          onSuccess()
        } else {
          alert('Failed to update movie: ' + JSON.stringify(result))
        }
      } else {
        // Create new movie
        const response = await fetch(`${import.meta.env.VITE_API_URL}/movies`, {
          method: 'POST',
          headers,
          body: submitData
        })
        const result = await response.json()
        if (result.success) {
          alert('Movie created successfully!')
          onSuccess()
        } else {
          alert('Failed to create movie: ' + JSON.stringify(result))
        }
      }
    } catch (error) {
      console.error('Submit error:', error)
      alert('Failed to save movie')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
      <div className="bg-gray-800 rounded-lg p-6 w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <h2 className="text-2xl font-bold mb-4 text-white">
          {movie ? 'Edit Movie' : 'Add New Movie'}
        </h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">Title *</label>
            <input
              type="text"
              required
              value={formData.title}
              onChange={(e) => setFormData({...formData, title: e.target.value})}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">Overview</label>
            <textarea
              value={formData.overview}
              onChange={(e) => setFormData({...formData, overview: e.target.value})}
              rows={3}
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">Release Date</label>
              <input
                type="date"
                value={formData.release_date}
                onChange={(e) => setFormData({...formData, release_date: e.target.value})}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">Vote Average</label>
              <input
                type="number"
                step="0.1"
                min="0"
                max="10"
                value={formData.vote_average}
                onChange={(e) => setFormData({...formData, vote_average: e.target.value})}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-300 mb-1">Genres (comma-separated)</label>
            <input
              type="text"
              value={formData.genre_ids}
              onChange={(e) => setFormData({...formData, genre_ids: e.target.value})}
              placeholder="Action, Adventure, Comedy"
              className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">Video URL</label>
              <input
                type="url"
                value={formData.video_url}
                onChange={(e) => setFormData({...formData, video_url: e.target.value})}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">Trailer URL</label>
              <input
                type="url"
                value={formData.trailer_url}
                onChange={(e) => setFormData({...formData, trailer_url: e.target.value})}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white"
              />
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">Poster Image</label>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => setPosterFile(e.target.files?.[0] || null)}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-1 file:px-3 file:rounded file:border-0 file:text-sm file:font-medium file:bg-red-600 file:text-white hover:file:bg-red-700"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-300 mb-1">Backdrop Image</label>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => setBackdropFile(e.target.files?.[0] || null)}
                className="w-full px-3 py-2 bg-gray-700 border border-gray-600 rounded-md text-white file:mr-4 file:py-1 file:px-3 file:rounded file:border-0 file:text-sm file:font-medium file:bg-red-600 file:text-white hover:file:bg-red-700"
              />
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={onCancel}
              className="px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 disabled:opacity-50"
            >
              {loading ? 'Saving...' : (movie ? 'Update Movie' : 'Create Movie')}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

export default MovieForm