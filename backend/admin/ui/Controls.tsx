import React, { useState } from 'react'

const Controls: React.FC<{ onSearch?: (q: string) => void; genres?: any[] }> = ({ onSearch, genres }) => {
  const [q, setQ] = useState('')

  return (
    <div className="p-4 flex items-center justify-between gap-4 bg-background-2 border-b border-accent-secondary/10">
      <div className="flex items-center gap-3">
        <select className="bg-card text-foreground p-2 rounded-lg border border-accent-secondary focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors">
          <option value="">All Categories</option>
          <option value="movies">Movies</option>
          <option value="tv">TV Series</option>
        </select>

        <input 
          value={q} 
          onChange={e => setQ(e.target.value)} 
          className="bg-card text-foreground p-2 rounded-lg border border-accent-secondary focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors min-w-[200px]" 
          placeholder="Search content..." 
        />
        <button 
          onClick={() => onSearch && onSearch(q)} 
          className="px-4 py-2 rounded-lg bg-accent text-white font-medium hover:bg-accent-secondary transition-colors"
        >
          Search
        </button>
      </div>

      <div className="flex items-center gap-2">
        <button className="px-3 py-2 rounded-lg border border-accent-secondary text-muted hover:text-foreground hover:border-accent transition-colors">
          Favorites
        </button>
      </div>
    </div>
  )
}

export default Controls
