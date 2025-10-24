import React from 'react'

const Header: React.FC<{ token?: string | null; onToken?: (t?: string) => void; onSignout?: () => void }> = ({ token, onToken, onSignout }) => {
  return (
    <header className="flex items-center justify-between p-4 bg-card border-b border-accent-secondary">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 bg-accent rounded flex items-center justify-center font-bold text-white">N</div>
        <h1 className="text-xl font-semibold text-foreground">Namkeen TV</h1>
      </div>

      <div className="flex items-center gap-3">
        <input
          className="bg-background-2 text-foreground p-2 rounded border border-accent-secondary focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors"
          placeholder="JWT token (optional)"
          value={token || ''}
          onChange={e => onToken && onToken(e.target.value)}
        />
        {token && (
          <button 
            onClick={() => onSignout && onSignout()} 
            className="px-3 py-1 rounded bg-transparent border border-accent text-accent hover:bg-accent hover:text-white transition-colors"
          >
            Sign out
          </button>
        )}
      </div>
    </header>
  )
}

export default Header
