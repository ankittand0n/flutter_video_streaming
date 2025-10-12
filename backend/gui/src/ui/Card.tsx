import React from 'react'
import api from '../services/api'

const Card: React.FC<{ title: string; description?: string; movie?: any; token?: string }> = ({ title, description, movie, token }) => {

  async function addToWL() {
    if (!token) return alert('Provide JWT token in header to call protected endpoints')
    try {
      const res = await api.addToWatchlist(token, { contentId: String(movie.id), contentType: 'movie', title: movie.title })
      if (res && res.success) alert('Added to watchlist')
      else alert('Add failed: ' + JSON.stringify(res))
    } catch (e) { console.error(e); alert('Add failed') }
  }

  async function rate(n = 8) {
    if (!token) return alert('Provide JWT token in header to call protected endpoints')
    try {
      const res = await api.postRating(token, { contentId: String(movie.id), contentType: 'movie', rating: n })
      if (res && res.success) alert('Rated')
      else alert('Rate failed: ' + JSON.stringify(res))
    } catch (e) { console.error(e); alert('Rate failed') }
  }

  return (
    <article className="p-4 rounded shadow bg-card border border-red-900/10">
      <h3 className="font-semibold text-lg mb-2">{title}</h3>
      <p className="text-sm text-muted">{description}</p>
      <div className="mt-3 flex gap-2">
        <button onClick={addToWL} className="px-3 py-1 rounded bg-accent text-black">Add</button>
        <button onClick={() => rate(8)} className="px-3 py-1 rounded border border-red-700 text-red-300">Rate 8</button>
      </div>
    </article>
  )
}

export default Card
