import React, { useState } from 'react'

const Controls: React.FC<{ onSearch?: (q: string) => void; genres?: any[] }> = ({ onSearch, genres }) => {
  const [q, setQ] = useState('')

  return (
    <div className="p-4 flex items-center justify-between gap-4 bg-background-2 border-b border-red-900/10">
      <div className="flex items-center gap-2">
        <select className="bg-card text-foreground p-2 rounded border border-red-800">
          <option value="">All</option>
          <option value="movies">Movies</option>
          <option value="tv">TV Series</option>
        </select>

        <input value={q} onChange={e => setQ(e.target.value)} className="bg-card text-foreground p-2 rounded border border-red-800" placeholder="Search" />
        <button onClick={() => onSearch && onSearch(q)} className="px-3 py-1 rounded bg-accent text-black">Search</button>
      </div>

      <div className="flex items-center gap-2">
        <button className="px-3 py-1 rounded border border-red-700 text-red-300">Favorites</button>
        <button className="px-3 py-1 rounded bg-accent text-black">New</button>
      </div>
    </div>
  )
}

export default Controls
