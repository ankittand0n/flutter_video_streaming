import React from 'react'
import api from '../services/api'

const Card: React.FC<{ title: string; description?: string; content?: any; token?: string; contentType?: 'movie' | 'tv'; onEdit?: (content: any) => void }> = ({ title, description, content, token, contentType = 'movie', onEdit }) => {

  async function addToWL() {
    if (!token) return alert('Provide JWT token in header to call protected endpoints')
    try {
      const res = await api.addToWatchlist(token, { contentId: String(content.id), contentType, title })
      if (res && res.success) alert('Added to watchlist')
      else alert('Add failed: ' + JSON.stringify(res))
    } catch (e) { console.error(e); alert('Add failed') }
  }

  return (
    <article className="p-4 rounded shadow bg-card border border-red-900/10">
      {content?.poster_path && (
        <img
          src={`http://localhost:3000${content.poster_path}`}
          alt={title}
          className="w-full h-48 object-cover rounded mb-3"
          onError={(e) => {
            e.currentTarget.style.display = 'none';
          }}
        />
      )}
      <h3 className="font-semibold text-lg mb-2">{title}</h3>
      <p className="text-sm text-muted">{description}</p>
      <div className="mt-3 flex gap-2">
        {onEdit && (
          <button onClick={() => onEdit(content)} className="px-3 py-1 rounded bg-blue-600 text-white hover:bg-blue-700">Edit</button>
        )}
      </div>
    </article>
  )
}

export default Card
