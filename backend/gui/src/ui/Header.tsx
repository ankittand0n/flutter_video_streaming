import React from 'react'

const Header: React.FC<{ token?: string | null; onToken?: (t?: string) => void; onSignout?: () => void }> = ({ token, onToken, onSignout }) => {
  return (
    <header className="flex items-center justify-between p-4 bg-card border-b border-red-800">
      <div className="flex items-center gap-3">
        <div className="w-10 h-10 bg-accent rounded flex items-center justify-center font-bold text-black">R</div>
        <h1 className="text-xl">Namkeen TV</h1>
      </div>

      <div className="flex items-center gap-3">
        <input
          className="bg-card text-foreground p-2 rounded border border-red-800"
          placeholder="JWT token (optional)"
          value={token || ''}
          onChange={e => onToken && onToken(e.target.value)}
        />
        {token && (
          <button onClick={() => onSignout && onSignout()} className="px-3 py-1 rounded bg-transparent border border-red-600 text-red-400">Sign out</button>
        )}
      </div>
    </header>
  )
}

export default Header
