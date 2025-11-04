import React, { useState } from 'react'

interface Season {
  season_number: number
  episode_count: number
  name: string
  overview: string
  air_date: string
}

interface TVSeriesFormProps {
  tvSeries?: any
  onSuccess: () => void
  onCancel: () => void
}

const TVSeriesForm: React.FC<TVSeriesFormProps> = ({ tvSeries, onSuccess, onCancel }) => {
  // Initialize trailer_urls from either the new array or old single trailer
  const initialTrailers = tvSeries?.trailer_urls && tvSeries.trailer_urls.length > 0 
    ? tvSeries.trailer_urls 
    : tvSeries?.trailer_url 
      ? [tvSeries.trailer_url]
      : ['']

  const [formData, setFormData] = useState({
    name: tvSeries?.name || '',
    overview: tvSeries?.overview || '',
    first_air_date: tvSeries?.first_air_date ? new Date(tvSeries.first_air_date).toISOString().split('T')[0] : '',
    vote_average: tvSeries?.vote_average || '',
    genre_ids: tvSeries?.genre_ids ? JSON.parse(tvSeries.genre_ids).join(', ') : '',
    number_of_seasons: tvSeries?.number_of_seasons || '',
    number_of_episodes: tvSeries?.number_of_episodes || '',
    status: tvSeries?.status || 'Ended',
    video_url: tvSeries?.video_url || ''
  })

  const [trailerUrls, setTrailerUrls] = useState<string[]>(initialTrailers)
  const [seasons, setSeasons] = useState<Season[]>(
    tvSeries?.seasons ? JSON.parse(tvSeries.seasons) : []
  )

  const [loading, setLoading] = useState(false)
  const [posterFile, setPosterFile] = useState<File | null>(null)
  const [backdropFile, setBackdropFile] = useState<File | null>(null)

  const addSeason = () => {
    const newSeason: Season = {
      season_number: seasons.length + 1,
      episode_count: 1,
      name: `Season ${seasons.length + 1}`,
      overview: '',
      air_date: ''
    }
    setSeasons([...seasons, newSeason])
  }

  const updateSeason = (index: number, field: keyof Season, value: string | number) => {
    const updatedSeasons = [...seasons]
    updatedSeasons[index] = { ...updatedSeasons[index], [field]: value }
    setSeasons(updatedSeasons)
  }

  const removeSeason = (index: number) => {
    setSeasons(seasons.filter((_, i) => i !== index))
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      const submitData = new FormData()
      submitData.append('name', formData.name)
      submitData.append('overview', formData.overview)
      submitData.append('first_air_date', formData.first_air_date)
      submitData.append('vote_average', formData.vote_average ? formData.vote_average.toString() : '')
      submitData.append('genre_ids', JSON.stringify(formData.genre_ids.split(',').map((g: string) => g.trim())))
      submitData.append('number_of_seasons', formData.number_of_seasons)
      submitData.append('number_of_episodes', formData.number_of_episodes)
      submitData.append('status', formData.status)
      submitData.append('video_url', formData.video_url)
      
      // Send trailer_urls as JSON array, filtering out empty strings
      const validTrailers = trailerUrls.filter(url => url.trim() !== '')
      submitData.append('trailer_urls', JSON.stringify(validTrailers))
      
      submitData.append('seasons', JSON.stringify(seasons))

      if (posterFile) submitData.append('poster', posterFile)
      if (backdropFile) submitData.append('backdrop', backdropFile)

      const token = localStorage.getItem('jwt')
      if (!token) {
        alert('Please login first')
        return
      }

      const headers: Record<string,string> = { 'Authorization': `Bearer ${token}` }

      if (tvSeries) {
        // Update existing TV series
        const response = await fetch(`/api/tv/${tvSeries.id}`, {
          method: 'PUT',
          headers,
          body: submitData
        })
        const result = await response.json()
        if (result.success) {
          alert('TV Series updated successfully!')
          onSuccess()
        } else {
          alert('Failed to update TV series: ' + JSON.stringify(result))
        }
      } else {
        // Create new TV series
        const response = await fetch(`/api/tv`, {
          method: 'POST',
          headers,
          body: submitData
        })
        const result = await response.json()
        if (result.success) {
          alert('TV Series created successfully!')
          onSuccess()
        } else {
          alert('Failed to create TV series: ' + JSON.stringify(result))
        }
      }
    } catch (error) {
      console.error('Submit error:', error)
      alert('Failed to save TV series')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4">
      <div className="bg-card rounded-lg p-6 w-full max-w-4xl max-h-[90vh] overflow-y-auto border border-accent-secondary/20">
        <h2 className="text-2xl font-bold mb-4 text-foreground">
          {tvSeries ? 'Edit TV Series' : 'Add New TV Series'}
        </h2>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-muted mb-1">Name *</label>
            <input
              type="text"
              required
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
            />
          </div>

            <div>
              <label className="block text-sm font-medium text-muted mb-1">Overview</label>
              <textarea
                value={formData.overview}
                onChange={(e) => setFormData({...formData, overview: e.target.value})}
                rows={3}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors resize-vertical"
              />
            </div>          <div className="grid grid-cols-3 gap-4">
            <div>
              <label className="block text-sm font-medium text-muted mb-1">First Air Date</label>
              <input
                type="date"
                value={formData.first_air_date}
                onChange={(e) => setFormData({...formData, first_air_date: e.target.value})}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-muted mb-1">Vote Average</label>
              <input
                type="number"
                step="0.1"
                min="0"
                max="10"
                value={formData.vote_average}
                onChange={(e) => setFormData({...formData, vote_average: e.target.value})}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-muted mb-1">Status</label>
              <select
                value={formData.status}
                onChange={(e) => setFormData({...formData, status: e.target.value})}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
              >
                <option value="Ended">Ended</option>
                <option value="Returning Series">Returning Series</option>
                <option value="Canceled">Canceled</option>
                <option value="In Production">In Production</option>
              </select>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-muted mb-1">Number of Seasons</label>
              <input
                type="number"
                min="1"
                value={formData.number_of_seasons}
                onChange={(e) => setFormData({...formData, number_of_seasons: e.target.value})}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-muted mb-1">Number of Episodes</label>
              <input
                type="number"
                min="1"
                value={formData.number_of_episodes}
                onChange={(e) => setFormData({...formData, number_of_episodes: e.target.value})}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-medium text-muted mb-1">Genres (comma-separated)</label>
            <input
              type="text"
              value={formData.genre_ids}
              onChange={(e) => setFormData({...formData, genre_ids: e.target.value})}
              placeholder="Drama, Mystery, Thriller"
              className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-muted mb-1">Video URL</label>
            <input
              type="url"
              value={formData.video_url}
              onChange={(e) => setFormData({...formData, video_url: e.target.value})}
              className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
            />
          </div>

          <div>
            <label className="block text-sm font-medium text-muted mb-1">
              Trailer URLs (Multiple trailers will be played randomly)
            </label>
            <div className="space-y-2">
              {trailerUrls.map((url, index) => (
                <div key={index} className="flex gap-2">
                  <input
                    type="url"
                    value={url}
                    onChange={(e) => {
                      const newTrailers = [...trailerUrls]
                      newTrailers[index] = e.target.value
                      setTrailerUrls(newTrailers)
                    }}
                    placeholder={`Trailer ${index + 1} URL`}
                    className="flex-1 px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
                  />
                  {trailerUrls.length > 1 && (
                    <button
                      type="button"
                      onClick={() => setTrailerUrls(trailerUrls.filter((_, i) => i !== index))}
                      className="px-3 py-2 bg-red-500/10 text-red-500 border border-red-500/30 rounded-lg hover:bg-red-500/20 transition-colors"
                    >
                      Remove
                    </button>
                  )}
                </div>
              ))}
              <button
                type="button"
                onClick={() => setTrailerUrls([...trailerUrls, ''])}
                className="px-4 py-2 bg-accent/10 text-accent border border-accent/30 rounded-lg hover:bg-accent/20 transition-colors text-sm"
              >
                + Add Another Trailer
              </button>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-muted mb-1">Poster Image</label>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => setPosterFile(e.target.files?.[0] || null)}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors file:mr-4 file:py-1 file:px-3 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-accent file:text-white hover:file:bg-accent-secondary"
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-muted mb-1">Backdrop Image</label>
              <input
                type="file"
                accept="image/*"
                onChange={(e) => setBackdropFile(e.target.files?.[0] || null)}
                className="w-full px-3 py-2 bg-background-2 border border-accent-secondary rounded-lg text-foreground focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors file:mr-4 file:py-1 file:px-3 file:rounded-lg file:border-0 file:text-sm file:font-medium file:bg-accent file:text-white hover:file:bg-accent-secondary"
              />
            </div>
          </div>

          {/* Seasons Section */}
          <div className="border-t border-accent-secondary pt-4">
            <div className="flex justify-between items-center mb-4">
              <h3 className="text-lg font-semibold text-foreground">Seasons</h3>
              <button
                type="button"
                onClick={addSeason}
                className="px-3 py-1 bg-accent text-white rounded-lg hover:bg-accent-secondary transition-colors text-sm font-medium"
              >
                Add Season
              </button>
            </div>

            <div className="space-y-3">
              {seasons.map((season, index) => (
                <div key={index} className="bg-background-2 p-4 rounded-lg">
                  <div className="flex justify-between items-start mb-3">
                    <h4 className="text-foreground font-medium">Season {season.season_number}</h4>
                    <button
                      type="button"
                      onClick={() => removeSeason(index)}
                      className="text-red-400 hover:text-red-300 text-sm"
                    >
                      Remove
                    </button>
                  </div>

                  <div className="grid grid-cols-2 gap-3">
                    <div>
                      <label className="block text-sm font-medium text-muted mb-1">Season Name</label>
                      <input
                        type="text"
                        value={season.name}
                        onChange={(e) => updateSeason(index, 'name', e.target.value)}
                        className="w-full px-2 py-1 bg-card border border-accent-secondary rounded-lg text-foreground text-sm focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-muted mb-1">Episode Count</label>
                      <input
                        type="number"
                        min="1"
                        value={season.episode_count}
                        onChange={(e) => updateSeason(index, 'episode_count', parseInt(e.target.value))}
                        className="w-full px-2 py-1 bg-card border border-accent-secondary rounded-lg text-foreground text-sm focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-muted mb-1">Air Date</label>
                      <input
                        type="date"
                        value={season.air_date}
                        onChange={(e) => updateSeason(index, 'air_date', e.target.value)}
                        className="w-full px-2 py-1 bg-card border border-accent-secondary rounded-lg text-foreground text-sm focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
                      />
                    </div>

                    <div>
                      <label className="block text-sm font-medium text-muted mb-1">Overview</label>
                      <input
                        type="text"
                        value={season.overview}
                        onChange={(e) => updateSeason(index, 'overview', e.target.value)}
                        placeholder="Brief description"
                        className="w-full px-2 py-1 bg-card border border-accent-secondary rounded-lg text-foreground text-sm focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="flex justify-end space-x-3 pt-4">
            <button
              type="button"
              onClick={onCancel}
              className="px-4 py-2 bg-background-2 text-foreground border border-accent-secondary rounded-lg hover:bg-accent-secondary/20 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-4 py-2 bg-accent text-white rounded-lg hover:bg-accent-secondary disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              {loading ? 'Saving...' : (tvSeries ? 'Update TV Series' : 'Create TV Series')}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

export default TVSeriesForm