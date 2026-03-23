import React from 'react'

const Footer: React.FC = () => {
  return (
    <footer className="mt-auto p-4 border-t border-accent-secondary bg-card text-center text-sm text-foreground">
      <a
        href="/privacy-policy"
        target="_blank"
        rel="noopener noreferrer"
        className="text-accent hover:underline transition-colors"
      >
        Privacy Policy
      </a>
      <span className="mx-2 text-accent-secondary">•</span>
      <span className="text-accent-secondary">&copy; 2026 Namkeen TV</span>
    </footer>
  )
}

export default Footer
